-- 1. Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabla de empresas
CREATE TABLE IF NOT EXISTS companies (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  ruc TEXT UNIQUE,
  address TEXT,
  phone TEXT,
  email TEXT NOT NULL,
  logo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT NOT NULL DEFAULT 'active' -- 'active', 'inactive', 'suspended'
);

-- 3. Tabla de empleados
CREATE TABLE IF NOT EXISTS employees (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'employee', -- 'employee', 'supervisor', 'admin', 'company_admin'
  position TEXT, -- Cargo o puesto del empleado
  phone TEXT,
  department TEXT, -- Departamento al que pertenece
  avatar_url TEXT, -- URL de la imagen de perfil
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT NOT NULL DEFAULT 'active', -- 'active', 'inactive', 'on_leave', 'suspended'
  CONSTRAINT unique_company_email UNIQUE (company_id, email)
);

-- 4. Índice para búsquedas por compañía
CREATE INDEX idx_employees_company ON employees(company_id);

-- 5. Función para actualizar automáticamente el campo updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Triggers para actualizar automáticamente updated_at
CREATE TRIGGER update_companies_updated_at
BEFORE UPDATE ON companies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at
BEFORE UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Tabla de categorías de tickets
CREATE TABLE ticket_categories (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT DEFAULT '#2196F3',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Tabla de tickets
CREATE TABLE tickets (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'abierto', -- 'abierto', 'en_progreso', 'en_revision', 'resuelto', 'cerrado'
  priority TEXT NOT NULL DEFAULT 'media', -- 'baja', 'media', 'alta', 'urgente'
  category_id INTEGER REFERENCES ticket_categories(id) ON DELETE SET NULL,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  assigned_to UUID REFERENCES employees(id) ON DELETE SET NULL,
  due_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  closed_at TIMESTAMP WITH TIME ZONE,
  closed_by UUID REFERENCES employees(id),
  resolution TEXT
);

-- 9. Tabla de comentarios en tickets
CREATE TABLE ticket_comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE NOT NULL,
  employee_id UUID REFERENCES employees(id) NOT NULL,
  comment TEXT NOT NULL,
  is_internal BOOLEAN DEFAULT false, -- Para comentarios internos del personal
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Tabla de archivos adjuntos
CREATE TABLE ticket_attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE NOT NULL,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  uploaded_by UUID REFERENCES employees(id) NOT NULL,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Tabla de historial de cambios en tickets
CREATE TABLE ticket_history (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE NOT NULL,
  employee_id UUID REFERENCES employees(id) NOT NULL,
  action TEXT NOT NULL, -- 'status_change', 'assignment', 'priority_change', etc.
  old_value TEXT,
  new_value TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. Tabla de notificaciones
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID REFERENCES employees(id) NOT NULL,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- 'info', 'warning', 'success', 'error'
  is_read BOOLEAN DEFAULT false,
  related_ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. Tabla de configuración
CREATE TABLE app_settings (
  id SERIAL PRIMARY KEY,
  setting_key TEXT UNIQUE NOT NULL,
  setting_value TEXT,
  description TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_by UUID REFERENCES employees(id)
);

-- 14. Tabla de configuraciones de la aplicación por empresa
CREATE TABLE company_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  setting_key TEXT NOT NULL,
  setting_value TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT unique_company_setting UNIQUE (company_id, setting_key)
);

-- 15. Tabla de configuraciones globales de la aplicación
CREATE TABLE global_settings (
  id SERIAL PRIMARY KEY,
  setting_key TEXT UNIQUE NOT NULL,
  setting_value TEXT,
  description TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 16. Insertar categorías por defecto
INSERT INTO ticket_categories (name, description, icon, color) VALUES 
  ('Materiales', 'Solicitud de materiales de construcción', 'construction', '#4CAF50'),
  ('Equipo', 'Problemas con maquinaria o equipo', 'build', '#2196F3'),
  ('Seguridad', 'Reporte de condiciones inseguras', 'security', '#F44336'),
  ('Mantenimiento', 'Solicitud de mantenimiento', 'handyman', '#FF9800'),
  ('Infraestructura', 'Problemas con instalaciones', 'apartment', '#9C27B0'),
  ('Otros', 'Otras solicitudes o reportes', 'more_horiz', '#607D8B');

-- 16. Habilitar RLS en todas las tablas
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_settings ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FUNCIONES Y TRIGGERS PARA INTEGRIDAD DE DATOS
-- =============================================

-- 1. Función para verificar la integridad de compañía en tickets
CREATE OR REPLACE FUNCTION check_ticket_company_integrity()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que el creador pertenezca a la compañía
    IF (SELECT company_id FROM employees WHERE id = NEW.created_by) != NEW.company_id THEN
        RAISE EXCEPTION 'El empleado que crea el ticket debe pertenecer a la compañía';
    END IF;
    
    -- Verificar que el asignado (si existe) pertenezca a la compañía
    IF NEW.assigned_to IS NOT NULL AND 
       (SELECT company_id FROM employees WHERE id = NEW.assigned_to) != NEW.company_id THEN
        RAISE EXCEPTION 'El empleado asignado debe pertenecer a la compañía';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Función para verificar la integridad de compañía en comentarios
CREATE OR REPLACE FUNCTION check_comment_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
    ticket_company_id UUID;
    employee_company_id UUID;
BEGIN
    SELECT t.company_id INTO ticket_company_id 
    FROM tickets t 
    WHERE t.id = NEW.ticket_id;
    
    SELECT e.company_id INTO employee_company_id 
    FROM employees e 
    WHERE e.id = NEW.employee_id;
    
    IF ticket_company_id != employee_company_id THEN
        RAISE EXCEPTION 'El empleado debe pertenecer a la misma compañía que el ticket';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Función para verificar la integridad de compañía en adjuntos
CREATE OR REPLACE FUNCTION check_attachment_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
    ticket_company_id UUID;
    uploader_company_id UUID;
BEGIN
    SELECT t.company_id INTO ticket_company_id 
    FROM tickets t 
    WHERE t.id = NEW.ticket_id;
    
    SELECT e.company_id INTO uploader_company_id 
    FROM employees e 
    WHERE e.id = NEW.uploaded_by;
    
    IF ticket_company_id != uploader_company_id THEN
        RAISE EXCEPTION 'El empleado que sube el archivo debe pertenecer a la misma compañía que el ticket';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Función para verificar la integridad de compañía en el historial
CREATE OR REPLACE FUNCTION check_history_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
    ticket_company_id UUID;
    employee_company_id UUID;
BEGIN
    SELECT t.company_id INTO ticket_company_id 
    FROM tickets t 
    WHERE t.id = NEW.ticket_id;
    
    SELECT e.company_id INTO employee_company_id 
    FROM employees e 
    WHERE e.id = NEW.employee_id;
    
    IF ticket_company_id != employee_company_id THEN
        RAISE EXCEPTION 'El empleado debe pertenecer a la misma compañía que el ticket';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Función para verificar la integridad de compañía en notificaciones
CREATE OR REPLACE FUNCTION check_notification_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
    employee_company_id UUID;
    ticket_company_id UUID;
BEGIN
    -- Verificar que el empleado pertenezca a la compañía
    SELECT company_id INTO employee_company_id 
    FROM employees 
    WHERE id = NEW.employee_id;
    
    IF employee_company_id != NEW.company_id THEN
        RAISE EXCEPTION 'El empleado debe pertenecer a la compañía de la notificación';
    END IF;
    
    -- Si hay un ticket relacionado, verificar que sea de la misma compañía
    IF NEW.related_ticket_id IS NOT NULL THEN
        SELECT company_id INTO ticket_company_id 
        FROM tickets 
        WHERE id = NEW.related_ticket_id;
        
        IF ticket_company_id != NEW.company_id THEN
            RAISE EXCEPTION 'El ticket relacionado debe ser de la misma compañía';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- CREACIÓN DE TRIGGERS
-- =============================================

-- 1. Trigger para tickets
CREATE OR REPLACE TRIGGER tr_check_ticket_company_integrity
BEFORE INSERT OR UPDATE ON tickets
FOR EACH ROW 
EXECUTE FUNCTION check_ticket_company_integrity();

-- 2. Trigger para comentarios
CREATE OR REPLACE TRIGGER tr_check_comment_company_integrity
BEFORE INSERT OR UPDATE ON ticket_comments
FOR EACH ROW 
EXECUTE FUNCTION check_comment_company_integrity();

-- 3. Trigger para adjuntos
CREATE OR REPLACE TRIGGER tr_check_attachment_company_integrity
BEFORE INSERT OR UPDATE ON ticket_attachments
FOR EACH ROW 
EXECUTE FUNCTION check_attachment_company_integrity();

-- 4. Trigger para historial
CREATE OR REPLACE TRIGGER tr_check_history_company_integrity
BEFORE INSERT OR UPDATE ON ticket_history
FOR EACH ROW 
EXECUTE FUNCTION check_history_company_integrity();

-- 5. Trigger para notificaciones
CREATE OR REPLACE TRIGGER tr_check_notification_company_integrity
BEFORE INSERT OR UPDATE ON notifications
FOR EACH ROW 
EXECUTE FUNCTION check_notification_company_integrity();

-- 17. Crear función para obtener el ID de la compañía del usuario actual
CREATE OR REPLACE FUNCTION get_current_user_company_id()
RETURNS UUID AS $$
DECLARE
  user_company_id UUID;
BEGIN
  SELECT company_id INTO user_company_id
  FROM employees
  WHERE id = auth.uid();
  
  RETURN user_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 18. Crear función para verificar si el usuario es administrador de la empresa
CREATE OR REPLACE FUNCTION is_company_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND role = 'company_admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 19. Políticas para la tabla companies
-- Los administradores pueden ver todas las empresas (para super administradores)
CREATE POLICY "Super admins can view all companies"
ON companies
FOR SELECT
TO authenticated
USING (EXISTS (
  SELECT 1 FROM auth.users 
  WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'super_admin'
));

-- Los usuarios solo pueden ver su propia empresa
CREATE POLICY "Users can view their own company"
ON companies
FOR SELECT
TO authenticated
USING (id = get_current_user_company_id());

-- Solo super administradores pueden crear/actualizar/eliminar empresas
CREATE POLICY "Only super admins can manage companies"
ON companies
FOR ALL
TO authenticated
USING (EXISTS (
  SELECT 1 FROM auth.users 
  WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'super_admin'
));

-- 20. Políticas para la tabla employees
-- Los empleados pueden ver a otros empleados de su misma empresa
CREATE POLICY "Employees can view colleagues from same company"
ON employees
FOR SELECT
USING (
  (SELECT company_id FROM employees WHERE id = auth.uid()) = company_id
);

-- Los administradores de empresa pueden gestionar empleados de su empresa
CREATE POLICY "Company admins can manage employees"
ON employees
FOR ALL
TO authenticated
USING (
  company_id = get_current_user_company_id() AND 
  (is_company_admin() OR auth.uid() = id)
);

-- 21. Políticas para tickets
-- Los empleados pueden ver los tickets de su empresa
CREATE POLICY "Employees can view tickets from their company"
ON tickets
FOR SELECT
TO authenticated
USING (company_id = get_current_user_company_id());

-- Los empleados pueden crear tickets en su empresa
CREATE POLICY "Employees can create tickets"
ON tickets
FOR INSERT
TO authenticated
WITH CHECK (
  company_id = get_current_user_company_id() AND
  created_by = auth.uid()
);

-- Los empleados pueden actualizar sus propios tickets
-- Los administradores pueden actualizar cualquier ticket de su empresa
CREATE POLICY "Employees can update their own tickets, admins can update any"
ON tickets
FOR UPDATE
TO authenticated
USING (company_id = get_current_user_company_id())
WITH CHECK (
  company_id = get_current_user_company_id() AND
  (created_by = auth.uid() OR is_company_admin())
);

-- 22. Políticas para comentarios
-- Los empleados pueden ver comentarios de su empresa
CREATE POLICY "Employees can view comments from their company"
ON ticket_comments
FOR SELECT
TO authenticated
USING (
  (SELECT company_id FROM tickets WHERE id = ticket_id) = get_current_user_company_id()
);

-- Los empleados pueden crear comentarios en tickets de su empresa
CREATE POLICY "Employees can create comments on their company's tickets"
ON ticket_comments
FOR INSERT
TO authenticated
WITH CHECK (
  employee_id = auth.uid() AND
  (SELECT company_id FROM tickets WHERE id = ticket_id) = get_current_user_company_id()
);

-- 23. Políticas para archivos adjuntos
-- Los empleados pueden ver archivos adjuntos de su empresa
CREATE POLICY "Employees can view attachments from their company"
ON ticket_attachments
FOR SELECT
TO authenticated
USING (
  (SELECT company_id FROM tickets WHERE id = ticket_id) = get_current_user_company_id()
);

-- Los empleados pueden subir archivos a tickets de su empresa
CREATE POLICY "Employees can upload attachments to their company's tickets"
ON ticket_attachments
FOR INSERT
TO authenticated
WITH CHECK (
  uploaded_by = auth.uid() AND
  (SELECT company_id FROM tickets WHERE id = ticket_id) = get_current_user_company_id()
);

-- 24. Políticas para notificaciones
-- Los empleados solo pueden ver sus propias notificaciones
CREATE POLICY "Employees can only view their own notifications"
ON notifications
FOR ALL
TO authenticated
USING (employee_id = auth.uid() AND company_id = get_current_user_company_id());

-- 25. Políticas para configuraciones de empresa
-- Los empleados pueden ver las configuraciones de su empresa
CREATE POLICY "Employees can view their company settings"
ON company_settings
FOR SELECT
TO authenticated
USING (company_id = get_current_user_company_id());

-- Solo los administradores pueden modificar configuraciones
CREATE POLICY "Only company admins can modify company settings"
ON company_settings
FOR ALL
TO authenticated
USING (company_id = get_current_user_company_id() AND is_company_admin());

-- 26. Crear usuario administrador inicial
-- Nota: Este es un ejemplo de cómo insertar un usuario administrador
-- Primero necesitarías crear el usuario en la tabla auth.users y luego vincularlo aquí
-- El password se maneja a través de Supabase Auth, no se almacena en esta tabla

-- Ejemplo de cómo se vería la inserción (descomenta y ajusta según sea necesario):
/*
-- Primero crear el usuario en auth.users (esto normalmente se haría a través de la API de autenticación)
-- Luego insertar en la tabla employees:
INSERT INTO employees (
  id, 
  email, 
  full_name, 
  role,
  phone,
  department,
  position,
  company_id  -- Asegúrate de que este ID exista en la tabla companies
) VALUES (
  '00000000-0000-0000-0000-000000000001', -- Este debe ser el mismo ID que en auth.users
  'admin@constructora.com',
  'Administrador del Sistema',
  'company_admin',
  '1234567890',
  'Administración',
  'Administrador del Sistema',
  'ID_DE_LA_EMPRESA' -- Reemplaza con un ID de empresa válido
);
*/

-- Nota: Para un entorno de producción, es mejor crear usuarios a través de la interfaz de autenticación de Supabase
-- y luego asignarles roles y permisos a través de las políticas RLS.

-- 12. Configuración inicial de la aplicación
INSERT INTO app_settings (setting_key, setting_value, description) VALUES
  ('app_name', 'Sistema de Tickets - Constructora', 'Nombre de la aplicación'),
  ('company_name', 'Constructora XYZ', 'Nombre de la empresa'),
  ('company_logo', 'https://yfnycmaksvrodshfpbpe.supabase.co/storage/v1/object/public/app/logo.png', 'URL del logo de la empresa'),
  ('default_ticket_priority', 'media', 'Prioridad por defecto para nuevos tickets'),
  ('ticket_timeout_days', '7', 'Días máximos para resolver un ticket'),
  ('notify_on_ticket_update', 'true', 'Notificar a los involucrados cuando se actualice un ticket');

-- 13. Configurar políticas de seguridad RLS (Row Level Security)
-- Políticas para la tabla 'employees'
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los empleados pueden ver su propia información" 
ON employees FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Los administradores pueden gestionar todos los empleados" 
ON employees 
USING (auth.role() = 'authenticated' AND 
       (SELECT role FROM employees WHERE id = auth.uid()) = 'admin');

-- Políticas para la tabla 'tickets'
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los empleados pueden ver sus propios tickets"
ON tickets FOR SELECT
USING (auth.uid() = created_by OR auth.uid() = assigned_to);

CREATE POLICY "Los supervisores pueden ver todos los tickets"
ON tickets FOR SELECT
USING (EXISTS (
  SELECT 1 FROM employees 
  WHERE id = auth.uid() AND role IN ('supervisor', 'admin')
));

CREATE POLICY "Los empleados pueden crear tickets"
ON tickets FOR INSERT
WITH CHECK (auth.role() = 'authenticated' AND created_by = auth.uid());

CREATE POLICY "Los empleados pueden actualizar sus propios tickets"
ON tickets FOR UPDATE
USING (auth.uid() = created_by)
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Los supervisores pueden actualizar cualquier ticket"
ON tickets FOR UPDATE
USING (EXISTS (
  SELECT 1 FROM employees 
  WHERE id = auth.uid() AND role IN ('supervisor', 'admin')
));

-- 14. Configurar Supabase Storage
INSERT INTO storage.buckets (id, name, public) 
VALUES ('ticket_attachments', 'ticket_attachments', true);

-- Políticas para el almacenamiento
CREATE POLICY "Permitir subida de archivos a usuarios autenticados"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'ticket_attachments' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Permitir lectura de archivos públicos"
ON storage.objects FOR SELECT
USING (bucket_id = 'ticket_attachments');

-- 15. Funciones para manejar timestamps automáticos
CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

-- 16. Triggers para actualizar automáticamente las fechas de modificación
CREATE TRIGGER update_employees_modtime
BEFORE UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_tickets_modtime
BEFORE UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_ticket_comments_modtime
BEFORE UPDATE ON ticket_comments
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 17. Función para registrar cambios en los tickets
CREATE OR REPLACE FUNCTION log_ticket_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        -- Registrar cambios de estado
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            INSERT INTO ticket_history (ticket_id, employee_id, action, old_value, new_value)
            VALUES (NEW.id, auth.uid(), 'status_change', OLD.status, NEW.status);
        END IF;
        
        -- Registrar cambios de asignación
        IF OLD.assigned_to IS DISTINCT FROM NEW.assigned_to THEN
            INSERT INTO ticket_history (ticket_id, employee_id, action, old_value, new_value)
            VALUES (
                NEW.id, 
                auth.uid(), 
                'assignment', 
                COALESCE(OLD.assigned_to::text, 'sin asignar'),
                COALESCE(NEW.assigned_to::text, 'sin asignar')
            );
        END IF;
        
        -- Registrar cambios de prioridad
        IF OLD.priority IS DISTINCT FROM NEW.priority THEN
            INSERT INTO ticket_history (ticket_id, employee_id, action, old_value, new_value)
            VALUES (NEW.id, auth.uid(), 'priority_change', OLD.priority, NEW.priority);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 18. Trigger para registrar cambios en los tickets
CREATE TRIGGER track_ticket_changes
AFTER UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION log_ticket_change();

-- 19. Función para notificar cambios en los tickets
CREATE OR REPLACE FUNCTION notify_ticket_update()
RETURNS TRIGGER AS $$
DECLARE
    notification_title TEXT;
    notification_message TEXT;
    affected_users UUID[];
BEGIN
    -- Definir título y mensaje según el tipo de operación
    IF TG_OP = 'INSERT' THEN
        notification_title := 'Nuevo ticket creado';
        notification_message := 'Se ha creado un nuevo ticket: ' || NEW.title;
        
        -- Notificar a los administradores/supervisores
        INSERT INTO notifications (employee_id, title, message, type, related_ticket_id)
        SELECT id, notification_title, notification_message, 'info', NEW.id
        FROM employees
        WHERE role IN ('admin', 'supervisor');
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- Notificar al creador del ticket
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            notification_title := 'Estado actualizado';
            notification_message := 'El estado del ticket #' || NEW.id || ' ha cambiado a: ' || 
                                  CASE NEW.status
                                      WHEN 'abierto' THEN 'Abierto'
                                      WHEN 'en_progreso' THEN 'En progreso'
                                      WHEN 'en_revision' THEN 'En revisión'
                                      WHEN 'resuelto' THEN 'Resuelto'
                                      WHEN 'cerrado' THEN 'Cerrado'
                                  END;
            
            -- Notificar al creador
            IF NEW.created_by != auth.uid() THEN
                INSERT INTO notifications (employee_id, title, message, type, related_ticket_id)
                VALUES (NEW.created_by, notification_title, notification_message, 'info', NEW.id);
            END IF;
            
            -- Notificar al asignado (si es diferente del creador)
            IF NEW.assigned_to IS NOT NULL AND NEW.assigned_to != NEW.created_by AND NEW.assigned_to != auth.uid() THEN
                INSERT INTO notifications (employee_id, title, message, type, related_ticket_id)
                VALUES (NEW.assigned_to, notification_title, notification_message, 'info', NEW.id);
            END IF;
        END IF;
        
        -- Notificar al nuevo asignado
        IF OLD.assigned_to IS DISTINCT FROM NEW.assigned_to AND NEW.assigned_to IS NOT NULL THEN
            notification_title := 'Has sido asignado a un ticket';
            notification_message := 'Has sido asignado al ticket #' || NEW.id || ': ' || NEW.title;
            
            INSERT INTO notifications (employee_id, title, message, type, related_ticket_id)
            VALUES (NEW.assigned_to, notification_title, notification_message, 'info', NEW.id);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 20. Trigger para notificar cambios en los tickets
CREATE TRIGGER notify_ticket_updates
AFTER INSERT OR UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION notify_ticket_update();

-- 21. Función para buscar tickets
CREATE OR REPLACE FUNCTION search_tickets(search_term TEXT)
RETURNS TABLE (
    id INTEGER,
    title TEXT,
    description TEXT,
    status TEXT,
    priority TEXT,
    created_at TIMESTAMPTZ,
    category_name TEXT,
    created_by_name TEXT,
    assigned_to_name TEXT,
    search_rank FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.description,
        t.status,
        t.priority,
        t.created_at,
        tc.name AS category_name,
        e1.name AS created_by_name,
        e2.name AS assigned_to_name,
        ts_rank(
            setweight(to_tsvector('spanish', t.title), 'A') ||
            setweight(to_tsvector('spanish', t.description), 'B') ||
            setweight(to_tsvector('spanish', COALESCE(tc.name, '')), 'C'),
            plainto_tsquery('spanish', search_term)
        ) AS search_rank
    FROM 
        tickets t
        LEFT JOIN ticket_categories tc ON t.category_id = tc.id
        LEFT JOIN employees e1 ON t.created_by = e1.id
        LEFT JOIN employees e2 ON t.assigned_to = e2.id
    WHERE 
        to_tsvector('spanish', 
            COALESCE(t.title, '') || ' ' || 
            COALESCE(t.description, '') || ' ' || 
            COALESCE(tc.name, '')
        ) @@ plainto_tsquery('spanish', search_term)
    ORDER BY 
        search_rank DESC;
END;
$$ LANGUAGE plpgsql;

-- 22. Crear índices para mejorar el rendimiento
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_created_by ON tickets(created_by);
CREATE INDEX idx_tickets_assigned_to ON tickets(assigned_to);
CREATE INDEX idx_tickets_category ON tickets(category_id);
CREATE INDEX idx_ticket_comments_ticket_id ON ticket_comments(ticket_id);
CREATE INDEX idx_ticket_attachments_ticket_id ON ticket_attachments(ticket_id);

-- Índice para búsqueda de texto completo
CREATE INDEX idx_tickets_search ON tickets 
USING GIN (to_tsvector('spanish', COALESCE(title, '') || ' ' || COALESCE(description, '')));

-- 23. Crear vista para el dashboard
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM tickets) AS total_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'abierto') AS open_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'en_progreso') AS in_progress_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'en_revision') AS in_review_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'resuelto') AS resolved_tickets,
    (SELECT COUNT(*) FROM tickets WHERE status = 'cerrado') AS closed_tickets,
    (SELECT COUNT(*) FROM employees) AS total_employees,
    (SELECT COUNT(*) FROM ticket_categories) AS total_categories;
