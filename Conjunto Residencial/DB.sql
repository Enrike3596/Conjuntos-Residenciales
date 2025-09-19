-- Elimina la base de datos BIGRADO si ya existe para evitar conflictos
DROP DATABASE IF EXISTS BIGRADO;

-- Crea la base de datos BIGRADO con collation utf8mb4 para soporte completo de Unicode
CREATE DATABASE BIGRADO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Selecciona la base de datos BIGRADO para trabajar en ella
USE BIGRADO;

/* 
 * Tabla de auditoría para registrar todos los cambios importantes en el sistema
 * Registra: qué tabla fue afectada, qué acción se realizó, qué usuario lo hizo y cuándo
 */
CREATE TABLE Auditoria (
    id_auditoria INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,  -- Identificador único del registro de auditoría
    tabla_afectada VARCHAR(100) NOT NULL,                 -- Nombre de la tabla donde ocurrió el cambio
    accion_realizada ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,  -- Tipo de operación realizada
    id_registro_afectado INT NOT NULL,                    -- ID del registro modificado
    datos_anteriores TEXT,                                -- Valores antes del cambio (para UPDATE/DELETE)
    datos_nuevos TEXT,                                    -- Valores nuevos (para INSERT/UPDATE)
    usuario_responsable VARCHAR(100),                     -- Usuario que realizó el cambio
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- Fecha y hora exacta del cambio
    ip_origen VARCHAR(50)                                 -- Dirección IP desde donde se realizó el cambio
) ENGINE=InnoDB;

/*
 * Tabla de roles del sistema
 * Define los diferentes perfiles de usuario y sus permisos
 */
CREATE TABLE Rol (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,           -- ID único del rol
    Nombre_Rol VARCHAR(250) NOT NULL UNIQUE,              -- Nombre del rol (Administrador, Estudiante, etc.)
    Descripcion VARCHAR(250),                             -- Descripción detallada del rol
    Estado_Rol ENUM('A', 'I') DEFAULT 'A',                -- Estado: A(Activo) o I(Inactivo)
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,    -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                        -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                   -- Usuario que actualizó por última vez
    INDEX idx_estado_rol (Estado_Rol),                    -- Índice para búsquedas por estado
    INDEX idx_fecha_creacion (fecha_creacion),            -- Índice para búsquedas por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion)   -- Índice para búsquedas por fecha de actualización
) ENGINE=InnoDB;


INSERT INTO Rol (Nombre_Rol, Descripcion, Estado_Rol, usuario_creacion) VALUES 
('Administrador', 'Acceso total al sistema', 'A', 'admin'),
('Profesional de apoyo', 'Gestiona programas y convocatorias', 'A', 'admin'),
('Estudiante', 'Usuario estudiante que aplica a intercambios', 'A', 'admin');


/*
 * Tabla de usuarios del sistema
 * Contiene toda la información de las personas que interactúan con el sistema
 */
CREATE TABLE Usuario (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,           -- ID único del usuario
    Tipo_Identificacion VARCHAR(50),                      -- Tipo de documento (CC, TI, Pasaporte)
    Numero_Identificacion VARCHAR(20) UNIQUE,             -- Número de identificación único
    Nombres VARCHAR(100) NOT NULL,                        -- Nombres del usuario
    Apellidos VARCHAR(100) NOT NULL,                      -- Apellidos del usuario
    Fecha_Nacimiento DATE,                                -- Fecha de nacimiento
    Lugar_Nacimiento VARCHAR(100),                        -- Ciudad/País de nacimiento
    Nacionalidad VARCHAR(100),                            -- Nacionalidad del usuario
    Direccion VARCHAR(250),                               -- Dirección de residencia
    Ciudad VARCHAR(100),                                  -- Ciudad de residencia
    Departamento VARCHAR(100),                            -- Departamento/Estado de residencia
    Telefono VARCHAR(20),                                 -- Teléfono de contacto
    Correo_Electronico VARCHAR(100) UNIQUE,               -- Correo electrónico único
    Genero ENUM('Masculino', 'Femenino', 'Otro'),         -- Género del usuario
    Clave_hash VARCHAR(255) NOT NULL,                     -- Contraseña encriptada
    Estado_usuario ENUM('A', 'I') DEFAULT 'A',            -- Estado: A(Activo) o I(Inactivo)
    Foto_Perfil VARCHAR(250),                             -- Ruta de la foto de perfil
    Rol_usuario INT UNSIGNED,                             -- Rol asignado al usuario (FK a Rol)
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,    -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                        -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                   -- Usuario que actualizó por última vez
    token_recuperacion VARCHAR(255) DEFAULT NULL,
    token_expiracion DATETIME DEFAULT NULL,
    intentos_recuperacion INT DEFAULT 0,
    ultimo_intento_recuperacion DATETIME DEFAULT NULL,
    INDEX idx_token_recuperacion (token_recuperacion),          -- Índice para búsquedas por token de recuperación
    INDEX idx_token_expiracion (token_expiracion),
    INDEX idx_estado_usuario (Estado_usuario),            -- Índice para búsquedas por estado
    INDEX idx_genero_usuario (Genero),                    -- Índice para búsquedas por género
    INDEX idx_dep_ciudad (Departamento, Ciudad),          -- Índice compuesto para búsquedas por ubicación
    INDEX idx_rol_usuario (Rol_usuario),                  -- Índice para búsquedas por rol
    INDEX idx_fecha_creacion (fecha_creacion),            -- Índice para búsquedas por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion),  -- Índice para búsquedas por fecha de actualización
    CONSTRAINT FK_Rol_usua FOREIGN KEY (Rol_usuario) REFERENCES Rol(id)  -- Relación con tabla Rol
) ENGINE=InnoDB;

/*
 * Tabla de universidades con convenios
 * Registra las instituciones con las que se tienen acuerdos de intercambio
 */
