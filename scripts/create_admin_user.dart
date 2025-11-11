import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializa Supabase con tu configuración
  await Supabase.initialize(
    url: 'https://yfnycmaksvrodshfpbpe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmbnljbWFrc3Zyb2RzaGZwYnBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MDQ2NzQsImV4cCI6MjA3ODM4MDY3NH0.1QZJt_ygYaWbgk6X39gDQ75p3vgb72CXpfxk_zI023U',
  );

  final supabase = Supabase.instance.client;
  
  try {
    // Datos del administrador
    final email = 'admin@ejemplo.com';
    final password = 'Admin123!';
    final fullName = 'Administrador Principal';
    final phone = '+1234567890';
    final companyName = 'Mi Empresa';
    final companyRuc = '12345678901';
    final companyAddress = 'Dirección de la empresa';

    print('🔵 Creando usuario administrador...');
    
    // 1. Crear la empresa
    print('🔄 Creando empresa...');
    final companyResponse = await supabase
        .from('companies')
        .insert({
          'name': companyName,
          'ruc': companyRuc,
          'email': email,
          'phone': phone,
          'address': companyAddress,
        })
        .select()
        .single();

    print('✅ Empresa creada con ID: ${companyResponse['id']}');

    // 2. Registrar el usuario en Supabase Auth
    print('🔄 Registrando usuario en Supabase Auth...');
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'company_admin',
      },
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('No se pudo crear el usuario en Supabase Auth');
    }

    print('✅ Usuario registrado con ID: ${user.id}');

    // 3. Crear el registro en la tabla employees
    print('🔄 Creando perfil de empleado...');
    await supabase.from('employees').insert({
      'id': user.id,
      'email': email,
      'full_name': fullName,
      'company_id': companyResponse['id'],
      'role': 'company_admin',
      'position': 'Administrador',
      'phone': phone,
      'status': 'active',
    });

    print('✅ Perfil de empleado creado exitosamente');
    print('\n🎉 ¡Usuario administrador creado exitosamente!');
    print('📧 Email: $email');
    print('🔑 Contraseña: $password');
    print('🏢 Empresa: $companyName (${companyResponse['id']})');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Cerrar la conexión
    await Supabase.instance.dispose();
  }
}
