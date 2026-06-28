import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

import type { Product } from '../types';

/** A line in the cart. Each one-of-a-kind piece can only be added once, so
 * there's no quantity — a product is either in the cart or it isn't. */
export interface CartItem {
  id: string;
  name: string;
  price: number;
  imageUrl: string;
}

interface Cart {
  items: CartItem[];
  count: number;
  subtotal: number;
  isOpen: boolean;
  has: (id: string) => boolean;
  add: (product: Product) => void;
  remove: (id: string) => void;
  clear: () => void;
  open: () => void;
  close: () => void;
}

const CartContext = createContext<Cart | null>(null);
const STORAGE_KEY = 'hl_cart';

function load(): CartItem[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.map((e: any) => ({
      id: String(e.id),
      name: String(e.name ?? ''),
      price: Number(e.price ?? 0),
      imageUrl: String(e.imageUrl ?? ''),
    }));
  } catch {
    return [];
  }
}

export function CartProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<CartItem[]>(load);
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    } catch {
      /* ignore quota errors */
    }
  }, [items]);

  const add = useCallback((product: Product) => {
    setItems((prev) =>
      prev.some((i) => i.id === product.id)
        ? prev
        : [
            ...prev,
            {
              id: product.id,
              name: product.name,
              price: product.price,
              imageUrl: product.imageUrl,
            },
          ],
    );
    setIsOpen(true);
  }, []);

  const remove = useCallback(
    (id: string) => setItems((prev) => prev.filter((i) => i.id !== id)),
    [],
  );

  const clear = useCallback(() => setItems([]), []);

  const value = useMemo<Cart>(
    () => ({
      items,
      count: items.length,
      subtotal: items.reduce((sum, i) => sum + i.price, 0),
      isOpen,
      has: (id: string) => items.some((i) => i.id === id),
      add,
      remove,
      clear,
      open: () => setIsOpen(true),
      close: () => setIsOpen(false),
    }),
    [items, isOpen, add, remove, clear],
  );

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

export function useCart(): Cart {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart must be used within CartProvider');
  return ctx;
}
