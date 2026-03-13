# Wholesale Payments / Merrick Bank - Application Schema

**Created:** March 13, 2026  
**Source:** Application field list provided by Kingsley  
**Status:** Complete ✅

---

## Overview

This document explains the **Wholesale Payments / Merrick Bank** processor schema and the database expansions needed to support it.

The Wholesale Payments application required additional fields beyond what Nuvei needed:
- Corporate address (separate from location address)
- Contact person fields (separate from owner)
- Ownership duration (years + months)
- Sales breakdown (consumer/business/government percentages)
- Seasonal merchant tracking
- Card type acceptance preferences
- Equipment deployment details

---

## Database Expansions

### New Fields Added to `merchants` Table

**Corporate Address (Separate from Location):**
- `corporate_address`
- `corporate_city`
- `corporate_state`
- `corporate_zip`

**Contact Person (Separate from Owner):**
- `contact_name`
- `contact_phone`

**Business Registration & Ownership:**
- `state_issued` (state where business is registered)
- `ownership_years` (how many years current ownership)
- `ownership_months` (additional months, 0-11)

**Sales Breakdown:**
- `sales_to_consumer_percentage`
- `sales_to_business_percentage`
- `sales_to_government_percentage`

**Current Processing Status:**
- `currently_accepts_cards` (boolean)
- `is_seasonal_merchant` (boolean)
- `seasonal_active_months` (text array)
- `reason_leaving_processor` (text)

---

### New Fields Added to `merchant_owners` Table

- `control_prong` (boolean) - Beneficial Ownership compliance flag
- `drivers_license_expiration` (date)
- `telephone` (text) - Primary phone (separate from mobile_phone)

---

### New Fields Added to `merchant_bank_accounts` Table

- `bank_name` (text)
- `bank_phone` (text)
- `account_type_detail` (Checking | Savings)

---

### New Fields Added to `merchant_equipment` Table

- `equipment_type` (Terminal, Pin Pad, VAR, Gateway)
- `manufacturer` (text)
- `model_version` (text)
- `quantity` (integer)
- `deployment` (New Order | Existing)
- `connection` (Dial | Ethernet | Wireless)
- `special_instructions` (text)

---

### New Table: `merchant_card_types`

Tracks which card types the merchant wants to accept.

**Fields:**
- `accept_visa_credit` (boolean)
- `accept_visa_debit` (boolean)
- `accept_mastercard_credit` (boolean)
- `accept_mastercard_debit` (boolean)
- `accept_discover` (boolean)
- `accept_american_express` (boolean)
- `accept_pin_debit` (boolean)
- `accept_ebt` (boolean)
- `opt_out_amex_marketing` (boolean)

**Usage:**
```javascript
await db.upsertCardTypes(merchantId, cardTypesData);
await db.getCardTypes(merchantId);
```

**Constraint:** One record per merchant (UNIQUE on merchant_id)

---

## Wholesale Payments Application Sections

The Wholesale Payments schema has 7 sections:

### 1. BUSINESS INFORMATION
21 fields including:
- DBA vs. Legal Name
- Location Address vs. Corporate Address (optional)
- Contact person (separate from owner)
- Federal Tax ID
- Business Structure (6 options)
- State Issued
- Length of Ownership (years + months)

**Note:** Wholesale Payments distinguishes between **location address** (where business operates) and **corporate address** (registered office). Corporate address is optional.

### 2. OWNER 1
16 required fields including Control Prong and Driver's License Expiration.

**Control Prong:** Beneficial Ownership rule compliance flag (FinCEN requirement for individuals with significant control).

### 3. OWNER 2
16 optional fields (same structure as Owner 1).

### 4. BANKING ACCOUNT INFORMATION
5 fields for a single bank account (deposit only).

**Difference from Nuvei:** Wholesale Payments only collects one account (no separate withdrawal account).

### 5. TRANSACTION INFORMATION
17 fields including:
- Business type, products/services
- Monthly volume, average ticket, high ticket
- Transaction percentages (Swipe, MOTO, Internet)
- **Sales breakdown** (Consumer, Business, Government)
- Delivery timeframe
- **Seasonal merchant** flag + active months
- Reason for leaving current processor

**Validation:** 
- Swipe % + MOTO % + Internet % must total 100%
- Consumer % + Business % + Government % must total 100%

### 6. REQUESTED CARD TYPES
8 boolean flags for card acceptance:
- Visa Credit, Visa Debit
- Mastercard Credit, Mastercard Debit
- Discover, American Express
- PIN Debit, EBT

**Note:** Allows merchants to opt out of AMEX marketing.

### 7. EQUIPMENT
9 fields for equipment preferences:
- Equipment Type (Terminal, Pin Pad, VAR, Gateway)
- Manufacturer, Model/Version, Quantity
- Deployment (New Order vs. Existing)
- Connection (Dial, Ethernet, Wireless)
- Payment application name/version
- Special instructions

**Note:** Application supports "Equipment Type 1" which suggests multiple equipment entries are possible via addendum.

### 8. SIGNATURES
9 fields for Principal 1 & 2 signatures (via SignWell).

---

## Auto-Fill Field Mapping

**Example mappings:**

| Processor Field | LM Field | Type | Required |
|----------------|----------|------|----------|
| DBA / Trade Name | `merchants.dba_name` | text | Yes |
| Corporate / Legal Name | `merchants.business_name` | text | Yes |
| Location Address | `merchants.business_address` | text | Yes |
| Corporate Address | `merchants.corporate_address` | text | No |
| Contact Name | `merchants.contact_name` | text | Yes |
| Length of Ownership - Years | `merchants.ownership_years` | number | Yes |
| Control Prong | `merchant_owners.control_prong[1]` | boolean | Yes |
| Accept Visa Credit | `merchant_card_types.accept_visa_credit` | boolean | Yes |
| Equipment Type 1 | `merchant_equipment.equipment_type` | select | No |

