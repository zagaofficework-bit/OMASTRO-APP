-- ==============================================================================
-- OmAstro Fix: Disable Row-Level Security (RLS) to prevent Forbidden inserts/updates
-- ==============================================================================

ALTER TABLE public.consultations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_tokens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_attachments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.astrologer_earnings DISABLE ROW LEVEL SECURITY;
