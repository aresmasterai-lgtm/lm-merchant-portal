# Nuvei Technologies - Application Schema

**Created:** March 13, 2026  
**Source:** Application field list provided by Kingsley  
**Status:** Complete ✅

---

## Overview

This document explains the **Nuvei Technologies** processor schema and the database expansions needed to support it.

The Nuvei application is comprehensive and required expanding the merchant profile with:
- Business address fields
- DBA address fields  
- Sales profile fields (transaction percentages, volumes)
- PCI compliance fields
- **4 new related tables** for owner info, bank accounts, equipment, and control panel access

---

## Database Expansions

### New Fields Added to `merchants` Table

**Business Information:**
- `business_address`
- `business_city`
- `business_state`
- `business_zip`
- `business_phone`
- `business_fax`
- `business_email`
- `customer_service_phone`
- `business_website`
- `federal_tax_id`
- `tax_filing_name`
- `product_or_service`

**DBA Address (Separate):**
- `dba_address`
- `dba_city`
- `dba_state`
- `dba_zip`
- `dba_phone`
- `dba_fax`

**Sales Profile:**
- `swipe_percentage`
- `ecommerce_percentage`
- `moto_percentage`
- `high_ticket`
- `amex_monthly_volume`
- `amex_avg_ticket`
- `delivery_timeframe`

**PCI Compliance:**
- `stores_card_numbers`
- `payment_application_name`
- `payment_application_version`

---

### New Related Tables

#### 1. `merchant_owners`
Stores owner/officer information (supports multiple owners via `owner_number`).

**Fields:**
- `title`
- `email`
- `percent_ownership`
- `has_managerial_control`
- `first_name`, `last_name`
- `drivers_license_number`, `drivers_license_state`
- `home_address`, `home_city`, `home_state`, `home_zip`
- `mobile_phone`
- `ssn`
- `date_of_birth`

**Usage:**
```javascript
await db.upsertOwner(merchantId, 1, ownerData);
await db.getOwners(merchantId);
```

---

#### 2. `merchant_bank_accounts`
Stores bank account information for deposits and withdrawals.

**Fields:**
- `account_type` (deposit | withdrawal)
- `routing_number`
- `account_number`
- `account_name_matches` (DBA | Legal)

**Usage:**
```javascript
await db.upsertBankAccount(merchantId, 'deposit', accountData);
await db.getBankAccounts(merchantId);
```

---

#### 3. `merchant_equipment`
Stores equipment and shipping preferences.

**Fields:**
- `ship_to`
- `shipping_method`
- `shipping_address`, `shipping_city`, `shipping_state`, `shipping_zip`
- `terminal_type`, `terminal_quantity`
- `software_gateway`
- `default_terminal_setup`

**Usage:**
```javascript
await db.upsertEquipment(merchantId, equipmentData);
await db.getEquipment(merchantId);
```

---

#### 4. `merchant_control_panel_access`
Stores admin access requests for processor control panels.

**Fields:**
- `processor_id`
- `request_access`
- `admin_first_name`, `admin_last_name`
- `admin_title`
- `admin_email`, `admin_telephone`

**Usage:**
```javascript
await db.upsertControlPanelAccess(merchantId, processorId, accessData);
await db.getControlPanelAccess(merchantId, processorId);
```

---

## Nuvei Application Sections

The Nuvei schema is organized into 10 sections:

### 1. MERCHANT BUSINESS INFORMATION
15 fields including legal name, address, contact info, tax ID, business structure, products/services.

### 2. DBA INFORMATION
8 conditional fields (only required if DBA differs from legal name).

### 3. ELECTRONIC DEBIT/CREDIT AUTHORIZATION
6 fields for deposit and withdrawal bank accounts.

### 4. OWNER 1
15 required fields for primary owner/officer information.

### 5. OWNER 2
15 optional fields for secondary owner (conditional).

### 6. SALES PROFILE
9 fields including transaction percentages, volumes, ticket sizes, delivery timeframe.

**Note:** `swipe_percentage`, `ecommerce_percentage`, and `moto_percentage` must total 100%.

### 7. PCI COMPLIANCE
3 fields for card storage and payment application info.

### 8. EQUIPMENT / SHIPPING
10 fields for equipment preferences and shipping details.

### 9. CONTROL PANEL ACCESS
6 conditional fields for admin access requests.

### 10. SIGNATURES
13 fields for principal and merchant signatures (handled by SignWell).

---

## Auto-Fill Field Mapping

**Example mappings:**

