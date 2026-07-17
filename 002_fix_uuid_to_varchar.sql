-- ==============================================================================
-- OmAstro Schema Fix: Change UUID columns to VARCHAR to support Firebase UIDs
-- ==============================================================================

-- 1. Drop foreign keys temporarily to alter types
ALTER TABLE public.chat_tokens DROP CONSTRAINT IF EXISTS chat_tokens_consultation_id_fkey;
ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_token_id_fkey;
ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_consultation_id_fkey;
ALTER TABLE public.chat_attachments DROP CONSTRAINT IF EXISTS chat_attachments_message_id_fkey;
ALTER TABLE public.astrologer_earnings DROP CONSTRAINT IF EXISTS astrologer_earnings_consultation_id_fkey;

-- 2. Alter consultations table
ALTER TABLE public.consultations 
  ALTER COLUMN user_id TYPE VARCHAR(255),
  ALTER COLUMN astrologer_id TYPE VARCHAR(255);

-- 3. Alter chat_tokens table
ALTER TABLE public.chat_tokens 
  ALTER COLUMN user_id TYPE VARCHAR(255),
  ALTER COLUMN astrologer_id TYPE VARCHAR(255);

-- 4. Alter chat_messages table
ALTER TABLE public.chat_messages 
  ALTER COLUMN sender_id TYPE VARCHAR(255),
  ALTER COLUMN receiver_id TYPE VARCHAR(255);

-- 5. Alter chat_attachments table
ALTER TABLE public.chat_attachments 
  ALTER COLUMN uploader_id TYPE VARCHAR(255);

-- 6. Alter astrologer_earnings table
ALTER TABLE public.astrologer_earnings 
  ALTER COLUMN astrologer_id TYPE VARCHAR(255);

-- 7. Restore foreign keys
ALTER TABLE public.chat_tokens 
  ADD CONSTRAINT chat_tokens_consultation_id_fkey 
  FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE SET NULL;

ALTER TABLE public.chat_messages 
  ADD CONSTRAINT chat_messages_token_id_fkey 
  FOREIGN KEY (token_id) REFERENCES public.chat_tokens(id) ON DELETE SET NULL;

ALTER TABLE public.chat_messages 
  ADD CONSTRAINT chat_messages_consultation_id_fkey 
  FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE CASCADE;

ALTER TABLE public.chat_attachments 
  ADD CONSTRAINT chat_attachments_message_id_fkey 
  FOREIGN KEY (message_id) REFERENCES public.chat_messages(id) ON DELETE CASCADE;

ALTER TABLE public.astrologer_earnings 
  ADD CONSTRAINT astrologer_earnings_consultation_id_fkey 
  FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE SET NULL;
