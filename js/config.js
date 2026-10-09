// Supabase config
// These values are safe to expose in frontend code — the publishable/anon key
// is meant to be public. Real protection comes from Row Level Security (RLS)
// policies set up in the database (see supabase/migrations/0001_init.sql).

const SUPABASE_URL = 'vaxyttjngalvvshfkpaj';
const SUPABASE_ANON_KEY = 'sb_publishable_0MHAMCm1cGvSoMAtKboPeA_5O-lFYbl';

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