CREATE TABLE Universidad_Convenio (
    id_convenio INT AUTO_INCREMENT PRIMARY KEY,            -- ID único del convenio
    Nombre_Universidad VARCHAR(250) NOT NULL,             -- Nombre de la universidad
    Fecha_Inicio DATE NOT NULL,                           -- Fecha de inicio del convenio
    Fecha_Fin DATE NOT NULL,                              -- Fecha de vencimiento del convenio
    Nombre_Convenio VARCHAR(150) NOT NULL,                -- Nombre específico del convenio
    Nombre_Coordinador_Origen VARCHAR(100),               -- Coordinador en nuestra institución
    Nombre_Coordinador_Destino VARCHAR(100),              -- Coordinador en la universidad externa
    Tipo_Convenio VARCHAR(50) NOT NULL,                   -- Tipo: Marco, Específico, etc.
    Estado_Convenio VARCHAR(50) NOT NULL,                 -- Estado: Activo, Vencido, Renovación
    Pais VARCHAR(100) NOT NULL,                           -- País de la universidad
    ciudad VARCHAR(250) NOT NULL,                         -- Ciudad de la universidad
    id_Documentos BLOB,                                   -- Documentos digitalizados del convenio
    Nombre_Contacto_Universidad_Destino VARCHAR(100),     -- Persona de contacto en la universidad
    Telefono_Universidad_Convenio VARCHAR(20),            -- Teléfono de contacto
    Correo_Universidad_Convenio VARCHAR(100),             -- Correo de contacto
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,    -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                        -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                   -- Usuario que actualizó por última vez
    INDEX idx_id_convenio (id_convenio),                  -- Índice por ID de convenio
    INDEX idx_tipo_convenio (Tipo_Convenio),              -- Índice por tipo de convenio
    INDEX idx_estado_convenio (Estado_Convenio),          -- Índice por estado del convenio
    INDEX idx_pais_uc (Pais),                             -- Índice por país
    INDEX idx_fecha_creacion (fecha_creacion),            -- Índice por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion)   -- Índice por fecha de actualización
) ENGINE=InnoDB;

/*
 * Tabla de programas curriculares
 * Contiene los programas académicos ofrecidos por la institución
 */
CREATE TABLE Programa_Curricular (
    id_Programa_Curricular INT AUTO_INCREMENT PRIMARY KEY,  -- ID único del programa
    Nombre_Programa_Curricular VARCHAR(150) NOT NULL,      -- Nombre completo del programa
    Sede_Programa_Curricular VARCHAR(150) NOT NULL,        -- Sede donde se ofrece el programa
    Facultad_Programa_Curricular VARCHAR(150) NOT NULL,    -- Facultad a la que pertenece
    Nombre_Coordinador_Curricular VARCHAR(100),            -- Nombre del coordinador del programa
    Telefono_Coordinador_Curricular VARCHAR(20),           -- Teléfono del coordinador
    Correo_Coordinador_Curricular VARCHAR(100),            -- Correo del coordinador
    Nivel_formacion VARCHAR(100),
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,     -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                         -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                    -- Usuario que actualizó por última vez
    INDEX idx_id_programa_pc (id_Programa_Curricular),     -- Índice por ID de programa
    INDEX idx_fecha_creacion (fecha_creacion),            -- Índice por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion)   -- Índice por fecha de actualización
) ENGINE=InnoDB;

/*
 * Tabla de convocatorias de intercambio
 * Registra las oportunidades de movilidad académica disponibles
 */
CREATE TABLE Convocatoria_Intercambio (
    id_Convocatoria INT AUTO_INCREMENT PRIMARY KEY,        -- ID único de la convocatoria
    Nombre_convocatoria VARCHAR(250) NOT NULL,            -- Nombre descriptivo de la convocatoria
    id_Universidad_Convenio INT,                          -- Universidad destino (FK)
    Pais VARCHAR(100) NOT NULL,                           -- País de la universidad destino
    Descripcion_Oferta VARCHAR(200),                      -- Descripción de la oportunidad
    Fecha_Inicio DATE NOT NULL,                           -- Fecha de apertura de la convocatoria
    Fecha_Fin DATE NOT NULL,                              -- Fecha de cierre de la convocatoria
    id_Programa_Curricular INT,                           -- Programa que puede aplicar (FK)
    Nombre_Programa_Curricular VARCHAR(250),              -- Nombre del programa (redundante para reportes)
    Financiacion VARCHAR(150),                            -- Tipo de financiación disponible
    Duracion_Movilidad VARCHAR(100),                      -- Duración estimada del intercambio
    Requisitos VARCHAR(200),                              -- Requisitos para aplicar
    Documentos_Convocatoria VARCHAR(200),                 -- Documentos requeridos
    Proceso_Seleccion VARCHAR(200),                       -- Descripción del proceso de selección
    Cronograma VARCHAR(200),                              -- Cronograma del proceso
    Aclaracion_Reclamacion VARCHAR(200),                  -- Información sobre reclamos
    Fecha_Inicio_Programa DATE,                           -- Fecha de inicio del programa académico
    Mayor_Informacion VARCHAR(200),                       -- Información adicional
    Requisitos_Academicos VARCHAR(200),                   -- Requisitos académicos específicos
    Carta_Aceptacion_Terminos BLOB,                       -- Documento de términos y condiciones
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,    -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                        -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                   -- Usuario que actualizó por última vez
    INDEX idx_id_Universidad_Convenio (id_Universidad_Convenio),  -- Índice por universidad
    INDEX idx_id_programa (id_Programa_Curricular),       -- Índice por programa curricular
    INDEX idx_pais_ci (Pais),                             -- Índice por país
    INDEX idx_fecha_creacion (fecha_creacion),            -- Índice por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion),  -- Índice por fecha de actualización
    FOREIGN KEY (id_Programa_Curricular) REFERENCES Programa_Curricular(id_Programa_Curricular),  -- Relación con Programa
    FOREIGN KEY (id_Universidad_Convenio) REFERENCES Universidad_Convenio(id_convenio)  -- Relación con Universidad
) ENGINE=InnoDB;

/*
 * Tabla de inscripciones a convocatorias
 * Registra las aplicaciones de los estudiantes a los programas de intercambio
 */
