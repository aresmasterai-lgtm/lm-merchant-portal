-- LM Merchant Portal - Nuvei Technologies Processor
-- Created: 2026-03-13
-- Application schema based on Nuvei application form provided by Kingsley

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
  'Nuvei Technologies',
  'nuvei_technologies',
  ARRAY['restaurant', 'retail', 'ecommerce', 'professional_services', 'healthcare', 'hospitality'],
  0,
  NULL,
  false,
  true,
  true,
  true,
  '{
    "version": "1.0",
    "sections": [
      {
        "section": "MERCHANT BUSINESS INFORMATION",
        "fields": [
          {
            "processor_field": "Legal Name",
            "lm_field": "merchants.business_name",
            "field_type": "text",
            "required": true,
            "max_length": 100
          },
          {
            "processor_field": "Legal Address",
            "lm_field": "merchants.business_address",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Legal City",
            "lm_field": "merchants.business_city",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Legal State",
            "lm_field": "merchants.business_state",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Legal Zip",
            "lm_field": "merchants.business_zip",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Telephone",
            "lm_field": "merchants.business_phone",
            "field_type": "phone",
            "required": true
          },
          {
            "processor_field": "Fax",
            "lm_field": "merchants.business_fax",
            "field_type": "phone",
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
            "processor_field": "IRS Tax Filing Name",
            "lm_field": "merchants.tax_filing_name",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "How Long in Business",
            "lm_field": "merchants.months_in_business",
            "field_type": "text",
            "required": true,
            "transform": "months_to_text"
          },
          {
            "processor_field": "Business Structure",
            "lm_field": "merchants.business_type",
            "field_type": "select",
            "required": true,
            "options": ["Sole Proprietorship", "Partnership", "Limited Liability", "Corporation", "Government", "Non-Profit", "Publicly Traded"]
          },
          {
            "processor_field": "Product or Service Sold",
            "lm_field": "merchants.product_or_service",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Website",
            "lm_field": "merchants.business_website",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Business Email",
            "lm_field": "merchants.business_email",
            "field_type": "email",
            "required": true
          },
          {
            "processor_field": "Customer Service Phone",
            "lm_field": "merchants.customer_service_phone",
            "field_type": "phone",
            "required": true
          }
        ]
      },
      {
        "section": "DBA INFORMATION",
        "fields": [
          {
            "processor_field": "DBA Same as Legal",
            "lm_field": "computed.dba_same_as_legal",
            "field_type": "boolean",
            "required": true,
            "computed": true
          },
          {
            "processor_field": "DBA Name",
            "lm_field": "merchants.dba_name",
            "field_type": "text",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          },
          {
            "processor_field": "DBA Telephone",
            "lm_field": "merchants.dba_phone",
            "field_type": "phone",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          },
          {
            "processor_field": "DBA Fax",
            "lm_field": "merchants.dba_fax",
            "field_type": "phone",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          },
          {
            "processor_field": "DBA Address",
            "lm_field": "merchants.dba_address",
            "field_type": "text",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          },
          {
            "processor_field": "DBA City",
            "lm_field": "merchants.dba_city",
            "field_type": "text",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          },
          {
            "processor_field": "DBA State",
            "lm_field": "merchants.dba_state",
            "field_type": "text",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          },
          {
            "processor_field": "DBA Zip",
            "lm_field": "merchants.dba_zip",
            "field_type": "text",
            "required": false,
            "conditional": "DBA Same as Legal = false"
          }
        ]
      },
      {
        "section": "ELECTRONIC DEBIT/CREDIT AUTHORIZATION",
        "fields": [
          {
            "processor_field": "Deposit Routing Number",
            "lm_field": "merchant_bank_accounts.routing_number[deposit]",
            "field_type": "text",
            "required": true,
            "max_length": 9
          },
          {
            "processor_field": "Deposit Account Number",
            "lm_field": "merchant_bank_accounts.account_number[deposit]",
            "field_type": "text",
            "required": true,
            "max_length": 15
          },
          {
            "processor_field": "Deposit Account Name Matches",
            "lm_field": "merchant_bank_accounts.account_name_matches[deposit]",
            "field_type": "select",
            "required": true,
            "options": ["DBA", "Legal"]
          },
          {
            "processor_field": "Withdrawal Routing Number",
            "lm_field": "merchant_bank_accounts.routing_number[withdrawal]",
            "field_type": "text",
            "required": false,
            "max_length": 9
          },
          {
            "processor_field": "Withdrawal Account Number",
            "lm_field": "merchant_bank_accounts.account_number[withdrawal]",
            "field_type": "text",
            "required": false,
            "max_length": 15
          },
          {
            "processor_field": "Withdrawal Account Name Matches",
            "lm_field": "merchant_bank_accounts.account_name_matches[withdrawal]",
            "field_type": "select",
            "required": false,
            "options": ["DBA", "Legal"]
          }
        ]
      },
      {
        "section": "OWNER 1",
        "fields": [
          {
            "processor_field": "Title",
            "lm_field": "merchant_owners.title[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Email Address",
            "lm_field": "merchant_owners.email[1]",
            "field_type": "email",
            "required": true
          },
          {
            "processor_field": "Percent Ownership",
            "lm_field": "merchant_owners.percent_ownership[1]",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Has Significant Managerial Control",
            "lm_field": "merchant_owners.has_managerial_control[1]",
            "field_type": "boolean",
            "required": true
          },
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
            "processor_field": "Mobile Phone",
            "lm_field": "merchant_owners.mobile_phone[1]",
            "field_type": "phone",
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
            "required": true,
            "format": "mm/dd/yyyy"
          }
        ]
      },
      {
        "section": "OWNER 2",
        "fields": [
          {
            "processor_field": "Title",
            "lm_field": "merchant_owners.title[2]",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Email Address",
            "lm_field": "merchant_owners.email[2]",
            "field_type": "email",
            "required": false
          },
          {
            "processor_field": "Percent Ownership",
            "lm_field": "merchant_owners.percent_ownership[2]",
            "field_type": "number",
            "required": false,
            "format": "percentage"
          },
          {
            "processor_field": "Has Significant Managerial Control",
            "lm_field": "merchant_owners.has_managerial_control[2]",
            "field_type": "boolean",
            "required": false
          },
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
            "processor_field": "Mobile Phone",
            "lm_field": "merchant_owners.mobile_phone[2]",
            "field_type": "phone",
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
            "required": false,
            "format": "mm/dd/yyyy"
          }
        ]
      },
      {
        "section": "SALES PROFILE",
        "fields": [
          {
            "processor_field": "Swipe Percentage",
            "lm_field": "merchants.swipe_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage",
            "validation": "must_total_100_with_ecommerce_moto"
          },
          {
            "processor_field": "Ecommerce Percentage",
            "lm_field": "merchants.ecommerce_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "MOTO/Keyed Percentage",
            "lm_field": "merchants.moto_percentage",
            "field_type": "number",
            "required": true,
            "format": "percentage"
          },
          {
            "processor_field": "Visa/MC/Discover Monthly Volume",
            "lm_field": "merchants.monthly_volume",
            "field_type": "number",
            "required": true,
            "format": "currency"
          },
          {
            "processor_field": "Visa/MC/Discover Average Ticket",
            "lm_field": "merchants.avg_ticket",
            "field_type": "number",
            "required": true,
            "format": "currency"
          },
          {
            "processor_field": "Visa/MC/Discover High Ticket",
            "lm_field": "merchants.high_ticket",
            "field_type": "number",
            "required": true,
            "format": "currency"
          },
          {
            "processor_field": "AMEX Monthly Volume",
            "lm_field": "merchants.amex_monthly_volume",
            "field_type": "number",
            "required": false,
            "format": "currency"
          },
          {
            "processor_field": "AMEX Average Ticket",
            "lm_field": "merchants.amex_avg_ticket",
            "field_type": "number",
            "required": false,
            "format": "currency"
          },
          {
            "processor_field": "Days Until Cardholder Receives Product/Service",
            "lm_field": "merchants.delivery_timeframe",
            "field_type": "select",
            "required": true,
            "options": ["Same Day", "1-5", "6-15", "16-30", "Over 30"]
          }
        ]
      },
      {
        "section": "PCI COMPLIANCE",
        "fields": [
          {
            "processor_field": "Store Credit Card Numbers",
            "lm_field": "merchants.stores_card_numbers",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Third-Party Payment Application Name",
            "lm_field": "merchants.payment_application_name",
            "field_type": "text",
            "required": false,
            "conditional": "Store Credit Card Numbers = true"
          },
          {
            "processor_field": "Third-Party Payment Application Version",
            "lm_field": "merchants.payment_application_version",
            "field_type": "text",
            "required": false,
            "conditional": "Store Credit Card Numbers = true"
          }
        ]
      },
      {
        "section": "EQUIPMENT / SHIPPING",
        "fields": [
          {
            "processor_field": "Ship To",
            "lm_field": "merchant_equipment.ship_to",
            "field_type": "select",
            "required": true,
            "options": ["DBA", "Other Address"]
          },
          {
            "processor_field": "Shipping Method",
            "lm_field": "merchant_equipment.shipping_method",
            "field_type": "select",
            "required": true,
            "options": ["Regular 3-Day", "2-Day", "Next Day", "Overnight"]
          },
          {
            "processor_field": "Shipping Address",
            "lm_field": "merchant_equipment.shipping_address",
            "field_type": "text",
            "required": false,
            "conditional": "Ship To = Other Address"
          },
          {
            "processor_field": "Shipping City",
            "lm_field": "merchant_equipment.shipping_city",
            "field_type": "text",
            "required": false,
            "conditional": "Ship To = Other Address"
          },
          {
            "processor_field": "Shipping State",
            "lm_field": "merchant_equipment.shipping_state",
            "field_type": "text",
            "required": false,
            "conditional": "Ship To = Other Address"
          },
          {
            "processor_field": "Shipping Zip",
            "lm_field": "merchant_equipment.shipping_zip",
            "field_type": "text",
            "required": false,
            "conditional": "Ship To = Other Address"
          },
          {
            "processor_field": "Terminal Type 1",
            "lm_field": "merchant_equipment.terminal_type",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Terminal Quantity 1",
            "lm_field": "merchant_equipment.terminal_quantity",
            "field_type": "number",
            "required": false
          },
          {
            "processor_field": "Software/Gateway",
            "lm_field": "merchant_equipment.software_gateway",
            "field_type": "text",
            "required": false
          },
          {
            "processor_field": "Default Terminal Setup",
            "lm_field": "merchant_equipment.default_terminal_setup",
            "field_type": "select",
            "required": true,
            "options": ["Retail", "Retail with Tip", "MOTO/Ecomm"]
          }
        ]
      },
      {
        "section": "CONTROL PANEL ACCESS",
        "fields": [
          {
            "processor_field": "Request Control Panel Access",
            "lm_field": "merchant_control_panel_access.request_access",
            "field_type": "boolean",
            "required": true
          },
          {
            "processor_field": "Admin First Name",
            "lm_field": "merchant_control_panel_access.admin_first_name",
            "field_type": "text",
            "required": false,
            "conditional": "Request Control Panel Access = true"
          },
          {
            "processor_field": "Admin Last Name",
            "lm_field": "merchant_control_panel_access.admin_last_name",
            "field_type": "text",
            "required": false,
            "conditional": "Request Control Panel Access = true"
          },
          {
            "processor_field": "Admin Title",
            "lm_field": "merchant_control_panel_access.admin_title",
            "field_type": "text",
            "required": false,
            "conditional": "Request Control Panel Access = true"
          },
          {
            "processor_field": "Admin Email",
            "lm_field": "merchant_control_panel_access.admin_email",
            "field_type": "email",
            "required": false,
            "conditional": "Request Control Panel Access = true"
          },
          {
            "processor_field": "Admin Telephone",
            "lm_field": "merchant_control_panel_access.admin_telephone",
            "field_type": "phone",
            "required": false,
            "conditional": "Request Control Panel Access = true"
          }
        ]
      },
      {
        "section": "SIGNATURES",
        "note": "Signatures will be collected via SignWell e-signature",
        "fields": [
          {
            "processor_field": "Principal 1 Full Name",
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
            "processor_field": "Principal 2 Full Name",
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
            "processor_field": "Merchant Signature",
            "lm_field": "signwell.merchant_signature",
            "field_type": "signature",
            "required": true
          },
          {
            "processor_field": "Merchant Name",
            "lm_field": "merchants.business_name",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Merchant Title",
            "lm_field": "merchant_owners.title[1]",
            "field_type": "text",
            "required": true
          },
          {
            "processor_field": "Merchant Date",
            "lm_field": "signwell.merchant_date",
            "field_type": "date",
            "required": true,
            "computed": "signature_date"
          },
          {
            "processor_field": "Opt Out of AMEX Communications",
            "lm_field": "computed.amex_opt_out",
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

COMMENT ON TABLE processors IS 'Nuvei Technologies processor added with complete application schema';
