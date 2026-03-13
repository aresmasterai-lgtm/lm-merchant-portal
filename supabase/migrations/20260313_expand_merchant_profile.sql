-- LM Merchant Portal - Expand Merchant Profile for Processor Applications
-- Created: 2026-03-13
-- Adds fields required by Nuvei and other processor applications

-- Add business address fields
ALTER TABLE merchants 
  ADD COLUMN IF NOT EXISTS business_address TEXT,
  ADD COLUMN IF NOT EXISTS business_city TEXT,
  ADD COLUMN IF NOT EXISTS business_state TEXT,
  ADD COLUMN IF NOT EXISTS business_zip TEXT,
  ADD COLUMN IF NOT EXISTS business_phone TEXT,
  ADD COLUMN IF NOT EXISTS business_fax TEXT,
  ADD COLUMN IF NOT EXISTS business_email TEXT,
  ADD COLUMN IF NOT EXISTS customer_service_phone TEXT,
  ADD COLUMN IF NOT EXISTS business_website TEXT,
  ADD COLUMN IF NOT EXISTS federal_tax_id TEXT,
  ADD COLUMN IF NOT EXISTS tax_filing_name TEXT,
  ADD COLUMN IF NOT EXISTS product_or_service TEXT;

-- Add DBA address fields (separate from main business address)
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS dba_address TEXT,
  ADD COLUMN IF NOT EXISTS dba_city TEXT,
  ADD COLUMN IF NOT EXISTS dba_state TEXT,
  ADD COLUMN IF NOT EXISTS dba_zip TEXT,
  ADD COLUMN IF NOT EXISTS dba_phone TEXT,
  ADD COLUMN IF NOT EXISTS dba_fax TEXT;

-- Add sales profile fields
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS swipe_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS ecommerce_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS moto_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS high_ticket NUMERIC,
  ADD COLUMN IF NOT EXISTS amex_monthly_volume NUMERIC,
  ADD COLUMN IF NOT EXISTS amex_avg_ticket NUMERIC,
  ADD COLUMN IF NOT EXISTS delivery_timeframe TEXT;

-- Add PCI compliance fields
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS stores_card_numbers BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS payment_application_name TEXT,
  ADD COLUMN IF NOT EXISTS payment_application_version TEXT;

-- Table: merchant_owners
-- Stores owner/officer information for merchant applications
CREATE TABLE IF NOT EXISTS merchant_owners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  owner_number INTEGER NOT NULL DEFAULT 1,
  title TEXT,
  email TEXT,
  percent_ownership NUMERIC,
  has_managerial_control BOOLEAN DEFAULT false,
  first_name TEXT,
  last_name TEXT,
  drivers_license_number TEXT,
  drivers_license_state TEXT,
  home_address TEXT,
  home_city TEXT,
  home_state TEXT,
  home_zip TEXT,
  mobile_phone TEXT,
  ssn TEXT,
  date_of_birth DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_merchant_owner UNIQUE (merchant_id, owner_number)
);

-- Table: merchant_bank_accounts
-- Stores bank account information for deposits and withdrawals
CREATE TABLE IF NOT EXISTS merchant_bank_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  account_type TEXT NOT NULL CHECK (account_type IN ('deposit', 'withdrawal')),
  routing_number TEXT,
  account_number TEXT,
  account_name_matches TEXT CHECK (account_name_matches IN ('DBA', 'Legal')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: merchant_equipment
-- Stores equipment/shipping preferences
CREATE TABLE IF NOT EXISTS merchant_equipment (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  ship_to TEXT,
  shipping_method TEXT,
  shipping_address TEXT,
  shipping_city TEXT,
  shipping_state TEXT,
  shipping_zip TEXT,
  terminal_type TEXT,
  terminal_quantity INTEGER,
  software_gateway TEXT,
  default_terminal_setup TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: merchant_control_panel_access
-- Stores admin access requests for processor control panels
CREATE TABLE IF NOT EXISTS merchant_control_panel_access (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  processor_id UUID REFERENCES processors(id) ON DELETE CASCADE,
  request_access BOOLEAN DEFAULT false,
  admin_first_name TEXT,
  admin_last_name TEXT,
  admin_title TEXT,
  admin_email TEXT,
  admin_telephone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_merchant_owners_merchant_id ON merchant_owners(merchant_id);
CREATE INDEX IF NOT EXISTS idx_merchant_bank_accounts_merchant_id ON merchant_bank_accounts(merchant_id);
CREATE INDEX IF NOT EXISTS idx_merchant_equipment_merchant_id ON merchant_equipment(merchant_id);
CREATE INDEX IF NOT EXISTS idx_merchant_control_panel_access_merchant_id ON merchant_control_panel_access(merchant_id);

-- Row Level Security
ALTER TABLE merchant_owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_control_panel_access ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only access their own data
CREATE POLICY merchant_owners_select_own ON merchant_owners
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_owners_insert_own ON merchant_owners
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_owners_update_own ON merchant_owners
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_bank_accounts_select_own ON merchant_bank_accounts
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_bank_accounts_insert_own ON merchant_bank_accounts
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_bank_accounts_update_own ON merchant_bank_accounts
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_equipment_select_own ON merchant_equipment
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_equipment_insert_own ON merchant_equipment
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_equipment_update_own ON merchant_equipment
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_control_panel_access_select_own ON merchant_control_panel_access
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_control_panel_access_insert_own ON merchant_control_panel_access
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_control_panel_access_update_own ON merchant_control_panel_access
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

-- Auto-update triggers
CREATE TRIGGER update_merchant_owners_updated_at
  BEFORE UPDATE ON merchant_owners
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchant_bank_accounts_updated_at
  BEFORE UPDATE ON merchant_bank_accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchant_equipment_updated_at
  BEFORE UPDATE ON merchant_equipment
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchant_control_panel_access_updated_at
  BEFORE UPDATE ON merchant_control_panel_access
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE merchant_owners IS 'Owner/officer information for merchant applications';
COMMENT ON TABLE merchant_bank_accounts IS 'Bank account information for deposits and withdrawals';
COMMENT ON TABLE merchant_equipment IS 'Equipment and shipping preferences';
COMMENT ON TABLE merchant_control_panel_access IS 'Admin access requests for processor control panels';
