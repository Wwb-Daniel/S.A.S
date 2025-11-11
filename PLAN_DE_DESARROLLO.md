# Plan de Desarrollo - Sistema de Tickets para Constructoras

## 1. Visión General
Sistema de gestión de tickets para empresas constructoras que permite a los empleados reportar problemas, solicitar materiales y realizar seguimiento de incidencias en tiempo real.

## 2. Objetivos
- Digitalizar el proceso de reporte de incidencias
- Mejorar la comunicación entre equipos
- Reducir tiempos de respuesta
- Mantener un historial de incidencias
- Generar reportes y estadísticas

## 3. Estructura del Proyecto

### 3.1 Frontend (Flutter)
```
lib/
├── main.dart
├── config/
├── models/
├── screens/
│   ├── auth/
│   ├── home/
│   ├── tickets/
│   └── profile/
├── services/
└── widgets/
```

### 3.2 Backend (Supabase)
- Base de datos PostgreSQL
- Autenticación
- Almacenamiento de archivos
- Funciones personalizadas
- Generación de reportes (PDF, Word, Excel)
- Políticas de seguridad

## 4. Hitos Principales

### Fase 1: Configuración Inicial (Semana 1)
- [x] Configurar proyecto Flutter
- [x] Integrar Supabase
- [x] Configurar autenticación
- [x] Diseñar esquema de base de datos

### Fase 2: Desarrollo Core (Semanas 2-3)
- [x] Pantalla de autenticación (Login/Register)
- [x] Lista de tickets
- [x] Creación/Edición de tickets
- [x] Gestión de archivos adjuntos
- [x] Sistema de comentarios

### Fase 3: Funcionalidades Avanzadas (Semana 4)
- [x] Notificaciones en tiempo real
- [x] Filtros y búsqueda
- [x] Reportes y estadísticas
- [x] Perfiles de usuario
- [x] Exportación de tickets en múltiples formatos (PDF, Word, Excel)

### Fase 4: Pruebas (Semana 5)
- [ ] Pruebas unitarias
- [ ] Pruebas de integración
- [ ] Pruebas de usabilidad
- [ ] Corrección de errores

### Fase 5: Despliegue (Semana 6)
- [ ] Configuración de producción
- [ ] Despliegue web
- [ ] Pruebas en producción
- [ ] Documentación

## 5. Entregables

### 5.1 Código Fuente
- Repositorio Git organizado
- Documentación del código
- Guía de instalación
- Plantillas personalizables para exportación

### 5.2 Documentación
- Manual de usuario
- Guía de administrador
- API documentation

### 5.3 Entrenamiento
- Sesión de capacitación
- Material de apoyo
- Videos tutoriales

## 6. Tecnologías

### Frontend
- Flutter 3.x
- Dart 3.x
- Provider/BLoC para gestión de estado
- Cached Network Image
- Photo View
- File Picker
- pdf: ^3.10.0 (generación de PDF)
- excel: ^2.1.0 (exportación a Excel)
- docx_template: ^4.0.0 (exportación a Word)

### Backend
- Supabase
- PostgreSQL
- Storage
- Autenticación JWT

## 7. Estándares de Código
- Clean Architecture
- Patrón Repository
- Widgets reutilizables
- Nombrado consistente
- Documentación en inglés

## 7.1 Especificaciones de Exportación

### 7.1.1 Exportación a PDF
- Diseño profesional con logo de la empresa
- Incluye imágenes adjuntas
- Muestra historial de cambios
- Firma digital opcional
- Código QR para verificación

### 7.1.2 Exportación a Word (DOCX)
- Formato editable
- Incluye tablas formateadas
- Compatible con versiones recientes de Word
- Mantiene el formato en diferentes dispositivos

### 7.1.3 Exportación a Excel (XLSX)
- Datos organizados en hojas de cálculo
- Filtros y tablas dinámicas
- Fórmulas para cálculos automáticos
- Gráficos de seguimiento

### 7.1.4 Características Comunes
- Plantillas personalizables
- Selección múltiple de tickets
- Programación de exportaciones recurrentes
- Envío automático por correo
- Almacenamiento en la nube

## 8. Estado Actual de Implementación

### ✅ Funcionalidades Completadas (Actualizado)

#### Sistema de Notificaciones en Tiempo Real
- **Modelo de Datos**: Estructura completa con campos id, employeeId, title, message, type, relatedTicketId, isRead, createdAt, readAt
- **Repository Pattern**: Implementación con Supabase para CRUD y suscripciones
- **Provider**: Gestión de estado con Riverpod incluyendo carga, actualización y suscripciones
- **UI Completa**: Pantalla de notificaciones con lista, estados de carga, y acciones
- **Widget de Icono**: Icono con contador de notificaciones no leídas para el AppBar
- **Suscripciones en Tiempo Real**: Integración con Supabase Realtime para actualizaciones instantáneas
- **Integración Total**: Ruta agregada al router y widget disponible en cualquier pantalla
- **Corrección de Bugs**: Solucionado bucle infinito en carga de notificaciones mediante gestión adecuada de suscripciones y estados

#### Sistema de Gestión de Archivos Adjuntos
- **Upload de Archivos**: Integración con Cloudinary para almacenamiento seguro
- **Tipos de Archivos Soportados**: Imágenes, PDFs, documentos de Office
- **Gestión en UI**: Selector de archivos, vista previa, eliminación
- **Almacenamiento**: URLs seguras y metadatos en base de datos
- **Validación**: Límites de tamaño y tipos de archivo permitidos

