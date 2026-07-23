-- ==============================================================================
-- Disable Row-Level Security (RLS) on astrologers and profiles
-- This prevents RLS from silently blocking profile updates from the app
-- ==============================================================================

ALTER TABLE public.astrologers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
