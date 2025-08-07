from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    supabase_url: str | None = None
    supabase_key: str | None = None
    openai_api_key: str | None = None

    class Config:
        env_file = ".env"

settings = Settings()

