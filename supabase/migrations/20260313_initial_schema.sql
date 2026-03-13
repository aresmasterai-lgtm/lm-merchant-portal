-- LM Merchant Portal - Initial Database Schema
-- Created: 2026-03-13
-- Based on Build Brief v1.0

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: processors
-- Stores payment processor partner information and matching criteria
CREATE TABLE processors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  short_name TEXT NOT NULL UNIQUE,
  industries_supported TEXT[] NOT NULL DEFAULT '{}',
  min_monthly_volume NUMERIC DEFAULT 0,
  max_monthly_volume NUMERIC DEFAULT NULL,
  accepts_high_risk BOOLEAN NOT NULL DEFAULT false,
  accepts_new_business BOOLEAN NOT NULL DEFAULT false,
  card_present BOOLEAN NOT NULL DEFAULT true,
  card_not_present BOOLEAN NOT NULL DEFAULT true,
  application_schema JSONB DEFAULT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: merchants
-- Stores merchant profile and business information
CREATE TABLE merchants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  dba_name TEXT,
  industry TEXT NOT NULL,
  business_type TEXT NOT NULL,
  monthly_volume NUMERIC NOT NULL,
  avg_ticket NUMERIC NOT NULL,
  card_present BOOLEAN NOT NULL DEFAULT true,
  high_risk BOOLEAN NOT NULL DEFAULT false,
  months_in_business INTEGER NOT NULL,
  current_processor TEXT,
  pain_points TEXT[] DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'profile_complete',
  matched_processor_id UUID REFERENCES processors(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: merchant_applications
-- Tracks merchant applications per processor
CREATE TABLE merchant_applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  processor_id UUID NOT NULL REFERENCES processors(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'draft',
  signwell_document_id TEXT,
  signwell_signing_url TEXT,
  filled_application_url TEXT,
  signed_document_url TEXT,
  submitted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: merchant_documents
-- Stores uploaded merchant documents
CREATE TABLE merchant_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  verified BOOLEAN NOT NULL DEFAULT false,
  notes TEXT
);

-- Table: status_history
-- Audit trail for all status changes
CREATE TABLE status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status TEXT NOT NULL,
  changed_by TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: high_risk_industries
-- Configurable list of industries that auto-flag as high-risk
CREATE TABLE high_risk_industries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  industry_code TEXT NOT NULL UNIQUE,
  industry_name TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default high-risk industries
INSERT INTO high_risk_industries (industry_code, industry_name) VALUES
  ('adult_entertainment', 'Adult Entertainment'),
  ('cbd_cannabis', 'CBD / Cannabis-Adjacent'),
  ('firearms', 'Firearms and Ammunition'),
  ('nutraceuticals', 'Nutraceuticals / Supplements'),
  ('travel_agencies', 'Travel Agencies'),
  ('debt_collection', 'Debt Collection'),
  ('online_gambling', 'Online Gambling / Gaming'),
  ('telemarketing', 'Telemarketing / Subscription Billing');

-- Create indexes for common queries
CREATE INDEX idx_merchants_user_id ON merchants(user_id);
CREATE INDEX idx_merchants_status ON merchants(status);
CREATE INDEX idx_merchants_matched_processor ON merchants(matched_processor_id);
CREATE INDEX idx_merchant_applications_merchant_id ON merchant_applications(merchant_id);
CREATE INDEX idx_merchant_applications_processor_id ON merchant_applications(processor_id);
CREATE INDEX idx_merchant_applications_status ON merchant_applications(status);
CREATE INDEX idx_merchant_documents_merchant_id ON merchant_documents(merchant_id);
CREATE INDEX idx_status_history_merchant_id ON status_history(merchant_id);
CREATE INDEX idx_processors_active ON processors(active);

-- Function: Update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update updated_at on merchants table
CREATE TRIGGER update_merchants_updated_at
  BEFORE UPDATE ON merchants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Auto-update updated_at on merchant_applications table
CREATE TRIGGER update_merchant_applications_updated_at
  BEFORE UPDATE ON merchant_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE status_history ENABLE ROW LEVEL SECURITY;

-- Merchants: Users can only see their own data
CREATE POLICY merchants_select_own ON merchants
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY merchants_insert_own ON merchants
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY merchants_update_own ON merchants
  FOR UPDATE USING (auth.uid() = user_id);

-- Merchant Applications: Users can only see their own applications
CREATE POLICY merchant_applications_select_own ON merchant_applications
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_applications_insert_own ON merchant_applications
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_applications_update_own ON merchant_applications
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

-- Merchant Documents: Users can only see their own documents
CREATE POLICY merchant_documents_select_own ON merchant_documents
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_documents_insert_own ON merchant_documents
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_documents_update_own ON merchant_documents
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

-- Status History: Users can only see their own history
CREATE POLICY status_history_select_own ON status_history
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY status_history_insert_own ON status_history
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

-- Processors: Public read access (all users can see available processors)
CREATE POLICY processors_select_all ON processors
  FOR SELECT USING (active = true);

-- High-Risk Industries: Public read access
ALTER TABLE high_risk_industries ENABLE ROW LEVEL SECURITY;
CREATE POLICY high_risk_industries_select_all ON high_risk_industries
  FOR SELECT USING (active = true);

COMMENT ON TABLE processors IS 'Payment processor partners and their matching criteria';
COMMENT ON TABLE merchants IS 'Merchant business profiles and onboarding status';
COMMENT ON TABLE merchant_applications IS 'Applications submitted to specific processors';
COMMENT ON TABLE merchant_documents IS 'Uploaded merchant documents for verification';
COMMENT ON TABLE status_history IS 'Audit trail of all merchant status changes';
COMMENT ON TABLE high_risk_industries IS 'Configurable list of high-risk industry codes';