CREATE TABLE Inscripcion (
    id INT AUTO_INCREMENT PRIMARY KEY,                    -- ID único de la inscripción
    id_Usuario INT UNSIGNED,                             -- Estudiante que aplica (FK)
    Nombre_Persona_Emergencia VARCHAR(100),              -- Contacto de emergencia
    Parentesco VARCHAR(50),                              -- Parentesco con el contacto
    Telefono VARCHAR(20),                                -- Teléfono de contacto
    Celular VARCHAR(20),                                 -- Celular de contacto
    Correo VARCHAR(100),                                 -- Correo de contacto
    id_Programa_Curricular INT,                          -- Programa actual del estudiante (FK)
    Nombre_Programa_curricular VARCHAR(250),             -- Nombre del programa (redundante para reportes)
    Promedio_Academico DECIMAL(3,2),                     -- Promedio académico (formato: 5.00)
    id_Universidad_Convenio INT,                         -- Universidad destino (FK)
    id_Convocatoria_Intercambio INT,                     -- Convocatoria a la que aplica (FK)
    Ciudad VARCHAR(100),                                 -- Ciudad destino
    Facultad_Universidad_Convenio VARCHAR(100),          -- Facultad en universidad destino
    Programa_Universidad_Convenio VARCHAR(100),          -- Programa en universidad destino
    Modalidad ENUM('Presencial', 'Virtual', 'Híbrida'),  -- Modalidad del intercambio
    Prorroga VARCHAR(50),                                -- Información de prórroga (si aplica)
    Fecha_Inicio DATE,                                   -- Fecha de inicio del intercambio
    Fecha_Fin DATE,                                      -- Fecha de finalización
    Duracion_Meses INT,                                  -- Duración en meses
    Documentos_Doble_Titulacion BLOB,                    -- Documentos para doble titulación
    estado_inscripcion ENUM('Pendiente', 'Aprobada', 'Rechazada', 'Finalizada') DEFAULT 'Pendiente',  -- Estado de la aplicación
    observaciones VARCHAR (255),
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,   -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                       -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                  -- Usuario que actualizó por última vez
    INDEX idx_id_usuario (id_Usuario),                   -- Índice por usuario
    INDEX idx_id_programa (id_Programa_Curricular),      -- Índice por programa
    INDEX idx_id_convenio (id_Universidad_Convenio),     -- Índice por universidad destino
    INDEX idx_id_convocatoria (id_Convocatoria_Intercambio),  -- Índice por convocatoria
    INDEX idx_ciudad (Ciudad),                           -- Índice por ciudad destino
    INDEX idx_modalidad (Modalidad),                     -- Índice por modalidad
    INDEX idx_estado_inscripcion (estado_inscripcion),   -- Índice por estado de inscripción
    INDEX idx_fecha_creacion (fecha_creacion),           -- Índice por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion), -- Índice por fecha de actualización
    CONSTRAINT fk_inscripcion_usuario FOREIGN KEY (id_Usuario) REFERENCES Usuario(id),  -- Relación con Usuario
    CONSTRAINT fk_inscripcion_programa FOREIGN KEY (id_Programa_Curricular) REFERENCES Programa_Curricular(id_Programa_Curricular),  -- Relación con Programa
    CONSTRAINT fk_inscripcion_universidad FOREIGN KEY (id_Universidad_Convenio) REFERENCES Universidad_Convenio(id_convenio),  -- Relación con Universidad
    CONSTRAINT fk_inscripcion_convocatoria FOREIGN KEY (id_Convocatoria_Intercambio) REFERENCES Convocatoria_Intercambio(id_Convocatoria)  -- Relación con Convocatoria
) ENGINE=InnoDB;

/*
 * Tabla de avales del consejo
 * Registra las aprobaciones oficiales para los intercambios
 */
CREATE TABLE Aval_Consejo (
    id INT AUTO_INCREMENT PRIMARY KEY,                    -- ID único del aval
    id_Inscripcion INT,                                  -- Inscripción relacionada (FK)
    id_Usuario INT UNSIGNED,                             -- Usuario que recibe el aval (FK)
    Semestre_Fecha_Inicio DATE,                          -- Fecha inicio del semestre
    Semestre_Fecha_Fin DATE,                             -- Fecha fin del semestre
    id_Universidad_Convenio INT,                         -- Universidad destino (FK)
    Fecha_Aval_Consejo DATE,                             -- Fecha de aprobación del aval
    Numero_Acta_Consejo VARCHAR(50),                     -- Número de acta del consejo
    Nombre_Secretaria_Facultad VARCHAR(100),             -- Secretaria que firma el aval
    Aval_Consejo BLOB,                                   -- Documento digital del aval
    estado_aval ENUM('Pendiente', 'Aprobado', 'Rechazado') DEFAULT 'Pendiente',  -- Estado del aval
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,   -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                       -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                  -- Usuario que actualizó por última vez
    INDEX idx_id_inscripcion_ac (id_Inscripcion),        -- Índice por inscripción
    INDEX idx_id_usuario_ac (id_Usuario),                -- Índice por usuario
    INDEX idx_id_universidad_ac (id_Universidad_Convenio),  -- Índice por universidad
    INDEX idx_estado_aval (estado_aval),                -- Índice por estado del aval
    INDEX idx_fecha_creacion (fecha_creacion),          -- Índice por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion),  -- Índice por fecha de actualización
    CONSTRAINT fk_aval_inscripcion FOREIGN KEY (id_Inscripcion) REFERENCES Inscripcion(id) ON DELETE CASCADE,  -- Elimina aval si se borra inscripción
    CONSTRAINT fk_aval_usuario FOREIGN KEY (id_Usuario) REFERENCES Usuario(id) ON DELETE SET NULL,  -- Set NULL si se borra usuario
    CONSTRAINT fk_aval_universidad FOREIGN KEY (id_Universidad_Convenio) REFERENCES Universidad_Convenio(id_convenio) ON DELETE SET NULL  -- Set NULL si se borra universidad
) ENGINE=InnoDB;

/*
 * Tabla de seguimiento de intercambios
 * Registra el progreso y documentación de los intercambios en curso
 */
