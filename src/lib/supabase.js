import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables. Please check your .env file.');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

/**
 * Auth helpers
 */
export const auth = {
  signUp: async (email, password) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    return { data, error };
  },

  signIn: async (email, password) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { data, error };
  },

  signOut: async () => {
    const { error } = await supabase.auth.signOut();
    return { error };
  },

  getSession: async () => {
    const { data: { session }, error } = await supabase.auth.getSession();
    return { session, error };
  },

  getUser: async () => {
    const { data: { user }, error } = await supabase.auth.getUser();
    return { user, error };
  },

  onAuthStateChange: (callback) => {
    return supabase.auth.onAuthStateChange(callback);
  }
};

/**
 * Database helpers
 */
export const db = {
  // Merchants
  getMerchant: async (userId) => {
    const { data, error } = await supabase
      .from('merchants')
      .select('*')
      .eq('user_id', userId)
      .single();
    return { data, error };
  },

  createMerchant: async (merchantData) => {
    const { data, error } = await supabase
      .from('merchants')
      .insert([merchantData])
      .select()
      .single();
    return { data, error };
  },

  updateMerchant: async (merchantId, updates) => {
    const { data, error } = await supabase
      .from('merchants')
      .update(updates)
      .eq('id', merchantId)
      .select()
      .single();
    return { data, error };
  },

  // Processors
  getProcessors: async () => {
    const { data, error } = await supabase
      .from('processors')
      .select('*')
      .eq('active', true);
    return { data, error };
  },

  getProcessor: async (processorId) => {
    const { data, error } = await supabase
      .from('processors')
      .select('*')
      .eq('id', processorId)
      .single();
    return { data, error };
  },

  // Applications
  getApplications: async (merchantId) => {
    const { data, error } = await supabase
      .from('merchant_applications')
      .select(`
        *,
        processor:processors(*)
      `)
      .eq('merchant_id', merchantId);
    return { data, error };
  },

  getApplication: async (applicationId) => {
    const { data, error } = await supabase
      .from('merchant_applications')
      .select(`
        *,
        processor:processors(*),
        merchant:merchants(*)
      `)
      .eq('id', applicationId)
      .single();
    return { data, error };
  },

  createApplication: async (applicationData) => {
    const { data, error } = await supabase
      .from('merchant_applications')
      .insert([applicationData])
      .select()
      .single();
    return { data, error };
  },

  updateApplication: async (applicationId, updates) => {
    const { data, error } = await supabase
      .from('merchant_applications')
      .update(updates)
      .eq('id', applicationId)
      .select()
      .single();
    return { data, error };
  },

  // Documents
  getDocuments: async (merchantId) => {
    const { data, error } = await supabase
      .from('merchant_documents')
      .select('*')
      .eq('merchant_id', merchantId);
    return { data, error };
  },

  uploadDocument: async (merchantId, documentData) => {
    const { data, error } = await supabase
      .from('merchant_documents')
      .insert([{ merchant_id: merchantId, ...documentData }])
      .select()
      .single();
    return { data, error };
  },

  // Status History
  getStatusHistory: async (merchantId) => {
    const { data, error } = await supabase
      .from('status_history')
      .select('*')
      .eq('merchant_id', merchantId)
      .order('created_at', { ascending: false });
    return { data, error };
  },

  addStatusHistory: async (historyData) => {
    const { data, error } = await supabase
      .from('status_history')
      .insert([historyData])
      .select()
      .single();
    return { data, error };
  },

  // High-Risk Industries
  getHighRiskIndustries: async () => {
    const { data, error } = await supabase
      .from('high_risk_industries')
      .select('*')
      .eq('active', true);
    return { data, error };
  },

  // Merchant Owners
  getOwners: async (merchantId) => {
    const { data, error } = await supabase
      .from('merchant_owners')
      .select('*')
      .eq('merchant_id', merchantId)
      .order('owner_number', { ascending: true });
    return { data, error };
  },

  upsertOwner: async (merchantId, ownerNumber, ownerData) => {
    const { data, error } = await supabase
      .from('merchant_owners')
      .upsert([{
        merchant_id: merchantId,
        owner_number: ownerNumber,
        ...ownerData
      }], {
        onConflict: 'merchant_id,owner_number'
      })
      .select()
      .single();
    return { data, error };
  },

  // Bank Accounts
  getBankAccounts: async (merchantId) => {
    const { data, error } = await supabase
      .from('merchant_bank_accounts')
      .select('*')
      .eq('merchant_id', merchantId);
    return { data, error };
  },

  upsertBankAccount: async (merchantId, accountType, accountData) => {
    // First check if account exists
    const { data: existing } = await supabase
      .from('merchant_bank_accounts')
      .select('id')
      .eq('merchant_id', merchantId)
      .eq('account_type', accountType)
      .single();

    if (existing) {
      // Update existing
      const { data, error } = await supabase
        .from('merchant_bank_accounts')
        .update(accountData)
        .eq('id', existing.id)
        .select()
        .single();
      return { data, error };
    } else {
      // Insert new
      const { data, error } = await supabase
        .from('merchant_bank_accounts')
        .insert([{
          merchant_id: merchantId,
          account_type: accountType,
          ...accountData
        }])
        .select()
        .single();
      return { data, error };
    }
  },

  // Equipment
  getEquipment: async (merchantId) => {
    const { data, error } = await supabase
      .from('merchant_equipment')
      .select('*')
      .eq('merchant_id', merchantId)
      .single();
    return { data, error };
  },

  upsertEquipment: async (merchantId, equipmentData) => {
    // Check if equipment record exists
    const { data: existing } = await supabase
      .from('merchant_equipment')
      .select('id')
      .eq('merchant_id', merchantId)
      .single();

    if (existing) {
      // Update existing
      const { data, error } = await supabase
        .from('merchant_equipment')
        .update(equipmentData)
        .eq('id', existing.id)
        .select()
        .single();
      return { data, error };
    } else {
      // Insert new
      const { data, error } = await supabase
        .from('merchant_equipment')
        .insert([{
          merchant_id: merchantId,
          ...equipmentData
        }])
        .select()
        .single();
      return { data, error };
    }
  },

  // Control Panel Access
  getControlPanelAccess: async (merchantId, processorId = null) => {
    let query = supabase
      .from('merchant_control_panel_access')
      .select('*')
      .eq('merchant_id', merchantId);
    
    if (processorId) {
      query = query.eq('processor_id', processorId);
    }

    const { data, error } = await query.single();
    return { data, error };
  },

  upsertControlPanelAccess: async (merchantId, processorId, accessData) => {
    // Check if record exists
    const { data: existing } = await supabase
      .from('merchant_control_panel_access')
      .select('id')
      .eq('merchant_id', merchantId)
      .eq('processor_id', processorId)
      .single();

    if (existing) {
      // Update existing
      const { data, error } = await supabase
        .from('merchant_control_panel_access')
        .update(accessData)
        .eq('id', existing.id)
        .select()
        .single();
      return { data, error };
    } else {
      // Insert new
      const { data, error } = await supabase
        .from('merchant_control_panel_access')
        .insert([{
          merchant_id: merchantId,
          processor_id: processorId,
          ...accessData
        }])
        .select()
        .single();
      return { data, error };
    }
  }
};

/**
 * Storage helpers
 */
export const storage = {
  uploadFile: async (bucket, path, file) => {
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(path, file, {
        cacheControl: '3600',
        upsert: false
      });
    return { data, error };
  },

  getPublicUrl: (bucket, path) => {
    const { data } = supabase.storage
      .from(bucket)
      .getPublicUrl(path);
    return data.publicUrl;
  },

  deleteFile: async (bucket, path) => {
    const { data, error } = await supabase.storage
      .from(bucket)
      .remove([path]);
    return { data, error };
  }
};
