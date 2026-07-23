-- ==============================================================================
-- OmAstro Fix: Automate total_minutes_consulted updates via Database Trigger
-- Run this on your Supabase SQL Editor to bypass RLS restrictions
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.sync_astrologer_consulted_minutes()
RETURNS TRIGGER AS $$
DECLARE
    mins INT;
BEGIN
    -- Check if status is completed and there is a duration
    IF NEW.status = 'Completed' AND NEW.duration_seconds > 0 THEN
        mins := CEIL(NEW.duration_seconds / 60.0);
        
        -- Increment the total_minutes_consulted in astrologers table
        -- Matches both Supabase UUID (id) and Firebase UID (firebase_uid)
        UPDATE public.astrologers
        SET total_minutes_consulted = COALESCE(total_minutes_consulted, 0) + mins
        WHERE id::text = NEW.astrologer_id OR firebase_uid = NEW.astrologer_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS update_astrologer_minutes_trigger ON public.consultations;
CREATE TRIGGER update_astrologer_minutes_trigger
AFTER INSERT OR UPDATE OF status ON public.consultations
FOR EACH ROW
EXECUTE FUNCTION public.sync_astrologer_consulted_minutes();
