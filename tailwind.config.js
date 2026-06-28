/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Header (soft sunny yellow gradient).
        headerTop: '#FDF1A8',
        headerBottom: '#F8DE7E',
        heroPanel: '#F6DD80',
        footerBottom: '#F7E7C9',
        // Page backgrounds (warm blush).
        blush: '#FCEBEA',
        blushDeep: '#FBE3E2',
        cream: '#FBF4E9',
        // Pinks.
        pink: '#EFA0B0',
        pinkDeep: '#E7849B',
        pinkSoft: '#F3B9C5',
        logo: '#E88AA0',
        // Text.
        ink: '#6E5B57',
        inkSoft: '#9B8884',
      },
      fontFamily: {
        allura: ['Allura', 'cursive'],
        dancing: ['"Dancing Script"', 'cursive'],
        cormorant: ['"Cormorant Garamond"', 'serif'],
        quicksand: ['Quicksand', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
