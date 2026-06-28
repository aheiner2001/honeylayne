import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';

import App from './App';
import { HoneyStoreProvider } from './store/HoneyStore';
import { CartProvider } from './store/CartStore';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <HoneyStoreProvider>
        <CartProvider>
          <App />
        </CartProvider>
      </HoneyStoreProvider>
    </BrowserRouter>
  </StrictMode>,
);
