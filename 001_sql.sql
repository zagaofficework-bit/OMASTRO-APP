-- ==============================================================================
-- OmAstro Chat Token & Consultation Billing Architecture Schema
-- ==============================================================================

-- 1. Consultations Table
CREATE TABLE IF NOT EXISTS public.consultations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL, 
    astrologer_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'chat', 'audio', 'video'
    status VARCHAR(50) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Accepted', 'Connected', 'In Progress', 'Completed', 'Ended'
    duration_seconds INT NOT NULL DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Chat Tokens Table
CREATE TABLE IF NOT EXISTS public.chat_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id UUID REFERENCES public.consultations(id) ON DELETE SET NULL,
    user_id UUID NOT NULL,
    astrologer_id UUID NOT NULL,
    characters_total INT NOT NULL DEFAULT 160,
    characters_remaining INT NOT NULL DEFAULT 160,
    free_attachment_total INT NOT NULL DEFAULT 2,
    free_attachment_remaining INT NOT NULL DEFAULT 2,
    extra_attachment_purchased INT NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE', -- 'ACTIVE', 'EXHAUSTED'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Chat Messages Table
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token_id UUID REFERENCES public.chat_tokens(id) ON DELETE SET NULL,
    consultation_id UUID REFERENCES public.consultations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    text TEXT,
    characters_consumed INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. Chat Attachments Table
CREATE TABLE IF NOT EXISTS public.chat_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES public.chat_messages(id) ON DELETE CASCADE,
    uploader_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    file_size_bytes INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. Astrologer Earnings Table (Platform Internal Tracking)
CREATE TABLE IF NOT EXISTS public.astrologer_earnings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    astrologer_id UUID NOT NULL,
    consultation_id UUID REFERENCES public.consultations(id) ON DELETE SET NULL,
    gross_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.0,
    commission_rate DECIMAL(5, 2) NOT NULL DEFAULT 40.0,
    net_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.0,
    status VARCHAR(50) NOT NULL DEFAULT 'UNPAID', -- 'UNPAID', 'PROCESSING', 'PAID'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Function to update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for chat_tokens
DROP TRIGGER IF EXISTS update_chat_tokens_modtime ON public.chat_tokens;
CREATE TRIGGER update_chat_tokens_modtime
BEFORE UPDATE ON public.chat_tokens
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.astrologer_earnings ENABLE ROW LEVEL SECURITY;