CREATE TABLE Seguimiento_Intercambio (
    id_Seguimiento INT AUTO_INCREMENT PRIMARY KEY,        -- ID único del seguimiento
    id_Usuario INT UNSIGNED,                             -- Usuario en intercambio (FK)
    id_Inscripcion INT,                                  -- Inscripción relacionada (FK)
    Carta_Presentacion LONGBLOB,                         -- Carta de presentación digital
    Carta_Aceptacion LONGBLOB,                           -- Carta de aceptación digital
    Peama_Paes BOOLEAN DEFAULT FALSE,                    -- Indica si es estudiante PEAMA/PAES
    Apoyo_Externo BOOLEAN DEFAULT FALSE,                 -- Indica si recibe apoyo económico externo
    Monto_Pesos DECIMAL(12,2),                           -- Monto de apoyo en pesos colombianos
    Recibo_Pago LONGBLOB,                                -- Recibo de pago digital
    Copia_Seguro_Medico LONGBLOB,                        -- Copia del seguro médico
    Copia_Formato_Llegada LONGBLOB,                      -- Formato de llegada digital
    Semestre VARCHAR(20),                                -- Semestre académico (ej: 2023-2)
    semestre_inicio DATE,                                -- Fecha de inicio del semestre
    semestre_fin DATE,                                   -- Fecha de fin del semestre
    id_convenio_universidad INT,                         -- Universidad convenio (FK)
    fecha_consejo DATE,                                  -- Fecha de consejo que aprobó
    numero_acta VARCHAR(50),                             -- Número de acta de aprobación
    Nombre_Secretaria VARCHAR(100),                      -- Nombre de la secretaria que firmó
    documentos_soporte LONGBLOB,                         -- Otros documentos soporte
    estado_seguimiento ENUM('Activo', 'Finalizado', 'Cancelado') DEFAULT 'Activo',  -- Estado del intercambio
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,   -- Fecha de creación del registro
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  -- Fecha de última actualización
    usuario_creacion VARCHAR(100),                       -- Usuario que creó el registro
    usuario_actualizacion VARCHAR(100),                  -- Usuario que actualizó por última vez
    INDEX idx_id_usuario_si (id_Usuario),                -- Índice por usuario
    INDEX idx_id_inscripcion_si (id_Inscripcion),        -- Índice por inscripción
    INDEX idx_id_convenio (id_convenio_universidad),     -- Índice por universidad convenio
    INDEX idx_estado_seguimiento (estado_seguimiento),   -- Índice por estado de seguimiento
    INDEX idx_fecha_creacion (fecha_creacion),           -- Índice por fecha de creación
    INDEX idx_fecha_actualizacion (fecha_actualizacion), -- Índice por fecha de actualización
    INDEX idx_semestre (Semestre),                       -- Índice por semestre académico
    CONSTRAINT fk_seguimiento_usuario FOREIGN KEY (id_Usuario) REFERENCES Usuario(id) ON DELETE SET NULL,  -- Set NULL si se borra usuario
    CONSTRAINT fk_seguimiento_inscripcion FOREIGN KEY (id_Inscripcion) REFERENCES Inscripcion(id) ON DELETE CASCADE,  -- Elimina seguimiento si se borra inscripción
    CONSTRAINT fk_seguimiento_convenio FOREIGN KEY (id_convenio_universidad) REFERENCES Universidad_Convenio(id_convenio) ON DELETE SET NULL  -- Set NULL si se borra universidad
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Triggers para auditoría

-- Trigger para auditoría en tabla Rol
DELIMITER //
CREATE TRIGGER audit_rol_insert AFTER INSERT ON Rol
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion_realizada, id_registro_afectado, datos_nuevos, usuario_responsable)
    VALUES ('Rol', 'INSERT', NEW.id, CONCAT('Nombre_Rol:', NEW.Nombre_Rol, '|Descripcion:', NEW.Descripcion, '|Estado_Rol:', NEW.Estado_Rol), NEW.usuario_creacion);
END //

CREATE TRIGGER audit_rol_update AFTER UPDATE ON Rol
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion_realizada, id_registro_afectado, datos_anteriores, datos_nuevos, usuario_responsable)
    VALUES ('Rol', 'UPDATE', NEW.id, 
            CONCAT('Nombre_Rol:', OLD.Nombre_Rol, '|Descripcion:', OLD.Descripcion, '|Estado_Rol:', OLD.Estado_Rol),
            CONCAT('Nombre_Rol:', NEW.Nombre_Rol, '|Descripcion:', NEW.Descripcion, '|Estado_Rol:', NEW.Estado_Rol),
            NEW.usuario_actualizacion);
END //

CREATE TRIGGER audit_rol_delete AFTER DELETE ON Rol
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion_realizada, id_registro_afectado, datos_anteriores, usuario_responsable)
    VALUES ('Rol', 'DELETE', OLD.id, 
            CONCAT('Nombre_Rol:', OLD.Nombre_Rol, '|Descripcion:', OLD.Descripcion, '|Estado_Rol:', OLD.Estado_Rol),
            'admin');
END //
DELIMITER ;

-- Trigger para auditoría en tabla Usuario
DELIMITER //
CREATE TRIGGER audit_usuario_insert AFTER INSERT ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion_realizada, id_registro_afectado, datos_nuevos, usuario_responsable)
    VALUES ('Usuario', 'INSERT', NEW.id, 
            CONCAT('Nombres:', NEW.Nombres, '|Apellidos:', NEW.Apellidos, '|Correo:', NEW.Correo_Electronico, '|Rol:', NEW.Rol_usuario),
            NEW.usuario_creacion);
END //

CREATE TRIGGER audit_usuario_update AFTER UPDATE ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion_realizada, id_registro_afectado, datos_anteriores, datos_nuevos, usuario_responsable)
    VALUES ('Usuario', 'UPDATE', NEW.id, 
            CONCAT('Nombres:', OLD.Nombres, '|Apellidos:', OLD.Apellidos, '|Correo:', OLD.Correo_Electronico, '|Rol:', OLD.Rol_usuario),
            CONCAT('Nombres:', NEW.Nombres, '|Apellidos:', NEW.Apellidos, '|Correo:', NEW.Correo_Electronico, '|Rol:', NEW.Rol_usuario),
            NEW.usuario_actualizacion);
END //

CREATE TRIGGER audit_usuario_delete AFTER DELETE ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion_realizada, id_registro_afectado, datos_anteriores, usuario_responsable)
    VALUES ('Usuario', 'DELETE', OLD.id, 
            CONCAT('Nombres:', OLD.Nombres, '|Apellidos:', OLD.Apellidos, '|Correo:', OLD.Correo_Electronico, '|Rol:', OLD.Rol_usuario),
            'admin');
