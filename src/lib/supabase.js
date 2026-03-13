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
