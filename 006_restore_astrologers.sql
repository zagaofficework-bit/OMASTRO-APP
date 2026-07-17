-- ==============================================================================
-- Restore 4 Astrologers in auth.users, profiles, and astrologers tables
-- ==============================================================================

-- 1. Clean up existing auth users with duplicate emails if they exist with different IDs
DELETE FROM auth.users WHERE email IN (
  'astro.priya@omastro.app', 
  'yogini.meera@omastro.app', 
  'pandit.ramesh@omastro.app', 
  'acharya.shivam@omastro.app'
);

-- 2. Insert into auth.users (Supabase Auth)
INSERT INTO auth.users (
  id, 
  email, 
  encrypted_password, 
  email_confirmed_at, 
  raw_app_meta_data, 
  raw_user_meta_data, 
  created_at, 
  updated_at, 
  role, 
  aud
)
VALUES 
  (
    '7cf5a1bc-37b9-4042-bf29-d9c372aa12e6', 
    'astro.priya@omastro.app', 
    crypt('password123', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{}', 
    now(), 
    now(), 
    'authenticated', 
    'authenticated'
  ),
  (
    '28e48fff-bc76-43c3-b4fc-53e058bb2c6c', 
    'yogini.meera@omastro.app', 
    crypt('password123', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{}', 
    now(), 
    now(), 
    'authenticated', 
    'authenticated'
  ),
  (
    '7ddb004c-46ae-4714-87f3-81042c4a3e79', 
    'pandit.ramesh@omastro.app', 
    crypt('password123', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{}', 
    now(), 
    now(), 
    'authenticated', 
    'authenticated'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440000', 
    'acharya.shivam@omastro.app', 
    crypt('password123', gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}', 
    '{}', 
    now(), 
    now(), 
    'authenticated', 
    'authenticated'
  )
ON CONFLICT (id) DO NOTHING;

-- 3. Insert into public.profiles
INSERT INTO public.profiles (id, full_name, avatar_url)
VALUES 
  ('7cf5a1bc-37b9-4042-bf29-d9c372aa12e6', 'Astro Priya', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop'),
  ('28e48fff-bc76-43c3-b4fc-53e058bb2c6c', 'Yogini Meera', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=200&fit=crop'),
  ('7ddb004c-46ae-4714-87f3-81042c4a3e79', 'Pandit Ramesh', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&h=200&fit=crop'),
  ('550e8400-e29b-41d4-a716-446655440000', 'Acharya Shivam', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=200&fit=crop')
ON CONFLICT (id) DO UPDATE 
SET 
  full_name = EXCLUDED.full_name,
  avatar_url = EXCLUDED.avatar_url;

-- 4. Insert into public.astrologers
INSERT INTO public.astrologers (
  id, 
  name, 
  avatar_url, 
  firebase_uid, 
  price_per_minute, 
  chat_rate, 
  call_rate, 
  video_rate, 
  experience_years, 
  languages, 
  skills, 
  categories, 
  rating, 
  reviews_count, 
  total_minutes_consulted
)
VALUES 
  (
    '7cf5a1bc-37b9-4042-bf29-d9c372aa12e6', 
    'Astro Priya', 
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop', 
    'DRBaphzzYdYVcLnPfPAhYHynQn93', 
    10.0, 
    5.0, 
    10.0, 
    15.0, 
    5, 
    ARRAY['Hindi', 'English'], 
    ARRAY['Vedic Astrology', 'Tarot Card Reading'], 
    ARRAY['Love', 'Career'], 
    4.8, 
    124, 
    1240
  ),
  (
    '28e48fff-bc76-43c3-b4fc-53e058bb2c6c', 
    'Yogini Meera', 
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=200&fit=crop', 
    '4QByl2hM3HZPj2cb0W4mYhXooMo2', 
    12.0, 
    6.0, 
    12.0, 
    18.0, 
    8, 
    ARRAY['Hindi', 'English', 'Gujarati'], 
    ARRAY['Kundli Matching', 'Numerology'], 
    ARRAY['Marriage', 'Finance'], 
    4.9, 
    98, 
    980
  ),
  (
    '7ddb004c-46ae-4714-87f3-81042c4a3e79', 
    'Pandit Ramesh', 
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&h=200&fit=crop', 
    'bD5luP4IfnbCU1s0EbRCjSGKWWf1', 
    15.0, 
    8.0, 
    15.0, 
    20.0, 
    15, 
    ARRAY['Hindi', 'Sanskrit'], 
    ARRAY['Vastu Shastra', 'Palmistry'], 
    ARRAY['Family', 'Health'], 
    4.7, 
    215, 
    3220
  ),
  (
    '550e8400-e29b-41d4-a716-446655440000', 
    'Acharya Shivam', 
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=200&fit=crop', 
    'shivam-firebase-uid-1234', 
    15.0, 
    8.0, 
    15.0, 
    20.0, 
    10, 
    ARRAY['Hindi', 'English'], 
    ARRAY['Vedic Astrology', 'Vastu Shastra'], 
    ARRAY['Career', 'Finance'], 
    4.9, 
    152, 
    2240
  )
ON CONFLICT (id) DO UPDATE 
SET 
  name = EXCLUDED.name,
  avatar_url = EXCLUDED.avatar_url,
  firebase_uid = EXCLUDED.firebase_uid,
  price_per_minute = EXCLUDED.price_per_minute,
  chat_rate = EXCLUDED.chat_rate,
  call_rate = EXCLUDED.call_rate,
  video_rate = EXCLUDED.video_rate;
