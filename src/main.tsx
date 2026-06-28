import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';

import App from './App';
import { HoneyStoreProvider } from './store/HoneyStore';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <HoneyStoreProvider>
        <App />
      </HoneyStoreProvider>
    </BrowserRouter>
  </StrictMode>,
);