END //
DELIMITER ;

-- Procedimientos almacenados

-- Procedimiento para insertar un nuevo rol
DELIMITER //
CREATE PROCEDURE sp_insertar_rol(
    IN p_nombre_rol VARCHAR(250),
    IN p_descripcion VARCHAR(250),
    IN p_estado ENUM('A', 'I'),
    IN p_usuario VARCHAR(100)
)
BEGIN
    INSERT INTO Rol (Nombre_Rol, Descripcion, Estado_Rol, usuario_creacion, usuario_actualizacion)
    VALUES (p_nombre_rol, p_descripcion, p_estado, p_usuario, p_usuario);
    
    SELECT LAST_INSERT_ID() AS nuevo_id;
END //
DELIMITER ;

-- Procedimiento para actualizar un usuario
DELIMITER //
CREATE PROCEDURE sp_actualizar_usuario(
    IN p_id INT,
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_rol INT,
    IN p_estado ENUM('A', 'I'),
    IN p_usuario VARCHAR(100)
)
BEGIN
    UPDATE Usuario 
    SET Nombres = p_nombres,
        Apellidos = p_apellidos,
        Correo_Electronico = p_correo,
        Rol_usuario = p_rol,
        Estado_usuario = p_estado,
        usuario_actualizacion = p_usuario
    WHERE id = p_id;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END //
DELIMITER ;

-- Procedimiento para obtener usuarios por rol
DELIMITER //
CREATE PROCEDURE sp_obtener_usuarios_por_rol(
    IN p_rol_id INT
)
BEGIN
    SELECT id, CONCAT(Nombres, ' ', Apellidos) AS nombre_completo, Correo_Electronico, Estado_usuario
    FROM Usuario
    WHERE Rol_usuario = p_rol_id
    ORDER BY Apellidos, Nombres;
END //
DELIMITER ;

-- Procedimiento para insertar una nueva convocatoria
DELIMITER //
CREATE PROCEDURE sp_insertar_convocatoria(
    IN p_nombre VARCHAR(250),
    IN p_universidad_id INT,
    IN p_pais VARCHAR(100),
    IN p_descripcion VARCHAR(200),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_programa_id INT,
    IN p_usuario VARCHAR(100)
)
BEGIN
    DECLARE v_nombre_programa VARCHAR(250);
    
    SELECT Nombre_Programa_Curricular INTO v_nombre_programa
    FROM Programa_Curricular
    WHERE id_Programa_Curricular = p_programa_id;
    
    INSERT INTO Convocatoria_Intercambio (
        Nombre_convocatoria, id_Universidad_Convenio, Pais, Descripcion_Oferta,
        Fecha_Inicio, Fecha_Fin, id_Programa_Curricular, Nombre_Programa_Curricular,
        usuario_creacion, usuario_actualizacion
    )
    VALUES (
        p_nombre, p_universidad_id, p_pais, p_descripcion,
        p_fecha_inicio, p_fecha_fin, p_programa_id, v_nombre_programa,
        p_usuario, p_usuario
    );
    
    SELECT LAST_INSERT_ID() AS nuevo_id;
END //
DELIMITER ;

-- Procedimiento para generar reporte de inscripciones por periodo
DELIMITER //
CREATE PROCEDURE sp_reporte_inscripciones_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        i.id,
        CONCAT(u.Nombres, ' ', u.Apellidos) AS estudiante,
        pc.Nombre_Programa_Curricular AS programa_origen,
        uc.Nombre_Universidad AS universidad_destino,
        ci.Nombre_convocatoria AS convocatoria,
        i.Fecha_Inicio,
        i.Fecha_Fin,
        i.estado_inscripcion
    FROM Inscripcion i
    JOIN Usuario u ON i.id_Usuario = u.id
    JOIN Programa_Curricular pc ON i.id_Programa_Curricular = pc.id_Programa_Curricular
    JOIN Universidad_Convenio uc ON i.id_Universidad_Convenio = uc.id_convenio
    JOIN Convocatoria_Intercambio ci ON i.id_Convocatoria_Intercambio = ci.id_Convocatoria
    WHERE i.fecha_creacion BETWEEN p_fecha_inicio AND p_fecha_fin
    ORDER BY i.fecha_creacion DESC;
END //
DELIMITER ;

-- Vistas para reportes comunes

-- Vista para convocatorias activas
CREATE VIEW vw_convocatorias_activas AS
SELECT 
    ci.id_Convocatoria,
    ci.Nombre_convocatoria,
    uc.Nombre_Universidad,
    ci.Pais,
    ci.Fecha_Inicio AS fecha_inicio_convocatoria,
    ci.Fecha_Fin AS fecha_fin_convocatoria,
    pc.Nombre_Programa_Curricular AS programa_destino,
    ci.Fecha_Inicio_Programa,
    ci.Duracion_Movilidad
FROM Convocatoria_Intercambio ci
JOIN Universidad_Convenio uc ON ci.id_Universidad_Convenio = uc.id_convenio
JOIN Programa_Curricular pc ON ci.id_Programa_Curricular = pc.id_Programa_Curricular
WHERE ci.Fecha_Fin >= CURDATE()
ORDER BY ci.Fecha_Inicio;

-- Vista para estudiantes en intercambio
CREATE VIEW vw_estudiantes_intercambio AS
SELECT 
    i.id AS id_inscripcion,
    CONCAT(u.Nombres, ' ', u.Apellidos) AS estudiante,
    u.Correo_Electronico,
    pc.Nombre_Programa_Curricular AS programa_origen,
    uc.Nombre_Universidad AS universidad_destino,
    i.Ciudad,
    i.Pais,
    i.Fecha_Inicio,
    i.Fecha_Fin,
    i.estado_inscripcion
FROM Inscripcion i
JOIN Usuario u ON i.id_Usuario = u.id
JOIN Programa_Curricular pc ON i.id_Programa_Curricular = pc.id_Programa_Curricular
JOIN Universidad_Convenio uc ON i.id_Universidad_Convenio = uc.id_convenio
WHERE i.estado_inscripcion = 'Aprobada' 
AND i.Fecha_Fin >= CURDATE()
ORDER BY i.Fecha_Inicio;

