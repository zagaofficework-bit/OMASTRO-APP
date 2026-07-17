-- ============================================================
-- Supabase Storage & Database RLS Policies for chat_attachments
-- Run this in your Supabase SQL Editor
-- ============================================================

-- 1. Ensure the 'chat_attachments' bucket exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat_attachments', 'chat_attachments', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Drop existing storage policies to prevent conflicts
DROP POLICY IF EXISTS "Allow public uploads to chat_attachments" ON storage.objects;
DROP POLICY IF EXISTS "Allow public select from chat_attachments" ON storage.objects;
DROP POLICY IF EXISTS "Allow public updates to chat_attachments" ON storage.objects;
DROP POLICY IF EXISTS "Allow public deletes from chat_attachments" ON storage.objects;

-- 3. Create permissive storage policies for the 'chat_attachments' bucket
CREATE POLICY "Allow public uploads to chat_attachments"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'chat_attachments');

CREATE POLICY "Allow public select from chat_attachments"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'chat_attachments');

CREATE POLICY "Allow public updates to chat_attachments"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'chat_attachments');

CREATE POLICY "Allow public deletes from chat_attachments"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'chat_attachments');

-- 4. Ensure RLS is disabled on the database table 'chat_attachments'
ALTER TABLE public.chat_attachments DISABLE ROW LEVEL SECURITY;
