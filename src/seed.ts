import type { Product } from './types';

// Initial catalog mirroring the reference design. The manager can add,
// edit, or remove these from the manager page.
export const seedProducts: Product[] = [
  {
    id: 'daisy-puff-dress',
    name: 'Daisy Puff Dress',
    price: 72,
    category: 'Dresses',
    imageUrl: 'assets/images/prod_daisy_dress.png',
    instagramUrl: 'https://www.instagram.com/_honeylayne/',
    favorite: true,
  },
  {
    id: 'lily-tie-cardigan',
    name: 'Lily Tie Cardigan',
    price: 48,
    category: 'Tops',
    imageUrl: 'assets/images/prod_lily_cardigan.png',
    instagramUrl: 'https://www.instagram.com/_honeylayne/',
    favorite: true,
  },
  {
    id: 'honey-mini-dress',
    name: 'Honey Mini Dress',
    price: 68,
    category: 'Dresses',
    imageUrl: 'assets/images/prod_honey_dress.png',
    instagramUrl: 'https://www.instagram.com/_honeylayne/',
    favorite: true,
  },
  {
    id: 'ruffle-tank-top',
    name: 'Ruffle Tank Top',
    price: 36,
    category: 'Tops',
    imageUrl: 'assets/images/prod_ruffle_top.png',
    instagramUrl: 'https://www.instagram.com/_honeylayne/',
    favorite: true,
  },
  {
    id: 'blossom-midi-skirt',
    name: 'Blossom Midi Skirt',
    price: 54,
    category: 'Bottoms',
    imageUrl: 'assets/images/prod_blossom_skirt.png',
    instagramUrl: 'https://www.instagram.com/_honeylayne/',
    favorite: true,
  },
];
