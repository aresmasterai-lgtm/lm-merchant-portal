-- LM Merchant Portal - Additional Fields for Wholesale Payments
-- Created: 2026-03-13
-- Adds fields required by Wholesale Payments / Merrick Bank application

-- Add corporate address fields (separate from location/business address)
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS corporate_address TEXT,
  ADD COLUMN IF NOT EXISTS corporate_city TEXT,
  ADD COLUMN IF NOT EXISTS corporate_state TEXT,
  ADD COLUMN IF NOT EXISTS corporate_zip TEXT;

-- Add contact person fields (separate from business owner)
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS contact_name TEXT,
  ADD COLUMN IF NOT EXISTS contact_phone TEXT;

-- Add business registration and ownership fields
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS state_issued TEXT,
  ADD COLUMN IF NOT EXISTS ownership_years INTEGER,
  ADD COLUMN IF NOT EXISTS ownership_months INTEGER;

-- Add sales breakdown fields (consumer/business/government percentages)
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS sales_to_consumer_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS sales_to_business_percentage NUMERIC,
  ADD COLUMN IF NOT EXISTS sales_to_government_percentage NUMERIC;

-- Add current processing and seasonal fields
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS currently_accepts_cards BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_seasonal_merchant BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS seasonal_active_months TEXT[],
  ADD COLUMN IF NOT EXISTS reason_leaving_processor TEXT;

-- Add fields to merchant_owners table
ALTER TABLE merchant_owners
  ADD COLUMN IF NOT EXISTS control_prong BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS drivers_license_expiration DATE,
  ADD COLUMN IF NOT EXISTS telephone TEXT;

-- Add fields to merchant_bank_accounts table
ALTER TABLE merchant_bank_accounts
  ADD COLUMN IF NOT EXISTS bank_name TEXT,
  ADD COLUMN IF NOT EXISTS bank_phone TEXT,
  ADD COLUMN IF NOT EXISTS account_type_detail TEXT CHECK (account_type_detail IN ('Checking', 'Savings'));

-- Add fields to merchant_equipment table
ALTER TABLE merchant_equipment
  ADD COLUMN IF NOT EXISTS equipment_type TEXT,
  ADD COLUMN IF NOT EXISTS manufacturer TEXT,
  ADD COLUMN IF NOT EXISTS model_version TEXT,
  ADD COLUMN IF NOT EXISTS quantity INTEGER,
  ADD COLUMN IF NOT EXISTS deployment TEXT,
  ADD COLUMN IF NOT EXISTS connection TEXT,
  ADD COLUMN IF NOT EXISTS special_instructions TEXT;

-- Table: merchant_card_types
-- Tracks which card types the merchant wants to accept
CREATE TABLE IF NOT EXISTS merchant_card_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
  accept_visa_credit BOOLEAN DEFAULT false,
  accept_visa_debit BOOLEAN DEFAULT false,
  accept_mastercard_credit BOOLEAN DEFAULT false,
  accept_mastercard_debit BOOLEAN DEFAULT false,
  accept_discover BOOLEAN DEFAULT false,
  accept_american_express BOOLEAN DEFAULT false,
  accept_pin_debit BOOLEAN DEFAULT false,
  accept_ebt BOOLEAN DEFAULT false,
  opt_out_amex_marketing BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_merchant_card_types UNIQUE (merchant_id)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_merchant_card_types_merchant_id ON merchant_card_types(merchant_id);

-- Row Level Security
ALTER TABLE merchant_card_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY merchant_card_types_select_own ON merchant_card_types
  FOR SELECT USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_card_types_insert_own ON merchant_card_types
  FOR INSERT WITH CHECK (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

CREATE POLICY merchant_card_types_update_own ON merchant_card_types
  FOR UPDATE USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );

-- Auto-update trigger
CREATE TRIGGER update_merchant_card_types_updated_at
  BEFORE UPDATE ON merchant_card_types
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE merchant_card_types IS 'Tracks which card types merchant wants to accept (Visa, MC, Discover, Amex, PIN Debit, EBT)';
