-- ==============================================================================
-- Final Schema Compatibility Fix: Convert all ID columns to VARCHAR(255)
-- ==============================================================================

-- 1. Drop foreign keys referencing consultations.id
ALTER TABLE public.chat_tokens DROP CONSTRAINT IF EXISTS chat_tokens_consultation_id_fkey;
ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_consultation_id_fkey;
ALTER TABLE public.astrologer_earnings DROP CONSTRAINT IF EXISTS astrologer_earnings_consultation_id_fkey;

-- 2. Drop existing foreign keys on consultations user/astrologer columns
ALTER TABLE public.consultations DROP CONSTRAINT IF EXISTS consultations_user_id_fkey;
ALTER TABLE public.consultations DROP CONSTRAINT IF EXISTS consultations_astrologer_id_fkey;

-- 3. Alter consultations table columns to VARCHAR(255)
ALTER TABLE public.consultations ALTER COLUMN id TYPE VARCHAR(255);
ALTER TABLE public.consultations ALTER COLUMN user_id TYPE VARCHAR(255);
ALTER TABLE public.consultations ALTER COLUMN astrologer_id TYPE VARCHAR(255);

-- 4. Re-add foreign keys referencing consultations.id
ALTER TABLE public.chat_tokens ALTER COLUMN consultation_id TYPE VARCHAR(255);
ALTER TABLE public.chat_messages ALTER COLUMN consultation_id TYPE VARCHAR(255);
ALTER TABLE public.astrologer_earnings ALTER COLUMN consultation_id TYPE VARCHAR(255);

ALTER TABLE public.chat_tokens 
  ADD CONSTRAINT chat_tokens_consultation_id_fkey 
  FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE SET NULL;

ALTER TABLE public.chat_messages 
  ADD CONSTRAINT chat_messages_consultation_id_fkey 
  FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE CASCADE;

ALTER TABLE public.astrologer_earnings 
  ADD CONSTRAINT astrologer_earnings_consultation_id_fkey 
  FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE SET NULL;

-- 5. Add foreign key relationships pointing to profiles(id)
-- Note: profiles.id is VARCHAR(255) because it stores Firebase UIDs.
ALTER TABLE public.consultations
  ADD CONSTRAINT consultations_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.consultations
  ADD CONSTRAINT consultations_astrologer_id_fkey
  FOREIGN KEY (astrologer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
