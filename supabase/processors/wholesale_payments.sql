-- LM Merchant Portal - Wholesale Payments / Merrick Bank Processor
-- Created: 2026-03-13
-- Application schema based on Wholesale Payments application form provided by Kingsley

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
  'Wholesale Payments / Merrick Bank',
  'wholesale_payments',
  ARRAY['restaurant', 'retail', 'ecommerce', 'professional_services', 'healthcare', 'hospitality', 'automotive', 'services'],
  0,
  NULL,
  true,
  true,
  true,
  true,
  '{
    "version": "1.0",
    "sections": [
      {
        "section": "BUSINESS INFORMATION",
        "fields": [
          {
            "processor_field": "DBA / Trade Name",
            "lm_field": "merchants.dba_name",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Corporate / Legal Name",
            "lm_field": "merchants.business_name",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Location Address",
            "lm_field": "merchants.business_address",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Corporate Address",
            "lm_field": "merchants.corporate_address",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Location City",
            "lm_field": "merchants.business_city",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Location State",
            "lm_field": "merchants.business_state",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Location Zip",
            "lm_field": "merchants.business_zip",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Corporate City",
            "lm_field": "merchants.corporate_city",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Corporate State",
            "lm_field": "merchants.corporate_state",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Corporate Zip",
            "lm_field": "merchants.corporate_zip",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Phone Number",
            "lm_field": "merchants.business_phone",
            "field_type": "phone",
            "required": true
          },
          {
            "processor_field": "Fax Number",
            "lm_field": "merchants.business_fax",
            "field_type": "phone",
            "required": false
          },
          {
            "processor_field": "Contact Name",
            "lm_field": "merchants.contact_name",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Contact Phone",
            "lm_field": "merchants.contact_phone",
            "field_type": "phone",
            "required": true
          },
          {
            "processor_field": "Business Email",
            "lm_field": "merchants.business_email",
            "field_type": "email",
            "required": true
          },
          {
            "processor_field": "Website",
            "lm_field": "merchants.business_website",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Federal Tax ID",
            "lm_field": "merchants.federal_tax_id",
            "field_type": "text",
            "required": true,
            "format": "ein"
          },
          {
            "processor_field": "Business Structure",
            "lm_field": "merchants.business_type",
            "field_type": "select",
            "required": true,
            "options": ["Individual/Sole Prop", "Partnership", "Corporation", "LLC", "Non-Profit", "Government"]
          },
          {
            "processor_field": "State Issued",
            "lm_field": "merchants.state_issued",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Length of Ownership - Years",
            "lm_field": "merchants.ownership_years",
            "field_type": "number",
            "required": true
          },
          {
            "processor_field": "Length of Ownership - Months",
            "lm_field": "merchants.ownership_months",
            "field_type": "number",
            "required": true
          }
        ]
      },
      {
        "section": "OWNER 1",
        "fields": [
          {
            "processor_field": "First Name",
            "lm_field": "merchant_owners.first_name[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Last Name",
            "lm_field": "merchant_owners.last_name[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Home Address",
            "lm_field": "merchant_owners.home_address[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Home City",
            "lm_field": "merchant_owners.home_city[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Home State",
            "lm_field": "merchant_owners.home_state[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Home Zip",
            "lm_field": "merchant_owners.home_zip[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Title",
            "lm_field": "merchant_owners.title[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Ownership Percentage",
            "lm_field": "merchant_owners.percent_ownership[1]",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Control Prong",
            "lm_field": "merchant_owners.control_prong[1]",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Telephone",
            "lm_field": "merchant_owners.telephone[1]",
            "field_type": "phone",
            "required": true
          },
          {
            "processor_field": "Email",
            "lm_field": "merchant_owners.email[1]",
            "field_type": "email",
            "required": true
          },
          {
            "processor_field": "SSN",
            "lm_field": "merchant_owners.ssn[1]",
            "field_type": "text",
            "required": true,
            "format": "ssn"
          },
          {
            "processor_field": "Date of Birth",
            "lm_field": "merchant_owners.date_of_birth[1]",
            "field_type": "date",
            "required": true
          },
          {
            "processor_field": "Driver''s License Number",
            "lm_field": "merchant_owners.drivers_license_number[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Driver''s License State",
            "lm_field": "merchant_owners.drivers_license_state[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Driver''s License Expiration",
            "lm_field": "merchant_owners.drivers_license_expiration[1]",
            "field_type": "date",
            "required": true
          }
        ]
      },
      {
        "section": "OWNER 2",
        "fields": [
          {
            "processor_field": "First Name",
            "lm_field": "merchant_owners.first_name[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Last Name",
            "lm_field": "merchant_owners.last_name[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Home Address",
            "lm_field": "merchant_owners.home_address[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Home City",
            "lm_field": "merchant_owners.home_city[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Home State",
            "lm_field": "merchant_owners.home_state[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Home Zip",
            "lm_field": "merchant_owners.home_zip[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Title",
            "lm_field": "merchant_owners.title[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Ownership Percentage",
            "lm_field": "merchant_owners.percent_ownership[2]",
            "field_type": "number",
            "required": false,
            "format": "percentage"
          },
          {
            "processor_field": "Control Prong",
            "lm_field": "merchant_owners.control_prong[2]",
            "field_type": "boolean",
            "required": false
          },
          {
            "processor_field": "Telephone",
            "lm_field": "merchant_owners.telephone[2]",
            "field_type": "phone",
            "required": false
          },
          {
            "processor_field": "Email",
            "lm_field": "merchant_owners.email[2]",
            "field_type": "email",
            "required": false
          },
          {
            "processor_field": "SSN",
            "lm_field": "merchant_owners.ssn[2]",
            "field_type": "text",
            "required": false,
            "format": "ssn"
          },
          {
            "processor_field": "Date of Birth",
            "lm_field": "merchant_owners.date_of_birth[2]",
            "field_type": "date",
            "required": false
          },
          {
            "processor_field": "Driver''s License Number",
            "lm_field": "merchant_owners.drivers_license_number[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Driver''s License State",
            "lm_field": "merchant_owners.drivers_license_state[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Driver''s License Expiration",
            "lm_field": "merchant_owners.drivers_license_expiration[2]",
            "field_type": "date",
            "required": false
          }
        ]
      },
      {
        "section": "BANKING ACCOUNT INFORMATION",
        "fields": [
          {
            "processor_field": "Bank Name",
            "lm_field": "merchant_bank_accounts.bank_name[deposit]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Transit / Routing Number",
            "lm_field": "merchant_bank_accounts.routing_number[deposit]",
            "field_type": "text",
            "required": true,
            "max_length": 9
          },
          {
            "processor_field": "Account / DDA Number",
            "lm_field": "merchant_bank_accounts.account_number[deposit]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Bank Phone",
            "lm_field": "merchant_bank_accounts.bank_phone[deposit]",
            "field_type": "phone",
            "required": true
          },
          {
            "processor_field": "Account Type",
            "lm_field": "merchant_bank_accounts.account_type_detail[deposit]",
            "field_type": "select",
            "required": true,
            "options": ["Checking", "Savings"]
          }
        ]
      },
      {
        "section": "TRANSACTION INFORMATION",
        "fields": [
          {
            "processor_field": "Business Type",
            "lm_field": "merchants.industry",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Product / Services Sold",
            "lm_field": "merchants.product_or_service",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Monthly Payment Volume",
            "lm_field": "merchants.monthly_volume",
            "field_type": "number",
            "required": true,
            "format": "currency"
          },
          {
            "processor_field": "American Express Volume",
            "lm_field": "merchants.amex_monthly_volume",
            "field_type": "number",
            "required": false,
            "format": "currency"
          },
          {
            "processor_field": "Average Ticket",
            "lm_field": "merchants.avg_ticket",
            "field_type": "number",
            "required": true,
            "format": "currency"
          },
          {
            "processor_field": "High Ticket",
            "lm_field": "merchants.high_ticket",
            "field_type": "number",
            "required": true,
            "format": "currency"
          },
          {
            "processor_field": "Swipe Percentage",
            "lm_field": "merchants.swipe_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "MOTO Percentage",
            "lm_field": "merchants.moto_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Internet Percentage",
            "lm_field": "merchants.ecommerce_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Sales to Consumer Percentage",
            "lm_field": "merchants.sales_to_consumer_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Sales to Business Percentage",
            "lm_field": "merchants.sales_to_business_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Sales to Government Percentage",
            "lm_field": "merchants.sales_to_government_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Days to Delivery",
            "lm_field": "merchants.delivery_timeframe",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Currently Accepts Payment Cards",
            "lm_field": "merchants.currently_accepts_cards",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Seasonal Merchant",
            "lm_field": "merchants.is_seasonal_merchant",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Active Months if Seasonal",
            "lm_field": "merchants.seasonal_active_months",
            "field_type": "text",
            "required": false,
            "conditional": "Seasonal Merchant = true",
            "note": "Array of active months"
          },
          {
            "processor_field": "Reason for Leaving Current Processor",
            "lm_field": "merchants.reason_leaving_processor",
            "field_type": "text",
            "required": false
          }
        ]
      },
      {
        "section": "REQUESTED CARD TYPES",
        "fields": [
          {
            "processor_field": "Accept Visa Credit",
            "lm_field": "merchant_card_types.accept_visa_credit",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept Visa Debit",
            "lm_field": "merchant_card_types.accept_visa_debit",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept Mastercard Credit",
            "lm_field": "merchant_card_types.accept_mastercard_credit",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept Mastercard Debit",
            "lm_field": "merchant_card_types.accept_mastercard_debit",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept Discover",
            "lm_field": "merchant_card_types.accept_discover",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept American Express",
            "lm_field": "merchant_card_types.accept_american_express",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept PIN Debit",
            "lm_field": "merchant_card_types.accept_pin_debit",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Accept EBT",
            "lm_field": "merchant_card_types.accept_ebt",
            "field_type": "boolean",
            "required": true
          }
        ]
      },
      {
        "section": "EQUIPMENT",
        "fields": [
          {
            "processor_field": "Equipment Type 1",
            "lm_field": "merchant_equipment.equipment_type",
            "field_type": "select",
            "required": false,
            "options": ["Terminal", "Pin Pad", "VAR", "Gateway"]
          },
          {
            "processor_field": "Manufacturer 1",
            "lm_field": "merchant_equipment.manufacturer",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Model/Version 1",
            "lm_field": "merchant_equipment.model_version",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Quantity 1",
            "lm_field": "merchant_equipment.quantity",
            "field_type": "number",
            "required": false
          },
          {
            "processor_field": "Deployment 1",
            "lm_field": "merchant_equipment.deployment",
            "field_type": "select",
            "required": false,
            "options": ["New Order", "Existing"]
          },
          {
            "processor_field": "Connection 1",
            "lm_field": "merchant_equipment.connection",
            "field_type": "select",
            "required": false,
            "options": ["Dial", "Ethernet", "Wireless"]
          },
          {
            "processor_field": "Payment Application Name",
            "lm_field": "merchant_equipment.payment_application_name",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Payment Application Version",
            "lm_field": "merchant_equipment.payment_application_version",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Additional Special Instructions",
            "lm_field": "merchant_equipment.special_instructions",
            "field_type": "text",
            "required": false
          }
        ]
      },
      {
        "section": "SIGNATURES",
        "note": "Signatures will be collected via SignWell e-signature",
        "fields": [
          {
            "processor_field": "Principal 1 Name",
            "lm_field": "computed.principal_1_name",
            "field_type": "text",
            "required": true,
            "computed": "merchant_owners[1].first_name + merchant_owners[1].last_name"
          },
          {
            "processor_field": "Principal 1 Title",
            "lm_field": "merchant_owners.title[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Principal 1 Signature",
            "lm_field": "signwell.signature[1]",
            "field_type": "signature",
            "required": true
          },
          {
            "processor_field": "Principal 1 Date",
            "lm_field": "signwell.date[1]",
            "field_type": "date",
            "required": true,
            "computed": "signature_date"
          },
          {
            "processor_field": "Principal 2 Name",
            "lm_field": "computed.principal_2_name",
            "field_type": "text",
            "required": false,
            "computed": "merchant_owners[2].first_name + merchant_owners[2].last_name"
          },
          {
            "processor_field": "Principal 2 Title",
            "lm_field": "merchant_owners.title[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Principal 2 Signature",
            "lm_field": "signwell.signature[2]",
            "field_type": "signature",
            "required": false
          },
          {
            "processor_field": "Principal 2 Date",
            "lm_field": "signwell.date[2]",
            "field_type": "date",
            "required": false,
            "computed": "signature_date"
          },
          {
            "processor_field": "Opt Out of AMEX Marketing",
            "lm_field": "merchant_card_types.opt_out_amex_marketing",
            "field_type": "boolean",
            "required": false,
            "default": false
          }
        ]
      }
    ]
  }'::jsonb,
  true
);

COMMENT ON TABLE processors IS 'Wholesale Payments / Merrick Bank processor added with complete application schema';
