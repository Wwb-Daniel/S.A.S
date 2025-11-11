import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../utils/countries_es.dart';
import '../widgets/liquid_gradient_background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _companyNameCtrl = TextEditingController();
  final _companyRucCtrl = TextEditingController();
  final _companyAddressCtrl = TextEditingController();

  int _step = 0; // 0: datos personales, 1: datos empresa
  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _selectedCountry;
  String _selectedLanguage = 'es';
  String? _error;
  String? _companyLogoUrl;
  Uint8List? _companyLogoPreview;
  bool _showPassword = false;
  bool _showConfirm = false;
  double _passwordStrength = 0.0; // 0.0 a 1.0

  static const String _cloudName = 'dtxikv1nx';
  static const String _uploadPreset = 'uploads_unsigned';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _companyNameCtrl.dispose();
    _companyRucCtrl.dispose();
    _companyAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) return;
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fullName = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';
      await ref.read(authProvider.notifier).signUpCompany(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: fullName.trim(),
            phone: _phoneCtrl.text.trim(),
            companyName: _companyNameCtrl.text.trim(),
            companyRuc: _companyRucCtrl.text.trim(),
            companyAddress: _companyAddressCtrl.text.trim().isNotEmpty
                ? _companyAddressCtrl.text.trim()
                : null,
            country: _selectedCountry,
            language: _selectedLanguage,
            companyLogoUrl: _companyLogoUrl,
          );
      if (!mounted) return;
      context.go('/verify-email');
    } catch (e) {
      setState(() {
        _error = 'Error al registrar: $e';
        _isLoading = false;
      });
    }
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.9)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.32), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.9)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.9), width: 1.4),
      ),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      helperStyle: TextStyle(color: Colors.white.withOpacity(0.75)),
    );
  }

  void _updatePasswordStrength(String value) {
    int score = 0;
    if (value.length >= 6) score++;
    if (value.length >= 10) score++;
    if (RegExp(r"[A-Z]").hasMatch(value)) score++;
    if (RegExp(r"[0-9]").hasMatch(value)) score++;
    if (RegExp(r"[^A-Za-z0-9]").hasMatch(value)) score++;
    setState(() {
      _passwordStrength = (score / 5).clamp(0, 1).toDouble();
    });
  }

  List<Widget> _personalStep() {
    return [
      Text('Datos personales', style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      )),
      const SizedBox(height: 8),
      Divider(color: Colors.white.withOpacity(0.15), height: 20),
      const SizedBox(height: 8),
      TextFormField(
        controller: _firstNameCtrl,
        textInputAction: TextInputAction.next,
        decoration: _dec('Nombres', Icons.person_outline),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _lastNameCtrl,
        textInputAction: TextInputAction.next,
        decoration: _dec('Apellidos', Icons.person_outline),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tus apellidos' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: _dec('Correo electrónico', Icons.email_outlined),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
          final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
          return ok ? null : 'Correo inválido';
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _phoneCtrl,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.phone,
        decoration: _dec('Teléfono', Icons.phone_outlined),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordCtrl,
        obscureText: !_showPassword,
        textInputAction: TextInputAction.next,
        decoration: _dec('Contraseña', Icons.lock_outline).copyWith(
          suffixIcon: IconButton(
            onPressed: () => setState(() => _showPassword = !_showPassword),
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
          ),
          helperText: 'Usa 10+ caracteres, mezcla mayúsculas, números y símbolos',
        ),
        onChanged: _updatePasswordStrength,
        validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: _passwordStrength,
          minHeight: 6,
          backgroundColor: Colors.white.withOpacity(0.12),
          color: _passwordStrength < 0.4
              ? Colors.redAccent
              : (_passwordStrength < 0.7 ? Colors.amber : Colors.lightGreen),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        _passwordStrength < 0.4
            ? 'Contraseña débil'
            : (_passwordStrength < 0.7 ? 'Contraseña media' : 'Contraseña fuerte'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _confirmPasswordCtrl,
        obscureText: !_showConfirm,
        textInputAction: TextInputAction.done,
        decoration: _dec('Confirmar contraseña', Icons.lock_outline).copyWith(
          suffixIcon: IconButton(
            onPressed: () => setState(() => _showConfirm = !_showConfirm),
            icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
          ),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Confirma tu contraseña' : null,
      ),
    ];
  }

  List<Widget> _companyStep() {
    return [
      Text('Datos de empresa', style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      )),
      const SizedBox(height: 8),
      Divider(color: Colors.white.withOpacity(0.15), height: 20),
      const SizedBox(height: 8),
      TextFormField(
        controller: _companyNameCtrl,
        textInputAction: TextInputAction.next,
        decoration: _dec('Nombre de la empresa', Icons.apartment_rounded),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de la empresa' : null,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            clipBehavior: Clip.hardEdge,
            child: _companyLogoPreview != null
                ? Image.memory(_companyLogoPreview!, fit: BoxFit.cover)
                : const Icon(Icons.image_outlined, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickCompanyLogo,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(_companyLogoUrl == null ? 'Subir logo (opcional)' : 'Reemplazar logo'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _companyRucCtrl,
        textInputAction: TextInputAction.next,
        decoration: _dec('RUC (opcional)', Icons.badge_outlined),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _companyAddressCtrl,
        textInputAction: TextInputAction.next,
        decoration: _dec('Dirección (opcional)', Icons.location_on_outlined),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _selectedCountry,
        isDense: true,
        decoration: _dec('País', Icons.public),
        items: countriesEs
            .map((c) => DropdownMenuItem(
                  value: c['code'],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_flagEmoji(c['code']!)),
                      const SizedBox(width: 8),
                      Text(c['name']!),
                    ],
                  ),
                ))
            .toList(),
        onChanged: _isLoading ? null : (v) => setState(() => _selectedCountry = v),
        validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un país' : null,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _selectedLanguage,
        decoration: _dec('Idioma para correos', Icons.language),
        items: const [
          DropdownMenuItem(value: 'es', child: Text('Español')),
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'pt', child: Text('Português')),
        ],
        onChanged: _isLoading ? null : (v) => setState(() => _selectedLanguage = v ?? 'es'),
      ),
      const SizedBox(height: 12),
      CheckboxListTile(
        value: _acceptedTerms,
        onChanged: _isLoading ? null : (v) => setState(() => _acceptedTerms = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text('Acepto los Términos y la Política de Privacidad'),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => setState(() => _step = 0),
              child: const Text('Atrás'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isLoading || !_acceptedTerms ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Crear cuenta'),
            ),
          ),
        ],
      ),
    ];
  }

  Future<String?> _uploadCompanyLogoBytes(Uint8List bytes, String fileName) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/'+_cloudName+'/auto/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = fileName
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final match = RegExp('"secure_url"\s*:\s*"([^"]+)"').firstMatch(response.body);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickCompanyLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final name = picked.name.isNotEmpty ? picked.name : 'company_logo';
      final ext = name.toLowerCase().contains('.') ? name.toLowerCase().split('.').last : '';
      const allowed = ['jpg','jpeg','png','gif','webp','svg'];
      if (!allowed.contains(ext)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formato no soportado. Usa JPG, JPEG, PNG, GIF, WEBP o SVG.')),
        );
        return;
      }
      final bytes = await picked.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La imagen es demasiado grande. Máximo 5MB.')),
        );
        return;
      }
      setState(() => _companyLogoPreview = bytes);
      final url = await _uploadCompanyLogoBytes(bytes, name);
      if (!mounted) return;
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo subir el logo. Inténtalo nuevamente.')),
        );
        return;
      }
      setState(() => _companyLogoUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo subido correctamente')),
      );
    } catch (_) {}
  }

  String _flagEmoji(String code) {
    final cc = code.toUpperCase();
    if (cc.length != 2) return '🏳️';
    const base = 0x1F1E6;
    final first = base + (cc.codeUnitAt(0) - 65);
    final second = base + (cc.codeUnitAt(1) - 65);
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LiquidGradientBackground(),
          // Sutil velo para mejorar contraste sobre el fondo
          Container(color: Colors.black.withOpacity(0.08)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apartment_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'Registro de Empresa',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.20)),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      _error!,
                                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StepPill(active: _step == 0, label: 'Datos personales'),
                                    const SizedBox(width: 8),
                                    _StepPill(active: _step == 1, label: 'Datos empresa'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...(_step == 0 ? _personalStep() : _companyStep()),
                                const SizedBox(height: 16),
                                if (_step == 0)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _isLoading ? null : () => context.pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!.validate()) {
                                                    setState(() => _step = 1);
                                                  }
                                                },
                                          child: const Text('Siguiente'),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final bool active;
  final String label;

  const _StepPill({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
        color: Colors.white.withOpacity(active ? 0.18 : 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.circle,
            size: 14,
            color: Colors.white.withOpacity(active ? 0.95 : 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