-- Vista para convenios por vencer
CREATE VIEW vw_convenios_por_vencer AS
SELECT 
    id_convenio,
    Nombre_Universidad,
    Nombre_Convenio,
    Tipo_Convenio,
    Fecha_Inicio,
    Fecha_Fin,
    Pais,
    ciudad,
    Estado_Convenio,
    DATEDIFF(Fecha_Fin, CURDATE()) AS dias_para_vencer
FROM Universidad_Convenio
WHERE Fecha_Fin BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 MONTH)
ORDER BY Fecha_Fin;

-- Vista para seguimiento de intercambios
CREATE VIEW vw_seguimiento_intercambios AS
SELECT 
    si.id_Seguimiento,
    CONCAT(u.Nombres, ' ', u.Apellidos) AS estudiante,
    uc.Nombre_Universidad AS universidad_destino,
    i.Fecha_Inicio,
    i.Fecha_Fin,
    si.estado_seguimiento,
    si.semestre,
    CASE WHEN si.Peama_Paes = 1 THEN 'Sí' ELSE 'No' END AS peama_paes,
    CASE WHEN si.Apoyo_Externo = 1 THEN 'Sí' ELSE 'No' END AS apoyo_externo,
    si.Monto_Pesos
FROM Seguimiento_Intercambio si
JOIN Usuario u ON si.id_Usuario = u.id
JOIN Inscripcion i ON si.id_Inscripcion = i.id
JOIN Universidad_Convenio uc ON si.id_convenio_universidad = uc.id_convenio
ORDER BY si.estado_seguimiento, i.Fecha_Fin;

-- Vista para reporte de avales
CREATE VIEW vw_reportes_avales AS
SELECT 
    a.id,
    CONCAT(u.Nombres, ' ', u.Apellidos) AS estudiante,
    pc.Nombre_Programa_Curricular AS programa,
    uc.Nombre_Universidad AS universidad_destino,
    a.Fecha_Aval_Consejo,
    a.Numero_Acta_Consejo,
    a.estado_aval,
    a.fecha_creacion
FROM Aval_Consejo a
JOIN Usuario u ON a.id_Usuario = u.id
JOIN Inscripcion i ON a.id_Inscripcion = i.id
JOIN Programa_Curricular pc ON i.id_Programa_Curricular = pc.id_Programa_Curricular
JOIN Universidad_Convenio uc ON a.id_Universidad_Convenio = uc.id_convenio
ORDER BY a.Fecha_Aval_Consejo DESC;

-- Inserción de datos de prueba

-- Insertar roles
INSERT INTO Rol (Nombre_Rol, Descripcion, Estado_Rol, usuario_creacion) VALUES 
('Administrador', 'Acceso total al sistema', 'A', 'admin'),
('Coordinador', 'Gestiona programas y convocatorias', 'A', 'admin'),
('Estudiante', 'Usuario estudiante que aplica a intercambios', 'A', 'admin'),
('Secretaria', 'Personal administrativo que gestiona documentos', 'A', 'admin'),
('Consejo Facultad', 'Miembros del consejo que aprueban avales', 'A', 'admin');

-- Insertar usuarios
INSERT INTO Usuario (
    Tipo_Identificacion, Numero_Identificacion, Nombres, Apellidos, 
    Fecha_Nacimiento, Lugar_Nacimiento, Nacionalidad, Direccion, 
    Ciudad, Departamento, Telefono, Correo_Electronico, Genero, 
    Clave, Estado_usuario, Rol_usuario, usuario_creacion
) VALUES 
('CC', '123456789', 'Admin', 'Sistema', '1980-01-01', 'Bogotá', 'Colombiana', 'Calle 123', 
'Bogotá', 'Cundinamarca', '3001234567', 'admin@bigrado.edu.co', 'Masculino', 
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'A', 1, 'admin'),

('CC', '987654321', 'María', 'Gómez', '1990-05-15', 'Medellín', 'Colombiana', 'Carrera 45 #12-34', 
'Medellín', 'Antioquia', '3102345678', 'maria.gomez@bigrado.edu.co', 'Femenino', 
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'A', 2, 'admin'),

('TI', '1122334455', 'Carlos', 'Pérez', '1998-08-20', 'Cali', 'Colombiana', 'Avenida 6N #23-45', 
'Cali', 'Valle del Cauca', '3153456789', 'carlos.perez@bigrado.edu.co', 'Masculino', 
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'A', 3, 'admin'),

('CC', '5566778899', 'Ana', 'Rodríguez', '1985-11-30', 'Barranquilla', 'Colombiana', 'Calle 72 #45-67', 
'Barranquilla', 'Atlántico', '3204567890', 'ana.rodriguez@bigrado.edu.co', 'Femenino', 
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'A', 4, 'admin'),

('CC', '9988776655', 'Pedro', 'Martínez', '1975-03-25', 'Bucaramanga', 'Colombiana', 'Carrera 27 #56-78', 
'Bucaramanga', 'Santander', '3175678901', 'pedro.martinez@bigrado.edu.co', 'Masculino', 
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'A', 5, 'admin');

-- Insertar universidades convenio
INSERT INTO Universidad_Convenio (
    Nombre_Universidad, Fecha_Inicio, Fecha_Fin, Nombre_Convenio, 
    Nombre_Coordinador_Origen, Nombre_Coordinador_Destino, Tipo_Convenio, 
    Estado_Convenio, Pais, ciudad, Nombre_Contacto_Universidad_Destino, 
    Telefono_Universidad_Convenio, Correo_Universidad_Convenio, usuario_creacion
) VALUES 
('Universidad de Buenos Aires', '2020-01-15', '2025-01-15', 'Convenio Marco UBA-BIGRADO', 
'Dr. Juan López', 'Prof. Ana García', 'Marco', 'Activo', 'Argentina', 'Buenos Aires', 
'Lic. Carlos Fernández', '+541112345678', 'intercambios@uba.edu.ar', 'admin'),

('Universidad Nacional Autónoma de México', '2019-06-20', '2024-06-20', 'Convenio Específico UNAM-BIGRADO', 
'Dra. Laura Méndez', 'Dr. Roberto Jiménez', 'Específico', 'Activo', 'México', 'Ciudad de México', 
'Mtro. Luis Hernández', '+525512345678', 'movilidad@unam.mx', 'admin'),

