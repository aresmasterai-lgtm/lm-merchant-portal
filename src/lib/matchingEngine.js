/**
 * LM Merchant Portal - Processor Matching Engine
 * 
 * Rule-based matching engine that scores processors against merchant profiles.
 * Returns ranked list of processors with match scores (0-100).
 * 
 * Matching Variables:
 * 1. Industry (must be supported)
 * 2. Monthly Volume (must fall within range)
 * 3. Card Present/CNP (must match transaction type)
 * 4. High-Risk Flag (processor must accept if merchant is high-risk)
 * 5. Business Age (processor must accept new businesses if < 3 months)
 */

/**
 * Calculate match score for a single processor against a merchant profile
 * @param {Object} merchant - Merchant profile object
 * @param {Object} processor - Processor object
 * @returns {Object} { processor, score, reasons }
 */
export function calculateMatchScore(merchant, processor) {
  let score = 0;
  const reasons = [];
  const penalties = [];

  // HARD REQUIREMENT 1: Industry Support
  if (!processor.industries_supported.includes(merchant.industry)) {
    return {
      processor,
      score: 0,
      match: false,
      reasons: [`Processor does not support ${merchant.industry} industry`]
    };
  }
  score += 25;
  reasons.push(`Supports ${merchant.industry} industry`);

  // HARD REQUIREMENT 2: Monthly Volume Range
  const volume = parseFloat(merchant.monthly_volume);
  const minVolume = parseFloat(processor.min_monthly_volume) || 0;
  const maxVolume = processor.max_monthly_volume ? parseFloat(processor.max_monthly_volume) : Infinity;

  if (volume < minVolume || volume > maxVolume) {
    return {
      processor,
      score: 0,
      match: false,
      reasons: [`Volume $${volume.toLocaleString()} outside processor range ($${minVolume.toLocaleString()} - ${maxVolume === Infinity ? 'unlimited' : '$' + maxVolume.toLocaleString()})`]
    };
  }
  score += 25;
  reasons.push(`Volume within acceptable range`);

  // HARD REQUIREMENT 3: Card Present/CNP
  if (merchant.card_present && !processor.card_present) {
    return {
      processor,
      score: 0,
      match: false,
      reasons: ['Processor does not support card-present transactions']
    };
  }
  if (!merchant.card_present && !processor.card_not_present) {
    return {
      processor,
      score: 0,
      match: false,
      reasons: ['Processor does not support card-not-present transactions']
    };
  }
  score += 20;
  reasons.push(merchant.card_present ? 'Supports card-present' : 'Supports card-not-present');

  // HARD REQUIREMENT 4: High-Risk Flag
  if (merchant.high_risk && !processor.accepts_high_risk) {
    return {
      processor,
      score: 0,
      match: false,
      reasons: ['Processor does not accept high-risk merchants']
    };
  }
  if (merchant.high_risk && processor.accepts_high_risk) {
    score += 15;
    reasons.push('Accepts high-risk merchants');
  } else if (!merchant.high_risk) {
    score += 15;
    reasons.push('Standard risk profile accepted');
  }

  // HARD REQUIREMENT 5: Business Age
  const monthsInBusiness = parseInt(merchant.months_in_business);
  if (monthsInBusiness < 3 && !processor.accepts_new_business) {
    return {
      processor,
      score: 0,
      match: false,
      reasons: ['Processor does not accept new businesses (< 3 months)']
    };
  }
  if (monthsInBusiness < 3 && processor.accepts_new_business) {
    score += 15;
    reasons.push('Accepts new businesses');
  } else if (monthsInBusiness >= 3) {
    score += 15;
    reasons.push('Established business accepted');
  }

  // BONUS: Optimal volume range (closer to midpoint = better)
  if (maxVolume !== Infinity) {
    const midpoint = (minVolume + maxVolume) / 2;
    const distanceFromMidpoint = Math.abs(volume - midpoint);
    const rangeSize = maxVolume - minVolume;
    const proximityScore = Math.max(0, 10 - (distanceFromMidpoint / rangeSize) * 10);
    score += proximityScore;
    if (proximityScore > 5) {
      reasons.push('Optimal volume for this processor');
    }
  }

  return {
    processor,
    score: Math.round(score),
    match: score > 0,
    reasons,
    penalties
  };
}

/**
 * Match a merchant against all active processors
 * @param {Object} merchant - Merchant profile object
 * @param {Array} processors - Array of all processor objects
 * @returns {Array} Sorted array of match results (highest score first)
 */
export function matchMerchantToProcessors(merchant, processors) {
  // Filter to active processors only
  const activeProcessors = processors.filter(p => p.active);

  // Calculate match score for each processor
  const matches = activeProcessors.map(processor => 
    calculateMatchScore(merchant, processor)
  );

  // Filter out non-matches (score = 0)
  const validMatches = matches.filter(m => m.match);

  // Sort by score (highest first)
  validMatches.sort((a, b) => b.score - a.score);

  return validMatches;
}

