# mi_app_multiplataforma

Aplicación multiplataforma desarrollada con Flutter. Este repositorio contiene el código fuente de la app y las instrucciones para instalar las dependencias, ejecutar el proyecto en Windows, Android y Web, y resolver problemas comunes.

## Requisitos
- Windows 10/11 de 64 bits
- Git
- Flutter SDK (Dart incluido)
- Android Studio (SDK + emulador Android)
- Chrome (para Web) y/o un dispositivo/emulador Android
- VS Code o Android Studio (opcional)

## Instalación rápida en Windows
Puedes instalar con winget (recomendado) o manualmente.

### Opción A: winget
1. Instalar Git y Flutter:
   - `winget install Git.Git`
   - `winget install Flutter.Flutter`
2. Instalar Android Studio:
   - `winget install Google.AndroidStudio`
3. Reinicia la terminal y verifica:
   - `flutter doctor -v`

### Opción B: manual
1. Descarga Flutter (canal estable) desde https://docs.flutter.dev/get-started/install/windows
2. Extrae el zip en una ruta sin espacios (por ejemplo `C:\src\flutter`) y agrega `C:\src\flutter\bin` al PATH del sistema.
3. Instala Android Studio y, desde el SDK Manager, instala:
   - Android SDK Platform
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Emulador de Android (opcional)
4. Acepta licencias:
   - `flutter doctor --android-licenses`

## Verificación del entorno
Ejecuta:
- `flutter doctor -v`
Asegúrate de que no haya issues críticos.

## Configuración del proyecto
1. Instala dependencias:
   - `flutter pub get`
2. (Opcional) Generación de código si usas freezed/json_serializable:
   - `flutter pub run build_runner build --delete-conflicting-outputs`

## Ejecución
- Web (Chrome): `flutter run -d chrome`
- Windows: `flutter run -d windows`
- Android (emulador/dispositivo):
  1) Inicia un emulador desde Android Studio o conecta tu dispositivo con depuración USB.
  2) `flutter devices` para ver dispositivos.
  3) `flutter run -d <deviceId>`

## Variables y servicios externos
Este proyecto usa paquetes como `supabase_flutter`. Si tu app requiere URL/keys:
- Crea valores seguros en tu código o gestor de secretos.
- No subas claves sensibles al repositorio.
- Documenta dónde configurar estos valores (por ejemplo, en un archivo de constantes o usando inyección de entorno en CI/CD).

## Estructura principal
- `lib/` código fuente Dart
- `assets/` recursos (definidos en `pubspec.yaml`)
- `android/`, `windows/`, `web/` soportes por plataforma
- `test/` pruebas

## Comandos útiles
- Limpiar cachés: `flutter clean`
- Actualizar dependencias: `flutter pub upgrade --major-versions`
- Ver dependencias desactualizadas: `flutter pub outdated`
- Analizador/lints: `dart analyze`
- Tests: `flutter test`

## Solución de problemas
- Licencias Android: `flutter doctor --android-licenses`
- Dispositivo no detectado: `flutter devices` y revisa drivers/adb
- Errores de build_runner: `--delete-conflicting-outputs`

## Información del proyecto
- Nombre: `mi_app_multiplataforma`
- SDK Dart: ver `environment.sdk` en `pubspec.yaml`
- Principales dependencias: Riverpod, GoRouter, Supabase, etc. (ver `pubspec.yaml`)
