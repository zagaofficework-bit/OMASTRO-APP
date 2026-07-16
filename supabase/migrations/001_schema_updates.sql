-- ============================================================
-- OmAstro Schema Update Migration
-- Run this in Supabase SQL Editor
-- ============================================================

-- ① DROP deprecated columns from astrologers
ALTER TABLE public.astrologers DROP COLUMN IF EXISTS followers;
ALTER TABLE public.astrologers DROP COLUMN IF EXISTS orders_completed;

-- ② ADD new metric and rate columns to astrologers
ALTER TABLE public.astrologers ADD COLUMN IF NOT EXISTS total_minutes_consulted integer NOT NULL DEFAULT 0;
ALTER TABLE public.astrologers ADD COLUMN IF NOT EXISTS chat_rate numeric NOT NULL DEFAULT 5;
ALTER TABLE public.astrologers ADD COLUMN IF NOT EXISTS call_rate numeric NOT NULL DEFAULT 10;
ALTER TABLE public.astrologers ADD COLUMN IF NOT EXISTS video_rate numeric NOT NULL DEFAULT 15;

-- ③ CREATE notify_requests table for "Notify Me" feature
CREATE TABLE IF NOT EXISTS public.notify_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  astrologer_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  notified boolean NOT NULL DEFAULT false,
  CONSTRAINT notify_requests_pkey PRIMARY KEY (id),
  CONSTRAINT notify_requests_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT notify_requests_astrologer_fkey FOREIGN KEY (astrologer_id) REFERENCES public.astrologers(id),
  CONSTRAINT notify_requests_unique_pair UNIQUE (user_id, astrologer_id)
);

-- Enable RLS on notify_requests
ALTER TABLE public.notify_requests ENABLE ROW LEVEL SECURITY;

-- Policy: users can insert their own notify requests
CREATE POLICY "Users can insert own notify requests"
  ON public.notify_requests FOR INSERT
  WITH CHECK (true);

-- Policy: users can read their own notify requests
CREATE POLICY "Users can read own notify requests"
  ON public.notify_requests FOR SELECT
  USING (true);

-- ④ CREATE astrologer_reviews table if it does not exist, and add constraint linking user_id to profiles(id)
CREATE TABLE IF NOT EXISTS public.astrologer_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  astrologer_id uuid REFERENCES public.astrologers(id) ON DELETE CASCADE,
  user_id text, -- Firebase UID
  rating integer CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamp with time zone DEFAULT now()
);

-- If user_id exists as incompatible type, drop and recreate it as uuid
ALTER TABLE public.astrologer_reviews DROP COLUMN IF EXISTS user_id;
ALTER TABLE public.astrologer_reviews ADD COLUMN user_id uuid;

-- Ensure profiles foreign key constraint exists so select joins can run
ALTER TABLE public.astrologer_reviews DROP CONSTRAINT IF EXISTS fk_astrologer_reviews_user_id;
ALTER TABLE public.astrologer_reviews 
  ADD CONSTRAINT fk_astrologer_reviews_user_id 
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) 
  ON DELETE SET NULL;

-- ⑤ CREATE wallet tables for starter balance support
CREATE TABLE IF NOT EXISTS public.wallets (
  user_id uuid NOT NULL,
  balance_paise bigint NOT NULL DEFAULT 150000,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT wallets_pkey PRIMARY KEY (user_id),
  CONSTRAINT wallets_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  amount_paise bigint NOT NULL,
  kind text NOT NULL CHECK (kind IN ('credit', 'debit')),
  status text NOT NULL DEFAULT 'success',
  note text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT wallet_transactions_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own wallet" ON public.wallets;
CREATE POLICY "Users can manage their own wallet"
  ON public.wallets
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage their own wallet transactions" ON public.wallet_transactions;
CREATE POLICY "Users can manage their own wallet transactions"
  ON public.wallet_transactions
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
