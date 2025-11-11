import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('es', ''), // Español
    Locale('en', ''), // Inglés
  ];

  // Métodos de traducción
  String get appName => _localizedValues[locale.languageCode]?['appName'] ?? 'Sistema de Tickets';

  // Autenticación
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Iniciar Sesión';
  String get register => _localizedValues[locale.languageCode]?['register'] ?? 'Registro';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Correo Electrónico';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Contraseña';
  String get forgotPassword => _localizedValues[locale.languageCode]?['forgotPassword'] ?? '¿Olvidaste tu contraseña?';
  String get noAccount => _localizedValues[locale.languageCode]?['noAccount'] ?? '¿No tienes una cuenta? Regístrate';
  String get signIn => _localizedValues[locale.languageCode]?['signIn'] ?? 'Iniciar Sesión';
  String get signUp => _localizedValues[locale.languageCode]?['signUp'] ?? 'Registrarse';
  String get personalInfo => _localizedValues[locale.languageCode]?['personalInfo'] ?? 'Información Personal';
  String get companyInfo => _localizedValues[locale.languageCode]?['companyInfo'] ?? 'Información de la Empresa';
  String get firstName => _localizedValues[locale.languageCode]?['firstName'] ?? 'Nombre';
  String get lastName => _localizedValues[locale.languageCode]?['lastName'] ?? 'Apellido';
  String get phone => _localizedValues[locale.languageCode]?['phone'] ?? 'Teléfono';
  String get companyName => _localizedValues[locale.languageCode]?['companyName'] ?? 'Nombre de la Empresa';
  String get companyAddress => _localizedValues[locale.languageCode]?['companyAddress'] ?? 'Dirección de la Empresa';

  // Dashboard
  String get welcome => _localizedValues[locale.languageCode]?['welcome'] ?? 'Bienvenido/a';
  String get dashboardDescription => _localizedValues[locale.languageCode]?['dashboardDescription'] ?? 'Aquí puedes gestionar tus tickets y ver el estado de tus solicitudes.';
  String get ticketsSummary => _localizedValues[locale.languageCode]?['ticketsSummary'] ?? 'Resumen de Tickets';
  String get openTickets => _localizedValues[locale.languageCode]?['openTickets'] ?? 'Tickets Abiertos';
  String get inProgressTickets => _localizedValues[locale.languageCode]?['inProgressTickets'] ?? 'En Progreso';
  String get resolvedTickets => _localizedValues[locale.languageCode]?['resolvedTickets'] ?? 'Resueltos';
  String get closedTickets => _localizedValues[locale.languageCode]?['closedTickets'] ?? 'Cerrados';

  // Tickets
  String get tickets => _localizedValues[locale.languageCode]?['tickets'] ?? 'Tickets';
  String get createTicket => _localizedValues[locale.languageCode]?['createTicket'] ?? 'Crear Ticket';
  String get editTicket => _localizedValues[locale.languageCode]?['editTicket'] ?? 'Editar Ticket';
  String get ticketTitle => _localizedValues[locale.languageCode]?['ticketTitle'] ?? 'Título';
  String get description => _localizedValues[locale.languageCode]?['description'] ?? 'Descripción';
  String get status => _localizedValues[locale.languageCode]?['status'] ?? 'Estado';
  String get priority => _localizedValues[locale.languageCode]?['priority'] ?? 'Prioridad';
  String get category => _localizedValues[locale.languageCode]?['category'] ?? 'Categoría';
  String get dueDate => _localizedValues[locale.languageCode]?['dueDate'] ?? 'Fecha límite';
  String get assignedTo => _localizedValues[locale.languageCode]?['assignedTo'] ?? 'Asignado a';
  String get createdBy => _localizedValues[locale.languageCode]?['createdBy'] ?? 'Creado por';
  String get createdAt => _localizedValues[locale.languageCode]?['createdAt'] ?? 'Fecha de creación';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Guardar';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancelar';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Eliminar';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Editar';
  String get low => _localizedValues[locale.languageCode]?['low'] ?? 'Baja';
  String get medium => _localizedValues[locale.languageCode]?['medium'] ?? 'Media';
  String get high => _localizedValues[locale.languageCode]?['high'] ?? 'Alta';
  String get urgent => _localizedValues[locale.languageCode]?['urgent'] ?? 'Urgente';
  String get open => _localizedValues[locale.languageCode]?['open'] ?? 'Abierto';
  String get inProgress => _localizedValues[locale.languageCode]?['inProgress'] ?? 'En Progreso';
  String get resolved => _localizedValues[locale.languageCode]?['resolved'] ?? 'Resuelto';
  String get closed => _localizedValues[locale.languageCode]?['closed'] ?? 'Cerrado';

  // Notificaciones
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notificaciones';
  String get markAllAsRead => _localizedValues[locale.languageCode]?['markAllAsRead'] ?? 'Marcar todo como leído';
  String get noNotifications => _localizedValues[locale.languageCode]?['noNotifications'] ?? 'No tienes notificaciones';

  // Reportes
  String get reports => _localizedValues[locale.languageCode]?['reports'] ?? 'Reportes';
  String get statistics => _localizedValues[locale.languageCode]?['statistics'] ?? 'Estadísticas';
  String get export => _localizedValues[locale.languageCode]?['export'] ?? 'Exportar';
  String get exportReport => _localizedValues[locale.languageCode]?['exportReport'] ?? 'Exportar Reporte';
  String get selectFormat => _localizedValues[locale.languageCode]?['selectFormat'] ?? 'Seleccionar Formato';
  String get pdf => _localizedValues[locale.languageCode]?['pdf'] ?? 'PDF';
  String get word => _localizedValues[locale.languageCode]?['word'] ?? 'Word';
  String get excel => _localizedValues[locale.languageCode]?['excel'] ?? 'Excel';
  String get csv => _localizedValues[locale.languageCode]?['csv'] ?? 'CSV';
  String get json => _localizedValues[locale.languageCode]?['json'] ?? 'JSON';

  // Perfil
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Perfil';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Configuración';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Idioma';
  String get spanish => _localizedValues[locale.languageCode]?['spanish'] ?? 'Español';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Cerrar Sesión';

  // Filtros
  String get filters => _localizedValues[locale.languageCode]?['filters'] ?? 'Filtros';
  String get search => _localizedValues[locale.languageCode]?['search'] ?? 'Buscar';
  String get applyFilters => _localizedValues[locale.languageCode]?['applyFilters'] ?? 'Aplicar Filtros';
  String get clearFilters => _localizedValues[locale.languageCode]?['clearFilters'] ?? 'Limpiar Filtros';
  String get startDate => _localizedValues[locale.languageCode]?['startDate'] ?? 'Fecha de inicio';
  String get endDate => _localizedValues[locale.languageCode]?['endDate'] ?? 'Fecha de fin';
  String get overdue => _localizedValues[locale.languageCode]?['overdue'] ?? 'Vencidos';

  // Comentarios
  String get comments => _localizedValues[locale.languageCode]?['comments'] ?? 'Comentarios';
  String get addComment => _localizedValues[locale.languageCode]?['addComment'] ?? 'Agregar Comentario';
  String get internalComment => _localizedValues[locale.languageCode]?['internalComment'] ?? 'Comentario Interno';

  // Errores y mensajes
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'Reintentar';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Cargando...';
  String get noData => _localizedValues[locale.languageCode]?['noData'] ?? 'No hay datos disponibles';

  // Valores localizados
  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'appName': 'Sistema de Tickets',
      'login': 'Iniciar Sesión',
      'register': 'Registro',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'forgotPassword': '¿Olvidaste tu contraseña?',
      'noAccount': '¿No tienes una cuenta? Regístrate',
      'signIn': 'Iniciar Sesión',
      'signUp': 'Registrarse',
      'personalInfo': 'Información Personal',
      'companyInfo': 'Información de la Empresa',
      'firstName': 'Nombre',
      'lastName': 'Apellido',
      'phone': 'Teléfono',
      'companyName': 'Nombre de la Empresa',
      'companyAddress': 'Dirección de la Empresa',
      'welcome': 'Bienvenido/a',
      'dashboardDescription': 'Aquí puedes gestionar tus tickets y ver el estado de tus solicitudes.',
      'ticketsSummary': 'Resumen de Tickets',
      'openTickets': 'Tickets Abiertos',
      'inProgressTickets': 'En Progreso',
      'resolvedTickets': 'Resueltos',
      'closedTickets': 'Cerrados',
      'tickets': 'Tickets',
      'createTicket': 'Crear Ticket',
      'editTicket': 'Editar Ticket',
      'ticketTitle': 'Título',
      'description': 'Descripción',
      'status': 'Estado',
      'priority': 'Prioridad',
      'category': 'Categoría',
      'dueDate': 'Fecha límite',
      'assignedTo': 'Asignado a',
      'createdBy': 'Creado por',
      'createdAt': 'Fecha de creación',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'low': 'Baja',
      'medium': 'Media',
      'high': 'Alta',
      'urgent': 'Urgente',
      'open': 'Abierto',
      'inProgress': 'En Progreso',
      'resolved': 'Resuelto',
      'closed': 'Cerrado',
      'notifications': 'Notificaciones',
      'markAllAsRead': 'Marcar todo como leído',
      'noNotifications': 'No tienes notificaciones',
      'reports': 'Reportes',
      'statistics': 'Estadísticas',
      'export': 'Exportar',
      'exportReport': 'Exportar Reporte',
      'selectFormat': 'Seleccionar Formato',
      'pdf': 'PDF',
      'word': 'Word',
      'excel': 'Excel',
      'csv': 'CSV',
      'json': 'JSON',
      'profile': 'Perfil',
      'settings': 'Configuración',
      'language': 'Idioma',
      'spanish': 'Español',
      'english': 'English',
      'logout': 'Cerrar Sesión',
      'filters': 'Filtros',
      'search': 'Buscar',
      'applyFilters': 'Aplicar Filtros',
      'clearFilters': 'Limpiar Filtros',
      'startDate': 'Fecha de inicio',
      'endDate': 'Fecha de fin',
      'overdue': 'Vencidos',
      'comments': 'Comentarios',
      'addComment': 'Agregar Comentario',
      'internalComment': 'Comentario Interno',
      'error': 'Error',
      'retry': 'Reintentar',
      'loading': 'Cargando...',
      'noData': 'No hay datos disponibles',
    },
    'en': {
      'appName': 'Ticket System',
      'login': 'Sign In',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot your password?',
      'noAccount': "Don't have an account? Sign up",
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'personalInfo': 'Personal Information',
      'companyInfo': 'Company Information',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'phone': 'Phone',
      'companyName': 'Company Name',
      'companyAddress': 'Company Address',
      'welcome': 'Welcome',
      'dashboardDescription': 'Here you can manage your tickets and view the status of your requests.',
      'ticketsSummary': 'Tickets Summary',
      'openTickets': 'Open Tickets',
      'inProgressTickets': 'In Progress',
      'resolvedTickets': 'Resolved',
      'closedTickets': 'Closed',
      'tickets': 'Tickets',
      'createTicket': 'Create Ticket',
      'editTicket': 'Edit Ticket',
      'ticketTitle': 'Title',
      'description': 'Description',
      'status': 'Status',
      'priority': 'Priority',
      'category': 'Category',
      'dueDate': 'Due Date',
      'assignedTo': 'Assigned To',
      'createdBy': 'Created By',
      'createdAt': 'Created At',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'urgent': 'Urgent',
      'open': 'Open',
      'inProgress': 'In Progress',
      'resolved': 'Resolved',
      'closed': 'Closed',
      'notifications': 'Notifications',
      'markAllAsRead': 'Mark all as read',
      'noNotifications': 'You have no notifications',
      'reports': 'Reports',
      'statistics': 'Statistics',
      'export': 'Export',
      'exportReport': 'Export Report',
      'selectFormat': 'Select Format',
      'pdf': 'PDF',
      'word': 'Word',
      'excel': 'Excel',
      'csv': 'CSV',
      'json': 'JSON',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'spanish': 'Español',
      'english': 'English',
      'logout': 'Logout',
      'filters': 'Filters',
      'search': 'Search',
      'applyFilters': 'Apply Filters',
      'clearFilters': 'Clear Filters',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'overdue': 'Overdue',
      'comments': 'Comments',
      'addComment': 'Add Comment',
      'internalComment': 'Internal Comment',
      'error': 'Error',
      'retry': 'Retry',
      'loading': 'Loading...',
      'noData': 'No data available',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