#### Sistema de Comentarios
- **Creación de Comentarios**: Interface intuitiva con campo de texto
- **Comentarios Internos**: Soporte para comentarios privados del equipo
- **Historial Completo**: Visualización cronológica de todas las interacciones
- **Actualización en Tiempo Real**: Suscripciones Supabase para cambios instantáneos
- **Gestión de Usuarios**: Identificación del autor y timestamps automáticos

#### Configuración Base

#### Configuración Base
- **Proyecto Flutter**: Configurado con arquitectura limpia y estructura modular
- **Supabase Integration**: Cliente configurado y conectado a la base de datos
- **Autenticación**: Sistema completo de login/registro con manejo de sesiones
- **Base de Datos**: Esquema completo implementado con tablas, relaciones y políticas de seguridad

#### Frontend Implementado
- **Sistema de Navegación**: GoRouter configurado con protección de rutas
- **Pantalla de Login**: Formulario validado con manejo de errores
- **Pantalla de Registro**: Formulario para nuevos usuarios
- **Dashboard**: Pantalla principal con navegación básica
- **Lista de Tickets**: Visualización de tickets con estado y prioridad
- **Creación de Tickets**: Formulario para crear nuevos tickets
- **Detalle de Tickets**: Vista individual de tickets con información completa
- **Perfil de Usuario**: Pantalla de perfil con gestión básica

#### Backend Implementado
- **Tablas Principales**: companies, employees, tickets, comments, attachments, notifications
- **Sistema de Roles**: employee, supervisor, admin, company_admin
- **Políticas de Seguridad**: RLS (Row Level Security) configurado
- **Triggers**: Para auditoría y validación de datos
- **Funciones Personalizadas**: Para validación de integridad de datos

#### Dependencias Configuradas
- **UI/UX**: Material Design, animaciones, temas claro/oscuro
- **Exportación**: PDF, Excel, Word listos para implementar
- **Almacenamiento**: Sistema de archivos y gestión de imágenes
- **Estado**: Riverpod para gestión de estado reactivo

### ✅ Funcionalidades Recientemente Completadas

#### Sistema de Filtros y Búsqueda
- **Modelo de Filtros**: TicketFilters con soporte para estado, prioridad, categoría, asignado, creador, fechas y búsqueda
- **Diálogo de Filtros**: Interfaz completa para aplicar múltiples filtros simultáneamente
- **Búsqueda en Tiempo Real**: Campo de búsqueda que filtra por título y descripción
- **Integración Completa**: Filtros aplicados en lista de tickets y reportes

#### Sistema de Reportes y Estadísticas
- **Modelos de Datos**: TicketStatistics y TicketTrends para análisis de datos
- **Repository Pattern**: Implementación completa con cálculo de estadísticas
- **Pantalla de Reportes**: Visualización de estadísticas con gráficos y tendencias
- **Filtros en Reportes**: Aplicación de filtros para análisis específicos
- **Exportación Básica**: Exportación a CSV y JSON implementada

### ✅ Funcionalidades Recientemente Completadas (Actualizado)

#### Sistema de Internacionalización (i18n) - Base Implementada
- **Clase AppLocalizations**: Sistema de localización con soporte para español e inglés
- **Provider de Idioma**: LocaleNotifier para gestionar cambios de idioma con persistencia
- **Integración en MaterialApp**: Configuración de localizaciones y delegados
- **Traducciones Base**: Más de 80 strings traducidos para las funcionalidades principales
- **Pendiente**: Integración de traducciones en todas las pantallas de la aplicación

#### Sistema de Exportación de Tickets
- **Exportación a PDF**: Documento profesional con formato fijo, tablas, encabezados y pie de página
- **Exportación a Word**: Documento de texto formateado compatible con Microsoft Word
- **Exportación a Excel**: Hojas de cálculo con múltiples pestañas, estadísticas, tablas formateadas y fórmulas
- **Exportación a CSV/JSON**: Formatos básicos para intercambio de datos con codificación UTF-8 y BOM para compatibilidad con Excel
- **Diálogo de Selección**: Interfaz intuitiva para elegir el formato de exportación
- **Integración Completa**: Servicio de exportación integrado con el sistema de reportes
- **Soporte Multiplataforma**: Funciona en web, móvil y desktop
- **Correcciones Implementadas**: 
  - Solucionado problema de doble descarga de archivos
  - Corregido formato CSV para compatibilidad con Excel (BOM UTF-8)
  - Mejorado formato Excel para evitar errores de apertura
  - Validación y limpieza de datos en exportaciones

### 🚧 Funcionalidades en Progreso
- Internacionalización (i18n) - Estructura base implementada, pendiente integración en pantallas

### ❌ Funcionalidades Pendientes
- Sistema de notificaciones push
- Modo offline

## 9. Próximos Pasos (Actualizado)
1. ✅ Implementar filtros y búsqueda avanzada - COMPLETADO
2. ✅ Crear sistema de reportes y estadísticas - COMPLETADO
3. ✅ Desarrollar funcionalidad de exportación (PDF, Word, Excel) - COMPLETADO
4. ✅ Corregir bugs en notificaciones (bucle infinito) - COMPLETADO
5. ✅ Corregir bugs en exportación (doble descarga, formato Excel/CSV) - COMPLETADO
6. 🚧 Implementar internacionalización (i18n) - Estructura base creada, pendiente integración en pantallas
7. Implementar pruebas unitarias
8. Optimizar para modo offline
9. Preparar para despliegue en producción

## 10. Notas Adicionales
- Priorizar experiencia móvil
- Diseño responsive
- Soporte offline
- Internacionalización

## 11. Contacto
- Desarrollador: [Victor De Jesus]
- Email: [victordejesus131318@gmail.com]
- Fecha de inicio: Noviembre 2025
- Fecha estimada de finalización: Diciembre 2025
