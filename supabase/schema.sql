-- Supabase schema initial
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR UNIQUE NOT NULL,
  subscription_type VARCHAR DEFAULT 'free',
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS formations (
  id VARCHAR PRIMARY KEY,
  title VARCHAR NOT NULL,
  level VARCHAR NOT NULL,
  modules JSONB NOT NULL,
  price DECIMAL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_progress (
  user_id UUID REFERENCES users(id),
  formation_id VARCHAR REFERENCES formations(id),
  module_id VARCHAR,
  completed_at TIMESTAMP,
  score INTEGER,
  PRIMARY KEY (user_id, formation_id, module_id)
);

CREATE TABLE IF NOT EXISTS webinaires (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR NOT NULL,
  scheduled_at TIMESTAMP NOT NULL,
  google_meet_url VARCHAR,
  max_participants INTEGER DEFAULT 25,
  current_participants INTEGER DEFAULT 0
);
