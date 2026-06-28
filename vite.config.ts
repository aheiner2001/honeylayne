import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Served at the apex custom domain (honeylayne.shop), so base is "/".
export default defineConfig({
  base: '/',
  plugins: [react()],
  build: {
    outDir: 'dist',
  },
});
