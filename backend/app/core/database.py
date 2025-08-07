from supabase import create_client
from .config import settings

supabase = None
if settings.supabase_url and settings.supabase_key:
    supabase = create_client(settings.supabase_url, settings.supabase_key)

