/**
 * LM Merchant Portal - Application Schema Helpers
 * 
 * Functions for working with processor application schemas.
 * Schemas are stored as JSONB in the processors table and define
 * how to auto-fill processor applications from merchant profile data.
 */

/**
 * Validate an application schema structure
 * @param {Object} schema - Application schema object
 * @returns {Object} { isValid, errors }
 */
export function validateApplicationSchema(schema) {
  const errors = [];

  if (!schema) {
    return { isValid: false, errors: ['Schema is required'] };
  }

  if (typeof schema !== 'object') {
    return { isValid: false, errors: ['Schema must be an object'] };
  }

  // Check required top-level fields
  if (!schema.version) {
    errors.push('Schema must have a version field');
  }

  if (!schema.fields || !Array.isArray(schema.fields)) {
    errors.push('Schema must have a fields array');
    return { isValid: false, errors };
  }

  // Validate each field
  schema.fields.forEach((field, index) => {
    if (!field.processor_field) {
      errors.push(`Field ${index}: Missing processor_field`);
    }
    if (!field.lm_field) {
      errors.push(`Field ${index}: Missing lm_field`);
    }
    if (!field.field_type) {
      errors.push(`Field ${index}: Missing field_type`);
    }
    if (field.required === undefined) {
      errors.push(`Field ${index}: Missing required flag`);
    }

    // Validate field_type
    const validTypes = ['text', 'number', 'boolean', 'date', 'email', 'phone', 'select', 'textarea'];
    if (field.field_type && !validTypes.includes(field.field_type)) {
      errors.push(`Field ${index}: Invalid field_type "${field.field_type}". Must be one of: ${validTypes.join(', ')}`);
    }
  });

  return {
    isValid: errors.length === 0,
    errors
  };
}

/**
 * Extract value from merchant profile using dot notation
 * @param {Object} merchant - Merchant profile object
 * @param {string} path - Dot-notation path (e.g., "merchants.business_name")
 * @returns {any} Value at that path, or null if not found
 */
export function getValueFromPath(merchant, path) {
  // Remove 'merchants.' prefix if present
  const cleanPath = path.replace(/^merchants\./, '');
  
  // Split path and traverse object
  const parts = cleanPath.split('.');
  let value = merchant;
  
  for (const part of parts) {
    if (value === null || value === undefined) {
      return null;
    }
    value = value[part];
  }
  
  return value ?? null;
}

/**
 * Auto-fill a processor application using merchant data and schema
 * @param {Object} merchant - Merchant profile object
 * @param {Object} schema - Processor application schema
 * @returns {Object} Filled application data
 */
