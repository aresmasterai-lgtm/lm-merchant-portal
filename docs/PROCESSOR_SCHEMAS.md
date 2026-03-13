# Processor Application Schemas

## Overview

Each processor in the `processors` table has an `application_schema` field (JSONB) that defines how to auto-fill their application form with merchant profile data.

**DO NOT hardcode processor schemas in the codebase.**  
Schemas should be added via the Admin Panel or SQL scripts after Kingsley provides the application field mappings.

---

## Schema Structure

```json
{
  "version": "1.0",
  "fields": [
    {
      "processor_field": "Business Legal Name",
      "lm_field": "merchants.business_name",
      "field_type": "text",
      "required": true,
      "max_length": 100,
      "format": null
    },
    {
      "processor_field": "Monthly Card Volume",
      "lm_field": "merchants.monthly_volume",
      "field_type": "number",
      "required": true,
      "max_length": null,
      "format": "currency"
    }
  ]
}
```

### Field Definitions

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `processor_field` | string | Yes | Label on the processor's application form |
| `lm_field` | string | Yes | Path to merchant profile field (e.g., `merchants.business_name`) |
| `field_type` | string | Yes | Data type: `text`, `number`, `boolean`, `date`, `email`, `phone`, `select`, `textarea` |
| `required` | boolean | Yes | Whether this field is required on the application |
| `max_length` | number | No | Maximum character length (for text fields) |
| `format` | string | No | Special formatting: `currency`, `percentage`, `phone`, `ssn`, `ein` |

---

## Available Merchant Fields

These are the fields currently available in the merchant profile that can be mapped to processor applications:

| LM Field | Description | Type |
|----------|-------------|------|
| `merchants.business_name` | Business Legal Name | text |
| `merchants.dba_name` | Doing Business As (DBA) | text |
| `merchants.industry` | Industry code | text |
| `merchants.business_type` | Sole prop, LLC, Corp, Partnership | text |
| `merchants.monthly_volume` | Estimated monthly card volume | number |
| `merchants.avg_ticket` | Average transaction size | number |
| `merchants.card_present` | Card-present transactions (swipe/tap) | boolean |
| `merchants.high_risk` | High-risk flag | boolean |
| `merchants.months_in_business` | How long business has existed | number |
| `merchants.current_processor` | Current payment processor | text |
| `merchants.pain_points` | Array of pain points | array |

**Note:** As the merchant profile expands (e.g., adding owner info, business address, tax ID), more fields will become available for mapping.

---

## Adding a Processor Schema

### Option 1: Via Admin Panel (Recommended)

1. Log in to the Admin Panel
2. Go to **Processors** → **Add New Processor**
3. Fill in basic processor info
4. Click **Schema Builder**
5. For each field on the processor's application:
   - Enter the processor's field label
   - Select the matching LM merchant field
   - Choose the field type
   - Mark as required/optional
   - Save
6. Activate the processor

### Option 2: Via SQL

```sql
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
  ARRAY['restaurant', 'retail', 'ecommerce', 'professional_services'],
  0,
  NULL,
  true,
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
        "processor_field": "Monthly Processing Volume",
        "lm_field": "merchants.monthly_volume",
        "field_type": "number",
        "required": true,
        "format": "currency"
      }
    ]
  }'::jsonb,
  true
);
```

---

## How Auto-Fill Works

When a merchant applies to a processor:

1. System retrieves the processor's `application_schema`
2. For each field in the schema:
   - Extract value from merchant profile using `lm_field` path
   - Format the value based on `field_type` and `format`
   - Populate the processor's application field
3. Generate pre-filled PDF
4. Send to SignWell for merchant signature

**Example:**

If processor schema has:
```json
{
  "processor_field": "Monthly Card Volume",
  "lm_field": "merchants.monthly_volume",
  "field_type": "number",
  "format": "currency"
}
```

And merchant profile has:
```json
{
  "monthly_volume": 50000
}
```

The auto-filled application will show:
```
Monthly Card Volume: $50,000.00
```

---

## Schema Validation

All schemas are validated using `validateApplicationSchema()` in `src/lib/schemaHelpers.js`.

**Validation checks:**
- Schema has a `version` field
- Schema has a `fields` array
- Each field has `processor_field`, `lm_field`, `field_type`, and `required`
- Field types are valid: `text`, `number`, `boolean`, `date`, `email`, `phone`, `select`, `textarea`

Invalid schemas will throw an error and prevent auto-fill.

---

## Launch Processors (Phase 1)

Two processors will be added in Phase 1:
1. **Wholesale Payments / Merrick Bank**
2. **Nuvei Technologies**

**Kingsley will provide:**
- Complete application form field list for each processor
- Required vs. optional fields
- Field formats and validation rules
- Volume ranges and industry support

**Do NOT create placeholder schemas for these processors.**  
Wait for Kingsley to provide the actual application field mappings.

---

## Future Enhancements

**Phase 2 will add:**
- Support for conditional fields (e.g., show field X only if field Y = value)
- Multi-page application support
- Section grouping (Business Info, Owner Info, Bank Info, etc.)
- Custom validation rules per field
- Support for repeating sections (multiple owners, locations, etc.)

---

## Testing Schemas

Use the helper functions in `src/lib/schemaHelpers.js`:

```javascript
import { 
  validateApplicationSchema, 
  autoFillApplication, 
  checkSchemaCompletion 
} from './lib/schemaHelpers';

// Validate a schema
const { isValid, errors } = validateApplicationSchema(processorSchema);

// Auto-fill an application
const filledData = autoFillApplication(merchantProfile, processorSchema);

// Check if merchant profile has all required fields
const { isComplete, missingFields } = checkSchemaCompletion(merchantProfile, processorSchema);
```

---

## Questions?

Contact Kingsley for processor-specific application requirements.  
For technical schema issues, check `src/lib/schemaHelpers.js`.
