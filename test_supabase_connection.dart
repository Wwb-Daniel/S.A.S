import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    await Supabase.initialize(
      url: 'https://yfnycmaksvrodshfpbpe.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmbnljbWFrc3Zyb2RzaGZwYnBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MDQ2NzQsImV4cCI6MjA3ODM4MDY3NH0.1QZJt_ygYaWbgk6X39gDQ75p3vgb72CXpfxk_zI023U',
    );

    final response = await Supabase.instance.client
        .from('companies')
        .select();

    print('Conexión exitosa!');
    print('Datos: $response');
  } catch (e) {
    print('Error al conectar con Supabase: $e');
  }
}
