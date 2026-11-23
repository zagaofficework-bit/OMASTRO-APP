-- ============================================================
-- OmAstro Migration: Add birth_place and birth_time to profiles
-- Run this in your Supabase SQL Editor
-- ============================================================

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS birth_place text DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS birth_time text DEFAULT '';