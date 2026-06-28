import { getFunctions, httpsCallable } from 'firebase/functions';

import { authEnabled } from '../store/HoneyStore';
import type { CartItem } from '../store/CartStore';

interface CheckoutResponse {
  url: string;
}

/** Ask the Cloud Function to create a Stripe Checkout Session for the cart,
 * then redirect the browser to Stripe's hosted checkout page. Prices and
 * availability are re-validated server-side, so the client list is just IDs. */
export async function startCheckout(items: CartItem[]): Promise<void> {
  if (!authEnabled) {
    throw new Error('Checkout is not configured yet. Please reach out on Instagram.');
  }
  if (items.length === 0) return;

  const fn = httpsCallable<{ ids: string[]; origin: string }, CheckoutResponse>(
    getFunctions(),
    'createCheckoutSession',
  );

  const res = await fn({
    ids: items.map((i) => i.id),
    origin: window.location.origin,
  });

  const url = res.data?.url;
  if (!url) throw new Error('Could not start checkout. Please try again.');
  window.location.assign(url);
}