('Universidad de Salamanca', '2021-03-10', '2026-03-10', 'Convenio Movilidad USAL-BIGRADO', 
'Dr. Andrés Ramírez', 'Prof. María López', 'Movilidad', 'Activo', 'España', 'Salamanca', 
'Dra. Carmen Sánchez', '+34923123456', 'relaciones.internacionales@usal.es', 'admin'),

('Universidad de Chile', '2018-11-05', '2023-11-05', 'Convenio Doble Titulación UChile-BIGRADO', 
'Dra. Patricia González', 'Dr. Jorge Silva', 'Doble Titulación', 'Por Renovar', 'Chile', 'Santiago', 
'Prof. Alejandro Muñoz', '+56221234567', 'intercambio@uchile.cl', 'admin'),

('Universidad de São Paulo', '2022-02-28', '2027-02-28', 'Convenio Investigación USP-BIGRADO', 
'Dr. Carlos Andrade', 'Dr. Fernando Oliveira', 'Investigación', 'Activo', 'Brasil', 'São Paulo', 
'Dra. Beatriz Souza', '+551112345678', 'cooperacao.internacional@usp.br', 'admin');

-- Insertar programas curriculares
INSERT INTO Programa_Curricular (
    Nombre_Programa_Curricular, Sede_Programa_Curricular, Facultad_Programa_Curricular, 
    Nombre_Coordinador_Curricular, Telefono_Coordinador_Curricular, 
    Correo_Coordinador_Curricular, usuario_creacion
) VALUES 
('Ingeniería de Sistemas', 'Principal', 'Ingeniería', 
'Ing. Roberto Sánchez', '6012345678', 'coor.sistemas@bigrado.edu.co', 'admin'),

('Medicina', 'Principal', 'Ciencias de la Salud', 
'Dr. Luis Mendoza', '6023456789', 'coor.medicina@bigrado.edu.co', 'admin'),

('Derecho', 'Principal', 'Ciencias Jurídicas', 
'Dra. Sandra Pérez', '6034567890', 'coor.derecho@bigrado.edu.co', 'admin'),

('Administración de Empresas', 'Regional', 'Ciencias Económicas', 
'Mg. Carlos Jiménez', '6045678901', 'coor.administracion@bigrado.edu.co', 'admin'),

('Psicología', 'Principal', 'Ciencias Humanas', 
'Dra. Ana Torres', '6056789012', 'coor.psicologia@bigrado.edu.co', 'admin');

-- Insertar convocatorias de intercambio
INSERT INTO Convocatoria_Intercambio (
    Nombre_convocatoria, id_Universidad_Convenio, Pais, Descripcion_Oferta, 
    Fecha_Inicio, Fecha_Fin, id_Programa_Curricular, Nombre_Programa_Curricular, 
    Financiacion, Duracion_Movilidad, Requisitos, Documentos_Convocatoria, 
    Proceso_Seleccion, Fecha_Inicio_Programa, usuario_creacion
) VALUES 
('Movilidad UBA 2023-2', 1, 'Argentina', 'Convocatoria para movilidad estudiantil en la Universidad de Buenos Aires', 
'2023-03-01', '2023-04-30', 1, 'Ingeniería de Sistemas', 'Beca parcial', '1 semestre', 
'Promedio mínimo 4.0, 60% de créditos aprobados', 'Carta de motivación, certificado de notas, carta de recomendación', 
'Evaluación de documentos y entrevista', '2023-08-01', 'admin'),

('Intercambio UNAM 2023', 2, 'México', 'Programa de intercambio académico con la UNAM', 
'2023-01-15', '2023-03-15', 2, 'Medicina', 'Autofinanciado', '1 año', 
'Promedio mínimo 4.2, 70% de créditos aprobados, nivel B2 de español', 
'Certificado de notas, certificado de idiomas, ensayo académico', 
'Comité de selección por facultad', '2023-08-15', 'admin'),

('Movilidad USAL 2024-1', 3, 'España', 'Programa de movilidad con la Universidad de Salamanca', 
'2023-09-01', '2023-10-31', 3, 'Derecho', 'Beca completa', '1 semestre', 
'Promedio mínimo 3.8, 50% de créditos aprobados, nivel B1 de inglés', 
'Carta de motivación, plan de estudios, certificado de idiomas', 
'Evaluación académica y de idiomas', '2024-01-15', 'admin'),

('Doble Titulación UChile 2023', 4, 'Chile', 'Programa de doble titulación con la Universidad de Chile', 
'2023-02-01', '2023-04-30', 4, 'Administración de Empresas', 'Beca parcial', '2 años', 
'Promedio mínimo 4.5, 80% de créditos aprobados', 
'Proyecto de investigación, certificado de notas, carta de recomendación', 
'Evaluación integral por comité binacional', '2023-07-01', 'admin'),

('Investigación USP 2023', 5, 'Brasil', 'Programa de movilidad para investigación en la USP', 
'2023-04-01', '2023-05-31', 5, 'Psicología', 'Beca completa', '6 meses', 
'Promedio mínimo 4.0, proyecto de investigación avalado', 
'Proyecto de investigación, CV, carta del director de investigación', 
'Evaluación por pares académicos', '2023-09-01', 'admin');

-- Insertar inscripciones
INSERT INTO Inscripcion (
    id_Usuario, Nombre_Persona_Emergencia, Parentesco, Telefono, Celular, Correo, 
    id_Programa_Curricular, Nombre_Programa_curricular, Promedio_Academico, 
    id_Universidad_Convenio, id_Convocatoria_Intercambio, Ciudad, 
    Facultad_Universidad_Convenio, Programa_Universidad_Convenio, Modalidad, 
    Fecha_Inicio, Fecha_Fin, Duracion_Meses, estado_inscripcion, usuario_creacion
) VALUES 
(3, 'Luisa Pérez', 'Madre', '601234567', '3001234567', 'luisa.perez@email.com', 
1, 'Ingeniería de Sistemas', 4.2, 1, 1, 'Buenos Aires', 
'Facultad de Ingeniería', 'Ingeniería Informática', 'Presencial', 
'2023-08-01', '2023-12-20', 5, 'Aprobada', 'admin'),