/**
 * Check if an industry is high-risk
 * @param {string} industryCode - Industry code to check
 * @param {Array} highRiskIndustries - Array of high-risk industry objects
 * @returns {boolean}
 */
export function isHighRiskIndustry(industryCode, highRiskIndustries) {
  return highRiskIndustries.some(
    hr => hr.industry_code === industryCode && hr.active
  );
}

/**
 * Get document requirements based on business age
 * @param {number} monthsInBusiness - Merchant's months in business
 * @returns {Object} { isNewBusiness, requiredDocuments }
 */
export function getDocumentRequirements(monthsInBusiness) {
  const isNewBusiness = monthsInBusiness < 3;

  if (isNewBusiness) {
    return {
      isNewBusiness: true,
      requiredDocuments: [
        {
          type: 'bank_statement',
          label: '3 Most Recent Bank Statements',
          description: 'Required for new businesses (< 3 months)',
          count: 3
        },
        {
          type: 'voided_check',
          label: 'Voided Check',
          description: 'For bank deposit setup',
          count: 1
        },
        {
          type: 'government_id',
          label: 'Government-Issued Photo ID',
          description: 'Driver\'s license or passport',
          count: 1
        },
        {
          type: 'business_license',
          label: 'Business License or Formation Documents',
          description: 'Articles of incorporation, LLC formation, etc.',
          count: 1
        }
      ]
    };
  }

  return {
    isNewBusiness: false,
    requiredDocuments: [
      {
        type: 'processing_statement',
        label: '3 Most Recent Processing Statements',
        description: 'From your current payment processor',
        count: 3
      },
      {
        type: 'voided_check',
        label: 'Voided Check',
        description: 'For bank deposit setup',
        count: 1
      },
      {
        type: 'government_id',
        label: 'Government-Issued Photo ID',
        description: 'Driver\'s license or passport',
        count: 1
      },
      {
        type: 'business_license',
        label: 'Business License',
        description: 'If applicable',
        count: 1,
        optional: true
      }
    ]
  };
}

/**
 * Validate merchant profile completeness
 * @param {Object} merchant - Merchant profile object
 * @returns {Object} { isValid, missingFields }
 */
export function validateMerchantProfile(merchant) {
  const requiredFields = [
    'business_name',
    'industry',
    'business_type',
    'monthly_volume',
    'avg_ticket',
    'months_in_business'
  ];

  const missingFields = requiredFields.filter(field => {
    const value = merchant[field];
    return value === null || value === undefined || value === '';
  });

  return {
    isValid: missingFields.length === 0,
    missingFields
  };
}

/**
 * Get human-readable status label
 * @param {string} statusCode - Status code from database
 * @returns {string} Human-readable status label
 */
export function getStatusLabel(statusCode) {
  const statusMap = {
    'profile_complete': 'Profile Complete',
    'matched': 'Processor Matched',
    'docs_uploaded': 'Documents Uploaded',
    'app_sent': 'Application Sent for Signature',
    'app_signed': 'Application Signed',
    'submitted': 'Submitted to Processor',
    'approved': 'Approved',
    'declined': 'Declined'
  };

  return statusMap[statusCode] || statusCode;
}

/**
 * Get next action for merchant based on current status
 * @param {string} statusCode - Current status code
 * @param {Object} merchant - Merchant profile object
 * @returns {Object} { action, message, ctaLabel, ctaLink }
 */
export function getNextAction(statusCode, merchant) {
  const actions = {
    'profile_complete': {
      action: 'match_processor',
      message: 'Complete your profile to get matched with the right payment processor.',
      ctaLabel: 'View Matches',
      ctaLink: '/matches'
    },
    'matched': {
      action: 'upload_documents',
      message: 'Upload required documents to continue your application.',
      ctaLabel: 'Upload Documents',
      ctaLink: '/documents'
    },
    'docs_uploaded': {
      action: 'review_application',
      message: 'Review and sign your pre-filled application.',
      ctaLabel: 'Review Application',
      ctaLink: '/applications'
    },
    'app_sent': {
      action: 'sign_application',
      message: 'Sign your application to complete the process.',
      ctaLabel: 'Sign Now',
      ctaLink: '/applications'
    },
    'app_signed': {
      action: 'wait_submission',
      message: 'Your application has been signed and is being submitted to the processor.',
      ctaLabel: 'View Status',
      ctaLink: '/status'
    },
    'submitted': {
      action: 'wait_approval',
      message: 'Your application is under review by the processor.',
      ctaLabel: 'View Status',
      ctaLink: '/status'
    },
    'approved': {
      action: 'complete',
      message: 'Congratulations! Your application has been approved.',
      ctaLabel: 'View Details',
      ctaLink: '/applications'
    },
    'declined': {
      action: 'retry',
      message: 'Your application was declined. We can help you find alternative processors.',
      ctaLabel: 'Find Alternatives',
      ctaLink: '/matches'
    }
  };

  return actions[statusCode] || {
    action: 'unknown',
    message: 'Contact support for assistance.',
    ctaLabel: 'Contact Support',
    ctaLink: '/support'
  };
}
