import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://yfnycmaksvrodshfpbpe.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmbnljbWFrc3Zyb2RzaGZwYnBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MDQ2NzQsImV4cCI6MjA3ODM4MDY3NH0.1QZJt_ygYaWbgk6X39gDQ75p3vgb72CXpfxk_zI023U';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static GoTrueClient get auth => client.auth;
  
  static SupabaseStorageClient get storage => client.storage;
}