| Processor Field | LM Field | Type | Required |
|----------------|----------|------|----------|
| Legal Name | `merchants.business_name` | text | Yes |
| Legal Address | `merchants.business_address` | text | Yes |
| Federal Tax ID | `merchants.federal_tax_id` | text (EIN) | Yes |
| Monthly Volume | `merchants.monthly_volume` | currency | Yes |
| Owner 1 First Name | `merchant_owners.first_name[1]` | text | Yes |
| Deposit Routing Number | `merchant_bank_accounts.routing_number[deposit]` | text (9 digits) | Yes |

**Array Notation:**
- `[1]` = Owner 1
- `[2]` = Owner 2
- `[deposit]` = Deposit account
- `[withdrawal]` = Withdrawal account

---

## Conditional Fields

Some fields are only required if certain conditions are met:

**DBA Fields:**
- Only required if `DBA Same as Legal = false`

**PCI Application Info:**
- Only required if `Store Credit Card Numbers = true`

**Shipping Address:**
- Only required if `Ship To = Other Address`

**Control Panel Admin:**
- Only required if `Request Control Panel Access = true`

**Owner 2:**
- All Owner 2 fields are optional

---

## Processor Criteria

**Nuvei Technologies supports:**
- **Industries:** Restaurant, Retail, E-commerce, Professional Services, Healthcare, Hospitality
- **Volume:** $0 - Unlimited
- **High-Risk:** No (does not accept high-risk merchants)
- **New Business:** Yes (accepts businesses < 3 months old)
- **Card Present:** Yes
- **Card Not Present:** Yes

---

## Migration Files

1. **`20260313_expand_merchant_profile.sql`**
   - Adds all new fields to `merchants` table
   - Creates 4 new related tables
   - Sets up RLS policies
   - Creates triggers and indexes

2. **`supabase/processors/nuvei_technologies.sql`**
   - Inserts Nuvei processor record
   - Complete application schema with all 10 sections
   - Field mappings and validation rules

---

## Next Steps

### For Development:
1. ✅ Run migration: `20260313_expand_merchant_profile.sql`
2. ✅ Insert processor: `supabase/processors/nuvei_technologies.sql`
3. Build multi-step profile form to collect all required data
4. Build owner information form (supports 2+ owners)
5. Build bank account form (deposit + optional withdrawal)
6. Build equipment/shipping preferences form
7. Build control panel access form
8. Test auto-fill logic with complete merchant profile
9. Integrate SignWell for signatures

### For Business Profile Form:
The merchant profile form should be a **multi-step wizard**:

**Step 1: Business Basics**
- Legal name, DBA, industry, business type

**Step 2: Business Details**
- Address, contact info, tax ID, products/services

**Step 3: Transaction Profile**
- Volume, ticket sizes, transaction percentages, delivery timeframe

**Step 4: Owner Information**
- Owner 1 (required)
- Owner 2+ (optional, repeatable)

**Step 5: Bank Accounts**
- Deposit account (required)
- Withdrawal account (optional)

**Step 6: Equipment & PCI**
- Equipment preferences
- PCI compliance
- Control panel access

**Step 7: Review & Submit**
- Summary of all entered data
- Validation check

---

## Testing Checklist

- [ ] Create merchant profile with all required fields
- [ ] Add 2 owners
- [ ] Add deposit and withdrawal bank accounts
- [ ] Add equipment preferences
- [ ] Run matching engine against Nuvei
- [ ] Auto-fill Nuvei application
- [ ] Verify all 10 sections populate correctly
- [ ] Test conditional field logic
- [ ] Verify validation rules (percentages total 100%, etc.)
- [ ] Send to SignWell for signatures
- [ ] Retrieve signed document

---

## Questions for Kingsley

**Clarifications needed:**
1. **Business Structure mapping:** How do we map our simplified `business_type` (Sole Prop, LLC, Corp, Partnership) to Nuvei's expanded options (includes Government, Non-Profit, Publicly Traded)?
2. **Volume ranges:** What are Nuvei's actual minimum/maximum monthly volume requirements?
3. **Industry support:** Which specific industries does Nuvei support? Should we include all industries or only certain ones?
4. **High-risk acceptance:** Confirm Nuvei does NOT accept high-risk merchants.
5. **Signature workflow:** Do Principal 1 and Principal 2 need to sign, or just the Merchant signature?

---

## Summary

✅ **Nuvei Technologies processor is fully mapped and ready**  
✅ **Database schema expanded to support all Nuvei fields**  
✅ **Supabase helpers updated for new related tables**  
🚧 **Next:** Build the multi-step profile form to collect all merchant data

The infrastructure is complete. Once the profile form is built, merchants can complete their profiles and auto-fill Nuvei applications with one click. 🚀