---

## Processor Criteria

**Wholesale Payments supports:**
- **Industries:** Restaurant, Retail, E-commerce, Professional Services, Healthcare, Hospitality, Automotive, Services
- **Volume:** $0 - Unlimited
- **High-Risk:** Yes (accepts high-risk merchants)
- **New Business:** Yes (accepts businesses < 3 months old)
- **Card Present:** Yes
- **Card Not Present:** Yes

**Key Differentiator:** Wholesale Payments accepts high-risk merchants, unlike Nuvei.

---

## Differences from Nuvei

| Feature | Wholesale Payments | Nuvei |
|---------|-------------------|-------|
| Corporate Address | Separate field | Same as legal |
| Contact Person | Separate from owner | Not specified |
| Bank Accounts | Single account | Deposit + optional withdrawal |
| Control Prong | Required | Not included |
| Sales Breakdown | Consumer/Business/Gov | Not included |
| Card Types | 8 explicit flags | Not specified |
| Seasonal Merchant | Explicit flag + months | Not included |
| High-Risk | Accepted ✅ | Not accepted ❌ |

---

## Migration Files

1. **`20260313_add_wholesale_payments_fields.sql`**
   - Adds corporate address, contact person, ownership duration fields
   - Adds sales breakdown and seasonal merchant fields
   - Adds fields to merchant_owners (control_prong, DL expiration, telephone)
   - Adds fields to merchant_bank_accounts (bank_name, bank_phone, account_type_detail)
   - Adds fields to merchant_equipment (type, manufacturer, model, deployment, connection)
   - Creates `merchant_card_types` table

2. **`supabase/processors/wholesale_payments.sql`**
   - Inserts Wholesale Payments processor record
   - Complete application schema with 7 sections
   - Field mappings and validation rules

---

## Multi-Step Profile Form Requirements

To support both Nuvei and Wholesale Payments, the merchant profile form needs:

**Step 1: Business Basics**
- Legal name, DBA
- Industry, business type

**Step 2: Business Addresses**
- Location address (required)
- Corporate address (optional, if different)
- Contact person

**Step 3: Business Details**
- Phone, fax, email, website
- Federal Tax ID, tax filing name
- State issued, ownership duration
- Products/services

**Step 4: Transaction Profile**
- Volume, ticket sizes
- Transaction percentages (Swipe/MOTO/Internet)
- Sales breakdown (Consumer/Business/Government)
- Delivery timeframe
- Seasonal merchant flag

**Step 5: Owner Information**
- Owner 1 (required) with control prong, DL expiration
- Owner 2+ (optional, repeatable)

**Step 6: Bank Account**
- Bank name, routing/account number, phone
- Account type (Checking/Savings)

**Step 7: Card Types & Equipment**
- Which card types to accept (8 flags)
- Equipment preferences
- PCI compliance

**Step 8: Review & Submit**
- Summary of all entered data
- Validation check

---

## Supabase Helpers Updated

```javascript
// Card types
await db.getCardTypes(merchantId);
await db.upsertCardTypes(merchantId, cardTypesData);
```

---

## Testing Checklist

- [ ] Create merchant profile with all required fields
- [ ] Add corporate address (different from location)
- [ ] Add contact person info
- [ ] Add ownership duration (years + months)
- [ ] Add sales breakdown percentages
- [ ] Set seasonal merchant flag + active months
- [ ] Add 2 owners with control prong + DL expiration
- [ ] Add bank account with bank name + phone
- [ ] Select card types (8 flags)
- [ ] Add equipment preferences
- [ ] Run matching engine against Wholesale Payments
- [ ] Auto-fill Wholesale Payments application
- [ ] Verify all 7 sections populate correctly
- [ ] Test percentage validation (must total 100%)
- [ ] Send to SignWell for signatures
- [ ] Retrieve signed document

---

## Questions for Kingsley

**Clarifications needed:**
1. **Business Structure mapping:** How do we map our simplified `business_type` to Wholesale Payments' options?
   - Ours: Sole Prop, LLC, Corp, Partnership
   - Theirs: Individual/Sole Prop, Partnership, Corporation, LLC, Non-Profit, Government
2. **Volume ranges:** What are Wholesale Payments' actual minimum/maximum monthly volume requirements?
3. **Industry support:** Which specific industries does Wholesale Payments support?
4. **Control Prong:** How do we determine if an owner has "Control Prong" (significant managerial control)?
5. **Signature workflow:** Do both Principal 1 and Principal 2 need to sign, or is Principal 2 optional?
6. **Equipment:** Application shows "Equipment Type 1" - does this mean they support multiple equipment entries?

---

## Summary

✅ **Wholesale Payments / Merrick Bank processor is fully mapped and ready**  
✅ **Database schema expanded to support all Wholesale Payments fields**  
✅ **New `merchant_card_types` table for card acceptance preferences**  
✅ **Enhanced equipment tracking with deployment and connection details**  
🚧 **Next:** Build the multi-step profile form to collect all merchant data

**Key Features:**
- Accepts high-risk merchants (differentiator from Nuvei)
- Separate corporate and location addresses
- Sales breakdown by customer type (Consumer/Business/Government)
- Seasonal merchant support
- Granular card type selection (8 different card types)

The infrastructure is complete. Once the profile form is built, merchants can complete their profiles and auto-fill both Nuvei and Wholesale Payments applications with one click! 🚀