export function autoFillApplication(merchant, schema) {
  const validation = validateApplicationSchema(schema);
  if (!validation.isValid) {
    throw new Error(`Invalid schema: ${validation.errors.join(', ')}`);
  }

  const filledData = {};

  schema.fields.forEach(field => {
    const value = getValueFromPath(merchant, field.lm_field);
    
    // Format value based on field_type and format
    let formattedValue = value;

    if (value !== null && value !== undefined) {
      switch (field.field_type) {
        case 'number':
          formattedValue = Number(value);
          if (field.format === 'currency') {
            formattedValue = `$${formattedValue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
          }
          break;
        
        case 'boolean':
          formattedValue = value ? 'Yes' : 'No';
          break;
        
        case 'date':
          if (value instanceof Date) {
            formattedValue = value.toISOString().split('T')[0];
          }
          break;
        
        case 'phone':
          // Format phone number if it's just digits
          if (typeof value === 'string' && /^\d{10}$/.test(value)) {
            formattedValue = `(${value.slice(0, 3)}) ${value.slice(3, 6)}-${value.slice(6)}`;
          }
          break;
      }
    }

    filledData[field.processor_field] = formattedValue;
  });

  return filledData;
}

/**
 * Check if all required fields in a schema have values in merchant profile
 * @param {Object} merchant - Merchant profile object
 * @param {Object} schema - Processor application schema
 * @returns {Object} { isComplete, missingFields }
 */
export function checkSchemaCompletion(merchant, schema) {
  const validation = validateApplicationSchema(schema);
  if (!validation.isValid) {
    return { isComplete: false, missingFields: validation.errors };
  }

  const missingFields = [];

  schema.fields.forEach(field => {
    if (field.required) {
      const value = getValueFromPath(merchant, field.lm_field);
      if (value === null || value === undefined || value === '') {
        missingFields.push({
          processor_field: field.processor_field,
          lm_field: field.lm_field
        });
      }
    }
  });

  return {
    isComplete: missingFields.length === 0,
    missingFields
  };
}

/**
 * Get a blank application schema template
 * @returns {Object} Empty schema structure
 */
export function getBlankSchema() {
  return {
    version: "1.0",
    fields: []
  };
}

/**
 * Add a field to an application schema
 * @param {Object} schema - Application schema
 * @param {Object} field - Field definition
 * @returns {Object} Updated schema
 */
export function addFieldToSchema(schema, field) {
  const updatedSchema = { ...schema };
  if (!updatedSchema.fields) {
    updatedSchema.fields = [];
  }
  
  updatedSchema.fields.push({
    processor_field: field.processor_field || '',
    lm_field: field.lm_field || '',
    field_type: field.field_type || 'text',
    required: field.required ?? false,
    max_length: field.max_length || null,
    format: field.format || null
  });
  
  return updatedSchema;
}

/**
 * Remove a field from an application schema by index
 * @param {Object} schema - Application schema
 * @param {number} index - Field index to remove
 * @returns {Object} Updated schema
 */
export function removeFieldFromSchema(schema, index) {
  const updatedSchema = { ...schema };
  if (updatedSchema.fields && Array.isArray(updatedSchema.fields)) {
    updatedSchema.fields = updatedSchema.fields.filter((_, i) => i !== index);
  }
  return updatedSchema;
}

/**
 * Get available merchant fields for schema mapping
 * @returns {Array} List of available fields with descriptions
 */
export function getAvailableMerchantFields() {
  return [
    { value: 'merchants.business_name', label: 'Business Legal Name', type: 'text' },
    { value: 'merchants.dba_name', label: 'DBA Name', type: 'text' },
    { value: 'merchants.industry', label: 'Industry', type: 'text' },
    { value: 'merchants.business_type', label: 'Business Type', type: 'text' },
    { value: 'merchants.monthly_volume', label: 'Monthly Volume', type: 'number' },
    { value: 'merchants.avg_ticket', label: 'Average Ticket Size', type: 'number' },
    { value: 'merchants.card_present', label: 'Card Present', type: 'boolean' },
    { value: 'merchants.months_in_business', label: 'Months in Business', type: 'number' },
    { value: 'merchants.current_processor', label: 'Current Processor', type: 'text' },
    // Add more fields as the merchant profile expands
  ];
}

/**
 * Get available field types
 * @returns {Array} List of supported field types
 */
export function getAvailableFieldTypes() {
  return [
    { value: 'text', label: 'Text' },
    { value: 'number', label: 'Number' },
    { value: 'boolean', label: 'Yes/No' },
    { value: 'date', label: 'Date' },
    { value: 'email', label: 'Email' },
    { value: 'phone', label: 'Phone' },
    { value: 'select', label: 'Dropdown' },
    { value: 'textarea', label: 'Long Text' }
  ];
}

/**
 * Get available format options for number fields
 * @returns {Array} List of supported number formats
 */
export function getAvailableNumberFormats() {
  return [
    { value: null, label: 'None' },
    { value: 'currency', label: 'Currency ($)' },
    { value: 'percentage', label: 'Percentage (%)' },
    { value: 'phone', label: 'Phone Number' },
    { value: 'ssn', label: 'SSN' },
    { value: 'ein', label: 'EIN' }
  ];
}
