/**
 * honeylayne — Stripe checkout Cloud Functions (Firebase Functions v2).
 *
 *  - createCheckoutSession (callable): builds one Stripe Checkout Session from
 *    the buyer's cart. Prices and availability are re-read from Firestore so the
 *    browser is never trusted with amounts.
 *  - stripeWebhook (HTTPS): Stripe calls this after payment; we mark each
 *    purchased one-of-a-kind piece as sold and store an order record.
 */
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const Stripe = require('stripe');

initializeApp();
const db = getFirestore();

const STRIPE_SECRET_KEY = defineSecret('STRIPE_SECRET_KEY');
const STRIPE_WEBHOOK_SECRET = defineSecret('STRIPE_WEBHOOK_SECRET');

// ─────────────────────────────────────────────────────────────────────────────
// EDIT THESE to match your shop. Amounts are in cents.
const CURRENCY = 'usd';
const SHIP_COUNTRIES = ['US'];
const PICKUP_LABEL = 'Free pickup — Nampa, ID';
const LOCAL_DELIVERY_CENTS = 500; // $5 — maker drives to your address
const LOCAL_DELIVERY_LABEL = 'Local delivery (near Nampa, ID)';
const STANDARD_SHIPPING_CENTS = 800; // $8 — standard mail
const STANDARD_SHIPPING_LABEL = 'Standard shipping';
// Origins allowed to set success/cancel redirect URLs.
const ALLOWED_ORIGINS = [
  'https://honeylayne.com',
  'https://www.honeylayne.com',
  'http://localhost:5173',
  'http://localhost:4173',
];
const DEFAULT_SITE_URL = 'https://honeylayne.com';
// ─────────────────────────────────────────────────────────────────────────────

function shippingOptions() {
  const rate = (cents, label) => ({
    shipping_rate_data: {
      type: 'fixed_amount',
      fixed_amount: { amount: cents, currency: CURRENCY },
      display_name: label,
    },
  });
  return [
    rate(0, PICKUP_LABEL),
    rate(LOCAL_DELIVERY_CENTS, LOCAL_DELIVERY_LABEL),
    rate(STANDARD_SHIPPING_CENTS, STANDARD_SHIPPING_LABEL),
  ];
}

function safeOrigin(origin) {
  return ALLOWED_ORIGINS.includes(origin) ? origin : DEFAULT_SITE_URL;
}

exports.createCheckoutSession = onCall(
  { secrets: [STRIPE_SECRET_KEY], cors: ALLOWED_ORIGINS },
  async (request) => {
    const ids = Array.isArray(request.data?.ids) ? request.data.ids.map(String) : [];
    if (ids.length === 0) {
      throw new HttpsError('invalid-argument', 'Your cart is empty.');
    }

    const origin = safeOrigin(request.data?.origin);
    const stripe = new Stripe(STRIPE_SECRET_KEY.value());

    // Re-read each product; reject if missing or already sold.
    const lineItems = [];
    const unavailable = [];
    for (const id of ids) {
      const snap = await db.collection('products').doc(id).get();
      const p = snap.data();
      if (!snap.exists || !p || p.sold === true) {
        unavailable.push(id);
        continue;
      }
      const product_data = { name: p.name || 'honeylayne piece' };
      if (typeof p.imageUrl === 'string' && /^https?:\/\//.test(p.imageUrl)) {
        product_data.images = [p.imageUrl];
      }
      lineItems.push({
        quantity: 1,
        price_data: {
          currency: CURRENCY,
          unit_amount: Math.round(Number(p.price || 0) * 100),
          product_data,
        },
      });
    }

    if (unavailable.length > 0) {
      throw new HttpsError(
        'failed-precondition',
        'Some pieces are no longer available. Please remove them and try again.',
        { unavailable },
      );
    }

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: lineItems,
      shipping_address_collection: { allowed_countries: SHIP_COUNTRIES },
      shipping_options: shippingOptions(),
      phone_number_collection: { enabled: true },
      success_url: `${origin}/?checkout=success`,
      cancel_url: `${origin}/?checkout=cancel`,
      metadata: { productIds: ids.join(',') },
    });

    return { url: session.url };
  },
);

exports.stripeWebhook = onRequest(
  { secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET] },
  async (req, res) => {
    const stripe = new Stripe(STRIPE_SECRET_KEY.value());
    let event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        req.headers['stripe-signature'],
        STRIPE_WEBHOOK_SECRET.value(),
      );
    } catch (err) {
      console.error('Webhook signature verification failed:', err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const ids = (session.metadata?.productIds || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);

      const batch = db.batch();
      for (const id of ids) {
        batch.set(
          db.collection('products').doc(id),
          { sold: true },
          { merge: true },
        );
      }
      batch.set(db.collection('orders').doc(session.id), {
        productIds: ids,
        email: session.customer_details?.email || null,
        name: session.customer_details?.name || null,
        phone: session.customer_details?.phone || null,
        shipping: session.customer_details?.address || null,
        amountTotal: session.amount_total,
        currency: session.currency,
        createdAt: FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }

    res.json({ received: true });
  },
);
