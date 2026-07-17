-- ==============================================================================
-- Final Schema Compatibility Script (Run on Supabase Dashboard SQL Editor)
-- ==============================================================================

-- 1. Drop foreign keys referencing consultations.id
ALTER TABLE public.chat_tokens DROP CONSTRAINT IF EXISTS chat_tokens_consultation_id_fkey;
ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_consultation_id_fkey;
ALTER TABLE public.astrologer_earnings DROP CONSTRAINT IF EXISTS astrologer_earnings_consultation_id_fkey;

-- 2. Drop existing foreign keys on consultations user/astrologer columns
ALTER TABLE public.consultations DROP CONSTRAINT IF EXISTS consultations_user_id_fkey;
ALTER TABLE public.consultations DROP CONSTRAINT IF EXISTS consultations_astrologer_id_fkey;

-- 3. Alter columns to correct types
-- consultations.id must be VARCHAR(255) to support Firestore IDs
ALTER TABLE public.consultations ALTER COLUMN id TYPE VARCHAR(255);

-- consultations.user_id must be UUID (matches profiles.id)
ALTER TABLE public.consultations ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

-- consultations.astrologer_id must be VARCHAR(255) (matches astrologers.firebase_uid)
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

-- 5. Add a UNIQUE constraint on astrologers.firebase_uid so it can be referenced by foreign keys
ALTER TABLE public.astrologers DROP CONSTRAINT IF EXISTS astrologers_firebase_uid_key;
ALTER TABLE public.astrologers ADD CONSTRAINT astrologers_firebase_uid_key UNIQUE (firebase_uid);

-- 6. Add foreign key relationships to profiles and astrologers
-- consultations.user_id (UUID) points to profiles.id (UUID)
ALTER TABLE public.consultations
  ADD CONSTRAINT consultations_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- consultations.astrologer_id (VARCHAR) points to astrologers.firebase_uid (VARCHAR)
ALTER TABLE public.consultations
  ADD CONSTRAINT consultations_astrologer_id_fkey
  FOREIGN KEY (astrologer_id) REFERENCES public.astrologers(firebase_uid) ON DELETE CASCADE;

-- 7. Add foreign key linking astrologers.id to profiles.id (1-to-1 extension relationship)
-- First clean up notify_requests pointing to orphaned astrologers
DELETE FROM public.notify_requests WHERE astrologer_id NOT IN (SELECT id FROM public.profiles);

-- Next clean up any orphaned astrologers that do not exist in profiles
DELETE FROM public.astrologers WHERE id NOT IN (SELECT id FROM public.profiles);

ALTER TABLE public.astrologers DROP CONSTRAINT IF EXISTS fk_astrologers_profile_id;
ALTER TABLE public.astrologers
  ADD CONSTRAINT fk_astrologers_profile_id
  FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE;
