-- Elimina la base de datos conjunto_residencial si ya existe para evitar conflictos
DROP DATABASE IF EXISTS conjunto_residencial;

-- Crea la base de datos conjunto_residencial con collation utf8mb4 para soporte completo de Unicode

create database conjunto_residencial CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Usa la base de datos conjunto_residencial
use conjunto_residencial;

CREATE TABLE roles (
    role_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    status ENUM('Active','Inactive') DEFAULT 'Active'
);

select * from roles;

CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    names VARCHAR(150) NOT NULL,
    surnames VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    doc_type VARCHAR(20),
    doc_number VARCHAR(50) UNIQUE,
    status ENUM('Active','Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    role_user BIGINT NOT NULL,
    Clave_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (role_user) REFERENCES roles(role_id)
);

select * from users;

CREATE TABLE owners (
    user_id BIGINT PRIMARY KEY,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

select * from owners;

CREATE TABLE apartments (
    apartment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(10) NOT NULL,
    tower VARCHAR(10),
    owner_id BIGINT NOT NULL,
    status ENUM('Occupied','Available','Maintenance') DEFAULT 'Available',
    FOREIGN KEY (owner_id) REFERENCES owners(user_id)
);
select * from apartments;

CREATE TABLE residents (
    user_id BIGINT PRIMARY KEY,
    apartment_id BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (apartment_id) REFERENCES apartments(apartment_id)
);

select * from residents;


CREATE TABLE visitors (
    user_id BIGINT PRIMARY KEY,
    resident_id BIGINT NOT NULL,
    visit_date DATE NOT NULL,
    checkin_time TIME NOT NULL,
    checkout_time TIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (resident_id) REFERENCES residents(user_id)
);
select * from visitors;

CREATE TABLE security_staff (
    user_id BIGINT PRIMARY KEY,
    shift VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

select * from security_staff;

CREATE TABLE parking_lots (
    parking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_type ENUM('Owner','Resident','Visitor') NOT NULL,
    number VARCHAR(10) NOT NULL,
    user_id BIGINT,
    status ENUM('Occupied','Free','Reserved') DEFAULT 'Free',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
select * from parking_lots;

CREATE TABLE mail_deliveries (
    mail_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    description TEXT NOT NULL,
    user_id BIGINT NOT NULL, -- recipient
    received_date DATE NOT NULL,
    received_by_id BIGINT NOT NULL, -- who received (security staff)
    status ENUM('Pending','Delivered') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (received_by_id) REFERENCES security_staff(user_id)
);
select * from mail_deliveries;

CREATE TABLE common_areas (
    area_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    area_name VARCHAR(100) NOT NULL,
    description TEXT,
    capacity INT,
    available_hours VARCHAR(100),
    status ENUM('Available','Maintenance','Closed') DEFAULT 'Available'
);

select * from common_areas;


CREATE TABLE requests (
    request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    request_type VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL DEFAULT NULL,
    request_status ENUM('Pending','In Progress','Resolved','Rejected') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

select * from requests;

-- 1. Roles
INSERT INTO roles (role_name, status) VALUES
('Administrador', 'Active'),
('Propietario', 'Active'),
('Residente', 'Active'),
('Visitante', 'Active'),
('Seguridad', 'Active');

-- 2. Users (Usuarios)
INSERT INTO users (name, phone, email, doc_type, doc_number, role_id) VALUES
('Juan Pérez', '3001234567', 'juan.perez@email.com', 'CC', '100200300', 2),  -- Propietario
('Juana García', '3019876543', 'juana.garcia@email.com', 'CC', '200300400', 3), -- Residente
('Miguel Rodríguez', '3025551234', 'miguel.rodriguez@email.com', 'CC', '300400500', 4), -- Visitante
('Carlos López', '3034442233', 'carlos.lopez@email.com', 'CC', '400500600', 5), -- Seguridad
('Usuario Admin', '3101112222', 'admin@email.com', 'CC', '500600700', 1); -- Administrador

-- 3. Owners (Propietarios)
INSERT INTO owners (user_id) VALUES
(1); -- Juan Pérez

-- 4. Apartments (Apartamentos)
INSERT INTO apartments (number, tower, owner_id, status) VALUES
('101', 'A', 1, 'Occupied'),
('102', 'A', 1, 'Available');

-- 5. Residents (Residentes)
INSERT INTO residents (user_id, apartment_id) VALUES
(2, 1); -- Juana García vive en Apt 101

-- 6. Visitors (Visitantes)
INSERT INTO visitors (user_id, resident_id, visit_date, checkin_time, checkout_time) VALUES
(3, 2, '2025-09-18', '10:00:00', '12:00:00'); -- Miguel visita a Juana

-- 7. Security Staff (Personal de seguridad)
INSERT INTO security_staff (user_id, shift) VALUES
(4, 'Noche'); -- Carlos López turno noche

-- 8. Parking Lots (Parqueaderos)
INSERT INTO parking_lots (role_type, number, user_id, status) VALUES
('Owner', 'P1', 1, 'Occupied'),
('Resident', 'P2', 2, 'Occupied'),
('Visitor', 'P3', NULL, 'Free');

-- 9. Mail Deliveries (Correspondencias)
INSERT INTO mail_deliveries (description, user_id, received_date, received_by_id, status) VALUES
('Paquete de Amazon', 2, '2025-09-15', 4, 'Pending'),
('Factura de servicios', 1, '2025-09-16', 4, 'Delivered');

-- 10. Common Areas (Áreas comunes)
INSERT INTO common_areas (area_name, description, capacity, available_hours, status) VALUES
('Salón social', 'Espacio para eventos', 50, '08:00-22:00', 'Available'),
('Piscina', 'Piscina al aire libre', 30, '06:00-18:00', 'Maintenance'),
('Zona BBQ', 'Parrillas al aire libre', 20, '10:00-22:00', 'Available');

-- 11. Requests (Solicitudes)  -- adapted for MySQL schema (TIMESTAMP)
INSERT INTO requests (user_id, request_type, description, request_status) VALUES
(2, 'Reparación', 'Cambio de bombilla en el pasillo', 'Pending'),
(1, 'Mantenimiento', 'Revisión de plomería en apartamento 101', 'In Progress'),
(2, 'Reserva', 'Solicitud para reservar el salón social por cumpleaños', 'Resolved');