(3, 'Jorge Pérez', 'Padre', '602345678', '3102345678', 'jorge.perez@email.com', 
1, 'Ingeniería de Sistemas', 4.5, 2, 2, 'Ciudad de México', 
'Facultad de Medicina', 'Medicina', 'Presencial', 
'2023-08-15', '2024-06-15', 10, 'Pendiente', 'admin'),

(4, 'Marta Rodríguez', 'Madre', '603456789', '3153456789', 'marta.rodriguez@email.com', 
3, 'Derecho', 4.0, 3, 3, 'Salamanca', 
'Facultad de Derecho', 'Derecho', 'Presencial', 
'2024-01-15', '2024-06-30', 6, 'Aprobada', 'admin'),

(4, 'Carlos Rodríguez', 'Padre', '604567890', '3204567890', 'carlos.rodriguez@email.com', 
4, 'Administración de Empresas', 4.7, 4, 4, 'Santiago', 
'Facultad de Economía y Negocios', 'Administración de Empresas', 'Presencial', 
'2023-07-01', '2025-06-30', 24, 'Rechazada', 'admin'),

(5, 'Sofía Martínez', 'Esposa', '605678901', '3175678901', 'sofia.martinez@email.com', 
5, 'Psicología', 4.3, 5, 5, 'São Paulo', 
'Instituto de Psicología', 'Psicología', 'Presencial', 
'2023-09-01', '2024-02-29', 6, 'Aprobada', 'admin');

-- Insertar avales de consejo
INSERT INTO Aval_Consejo (
    id_Inscripcion, id_Usuario, Semestre_Fecha_Inicio, Semestre_Fecha_Fin, 
    id_Universidad_Convenio, Fecha_Aval_Consejo, Numero_Acta_Consejo, 
    Nombre_Secretaria_Facultad, estado_aval, usuario_creacion
) VALUES 
(1, 3, '2023-08-01', '2023-12-20', 1, '2023-05-15', 123, 
'Dra. Claudia Rojas', 'Aprobado', 'admin'),

(3, 4, '2024-01-15', '2024-06-30', 3, '2023-11-20', 124, 
'Lic. Patricia Gómez', 'Aprobado', 'admin'),

(5, 5, '2023-09-01', '2024-02-29', 5, '2023-06-10', 125, 
'Mg. Laura Fernández', 'Aprobado', 'admin'),

(2, 3, '2023-08-15', '2024-06-15', 2, '2023-05-30', 126, 
'Dra. Claudia Rojas', 'Pendiente', 'admin'),

(4, 4, '2023-07-01', '2025-06-30', 4, '2023-04-25', 127, 
'Lic. Patricia Gómez', 'Rechazado', 'admin');

-- Insertar seguimientos de intercambio
INSERT INTO Seguimiento_Intercambio (
    id_Usuario, id_Inscripcion, Peama_Paes, Apoyo_Externo, Monto_Pesos, 
    Semestre, semestre_inicio, semestre_fin, id_convenio_universidad, 
    fecha_consejo, numero_acta, Nombre_Secretaria, estado_seguimiento, usuario_creacion
) VALUES 
(3, 1, 0, 1, 5000000, '2023-2', '2023-08-01', '2023-12-20', 1, 
'2023-05-15', '123', 'Dra. Claudia Rojas', 'Activo', 'admin'),

(4, 3, 0, 0, 0, '2024-1', '2024-01-15', '2024-06-30', 3, 
'2023-11-20', '124', 'Lic. Patricia Gómez', 'Activo', 'admin'),

(5, 5, 1, 1, 8000000, '2023-2', '2023-09-01', '2024-02-29', 5, 
'2023-06-10', '125', 'Mg. Laura Fernández', 'Activo', 'admin'),

(3, 2, 0, 0, 0, '2023-2', '2023-08-15', '2024-06-15', 2, 
'2023-05-30', '126', 'Dra. Claudia Rojas', 'Cancelado', 'admin'),

(4, 4, 0, 0, 0, '2023-1', '2023-07-01', '2025-06-30', 4, 
'2023-04-25', '127', 'Lic. Patricia Gómez', 'Finalizado', 'admin');



Select * from Programa_Curricular;
INSERT INTO Programa_Curricular (
    Nombre_Programa_Curricular,
    Sede_Programa_Curricular,
    Facultad_Programa_Curricular,
    Nombre_Coordinador_Curricular,
    Telefono_Coordinador_Curricular,
    Correo_Coordinador_Curricular,
    Nivel_formacion,
    usuario_creacion,
    usuario_actualizacion
) VALUES
('Ingeniería de Sistemas', 'Sede Central', 'Facultad de Ingeniería', 'Laura Gómez', '3111234567', 'laura.gomez@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Administración de Empresas', 'Sede Norte', 'Facultad de Ciencias Económicas', 'Carlos Rodríguez', '3122345678', 'carlos.rodriguez@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Derecho', 'Sede Centro', 'Facultad de Derecho y Ciencias Políticas', 'Diana Martínez', '3133456789', 'diana.martinez@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Ingeniería Electrónica', 'Sede Central', 'Facultad de Ingeniería', 'Juan Pérez', '3144567890', 'juan.perez@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Contaduría Pública', 'Sede Sur', 'Facultad de Ciencias Económicas', 'Marta López', '3155678901', 'marta.lopez@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Psicología', 'Sede Norte', 'Facultad de Ciencias Humanas', 'Andrés Torres', '3166789012', 'andres.torres@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Maestría en Educación', 'Sede Central', 'Facultad de Educación', 'Paula Díaz', '3177890123', 'paula.diaz@univ.edu.co', 'Posgrado', 'admin', 'admin'),
('Ingeniería Industrial', 'Sede Central', 'Facultad de Ingeniería', 'Jorge Ruiz', '3188901234', 'jorge.ruiz@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Licenciatura en Matemáticas', 'Sede Norte', 'Facultad de Ciencias Exactas', 'Luisa Mejía', '3199012345', 'luisa.mejia@univ.edu.co', 'Pregrado', 'admin', 'admin'),
('Doctorado en Ciencias Sociales', 'Sede Central', 'Facultad de Ciencias Sociales', 'Camilo Herrera', '3200123456', 'camilo.herrera@univ.edu.co', 'Doctorado', 'admin', 'admin');