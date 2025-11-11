# Despliegue de Flutter Web en Vercel

Este documento explica cómo desplegar este proyecto Flutter multiplataforma en Vercel sin fallos de compilación.

## Requisitos previos

- Una cuenta en [Vercel](https://vercel.com)
- El repositorio subido a GitHub
- Acceso a las variables de entorno si las necesitas (Supabase, etc.)

## Pasos para el despliegue

### 1. Conectar el repositorio a Vercel

1. Ve a [vercel.com/new](https://vercel.com/new)
2. Selecciona "Import Git Repository"
3. Busca y selecciona `Wwb-Daniel/S.A.S`
4. Haz clic en "Import"

### 2. Configurar el proyecto en Vercel

Vercel debería detectar automáticamente el archivo `vercel.json`. Si no:

1. En "Project Settings":
   - **Framework**: Other
   - **Build Command**: Se configurará automáticamente desde vercel.json
   - **Output Directory**: `build/web`

2. Si necesitas variables de entorno:
   - Ve a "Settings" → "Environment Variables"
   - Agrega las variables necesarias (ej: Supabase URL, Supabase Key)

### 3. Desplegar

1. Vercel debería comenzar el build automáticamente
2. El build tardará entre 15-30 minutos la primera vez (Flutter SDK toma tiempo)
3. Una vez completado, tendrás un enlace a tu aplicación

## Configuración en vercel.json

El archivo `vercel.json` incluye:

- **buildCommand**: Clona Flutter, ejecuta `flutter build web --release`
- **installCommand**: Verifica que todo esté en orden
- **outputDirectory**: `build/web` - donde está el output compilado
- **framework**: `other` - ya que Vercel no tiene soporte nativo para Flutter

## Solución de problemas

### Build falla con "Flutter not found"

- El script `scripts/build.sh` se encarga de clonar Flutter automáticamente
- Si falla, revisa los logs del build en Vercel

### Build muy lento

- La primera vez tarda porque:
  - Clona el SDK de Flutter (~400MB)
  - Descarga todas las dependencias Dart/Flutter
  - Compila la aplicación
- Vercel cachea esto para builds posteriores

### Error con dependencias de Supabase

- Asegúrate de que:
  - Tu `pubspec.yaml` tiene las versiones correctas
  - Las variables de entorno están configuradas en Vercel
  - No hay conflictos entre paquetes

### Archivo output no generado

- Verifica que `build/web` se genere localmente:
  ```bash
  flutter build web --release
  ```
- Si genera error localmente, fijará en Vercel también

## Optimizaciones implementadas

1. **vercel.json**: Configuración personalizada para Flutter Web
2. **scripts/build.sh**: Script eficiente que evita reinstalar Flutter cada vez
3. **.gitignore mejorado**: Excluye archivos innecesarios para acelerar el upload

## Variables de entorno recomendadas

Si usas Supabase u otros servicios, agrega estas variables en Vercel:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Monitoreo después del despliegue

- **Logs**: Ve a tu proyecto en Vercel → Deployments → selecciona el build → Logs
- **Performance**: Usa las Analytics de Vercel
- **Redeployes**: Ocurren automáticamente con cada push a `main`

## Próximos pasos

1. Personaliza el dominio en Vercel
2. Configura SSL/HTTPS (automático)
3. Monitorea el rendimiento
4. Realiza pruebas de la aplicación en producción

¡Tu aplicación Flutter está ahora en la web! 🚀
