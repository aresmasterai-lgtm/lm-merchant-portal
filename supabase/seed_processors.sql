-- LM Merchant Portal - Processor Seed Data
-- Created: 2026-03-13
-- 
-- This file sets up the infrastructure for processor application schemas.
-- DO NOT hardcode actual processor schemas here.
-- Schemas will be provided by Kingsley and added via Admin Panel.

-- Example processor structure (for reference only - delete before production)
-- This shows the expected format but should be replaced with real data
INSERT INTO processors (
  name,
  short_name,
  industries_supported,
  min_monthly_volume,
  max_monthly_volume,
  accepts_high_risk,
  accepts_new_business,
  card_present,
  card_not_present,
  application_schema,
  active
) VALUES (
  'Example Processor (DELETE ME)',
  'example_processor',
  ARRAY['restaurant', 'retail', 'ecommerce'],
  0,
  NULL,
  false,
  true,
  true,
  true,
  '{
    "version": "1.0",
    "fields": [
      {
        "processor_field": "Business Legal Name",
        "lm_field": "merchants.business_name",
        "field_type": "text",
        "required": true,
        "max_length": 100
      },
      {
        "processor_field": "DBA Name",
        "lm_field": "merchants.dba_name",
        "field_type": "text",
        "required": false,
        "max_length": 100
      },
      {
        "processor_field": "Monthly Card Volume",
        "lm_field": "merchants.monthly_volume",
        "field_type": "number",
        "required": true,
        "format": "currency"
      },
      {
        "processor_field": "Average Ticket Size",
        "lm_field": "merchants.avg_ticket",
        "field_type": "number",
        "required": true,
        "format": "currency"
      }
    ]
  }'::jsonb,
  false
);

-- Note: The above is an EXAMPLE ONLY. 
-- Real processor data should be added via the Admin Panel or by running
-- update scripts with actual processor details provided by Kingsley.

-- To add a real processor, use this template:
-- 
-- INSERT INTO processors (
--   name,
--   short_name,
--   industries_supported,
--   min_monthly_volume,
--   max_monthly_volume,
--   accepts_high_risk,
--   accepts_new_business,
--   card_present,
--   card_not_present,
--   application_schema,
--   active
-- ) VALUES (
--   'Processor Name',
--   'processor_slug',
--   ARRAY['industry1', 'industry2', 'industry3'],
--   minimum_volume_number,
--   maximum_volume_number_or_NULL,
--   true_or_false,
--   true_or_false,
--   true_or_false,
--   true_or_false,
--   '{
--     "version": "1.0",
--     "fields": [
--       {
--         "processor_field": "Field Label on Processor Application",
--         "lm_field": "merchants.field_name",
--         "field_type": "text|number|boolean|date|email|phone",
--         "required": true|false,
--         "max_length": number_or_null,
--         "format": "currency|percentage|phone|ssn|ein|custom"
--       }
--     ]
--   }'::jsonb,
--   true
-- );

COMMENT ON TABLE processors IS 'Payment processor partners. Schemas should be added via Admin Panel with data from Kingsley.';
