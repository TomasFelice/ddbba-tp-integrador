-- ## CONVENCIONES ##

-- DB: com2900g09
-- SCHEMA: ddbba
-- TABLAS: UpperCamelCase 
-- CAMPOS: camel_case

-- Prefieren usar ingles para los nombres de campos? Yo prefiero ingles

-- Falta revisar con profundidad los tipos de datos
-- y valores por defecto

-- Cambie la mayoria de los VARCHAR po CHAR para evitar gastar memoria de mas innecesariamente
-- Esto guiandome de lo que dijo jair en una clase de que VARCHAR reserva memoria de mas
-- por las dudas

-- Creo que en vez de DATE nos conviene usar DATETIME para tener la referencia de H, M y S


CREATE DATABASE com2900g09
GO

USE com2900g09
GO

CREATE SCHEMA ddbba
GO

CREATE TABLE ddbba.Prestador (
    id_prestador INT IDENTITY(1,1) PRIMARY KEY,
    nombre_prestador CHAR(100),
    plan_prestador CHAR(50)
)
GO

CREATE TABLE ddbba.Cobertura (
    id_cobertura INT IDENTITY(1,1) PRIMARY KEY,
    id_prestador INT,
    imagen_de_la_credencial VARCHAR(255),
    nro_de_socio INT,
    fecha_de_registro DATE,
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)
GO

CREATE TABLE ddbba.Paciente (
    id_historia_clinica INT IDENTITY(1,1) PRIMARY KEY,
    id_cobertura INT,
    nombre CHAR(50) NOT NULL,
    apellido CHAR(50) NOT NULL,
    apellido_materno CHAR(50), -- Np creo que sea necesario
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento CHAR(25),
    nro_de_documento INT UNIQUE NOT NULL,
    sexo_biologico CHAR(1),
    genero CHAR(1),
    nacionalidad CHAR(18),
    foto_de_perfil VARCHAR(255),
    mail CHAR(100),
    telefono_fijo CHAR(15),
    telefono_de_contacto_alternativo CHAR(15),
    telefono_laboral CHAR(15),
    fecha_de_registro DATE NOT NULL,
    fecha_de_actualización DATE,
    usuario_actualización DATE,
    CONSTRAINT fk_cobertura FOREIGN KEY (id_cobertura) REFERENCES ddbba.Cobertura(id_cobertura)
)
GO

CREATE TABLE ddbba.Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nro_de_documento INT NOT NULL,
    contrasenia CHAR(255),
    fecha_de_creacion DATE,
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Domicilio (
    id_domicilio INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento_paciente INT NOT NULL,
    calle CHAR(50),
    numero INT,
    piso CHAR(10), -- es texto o es numero? yo me imagino: Piso 1 por ej
    departamento CHAR(10), -- testo o unmero? yo me imagino: dpto 2 por ej o dpto A por ej
    codigo_postal CHAR(10),
    pais CHAR(40),
    provincia CHAR(50),
    localidad CHAR(50),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Estudio (
    id_estudio INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento_paciente INT NOT NULL,
    fecha DATE,
    nombre_estudio CHAR(50) NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado BIT DEFAULT 0,
    imagen_resultado VARCHAR(255),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Pago (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    monto NUMERIC(10, 2) -- Ajustado para manejar montos monetarios
)
GO

CREATE TABLE ddbba.Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    id_pago INT,
    dni_paciente INT,
    costo_factura NUMERIC(10, 2), -- Ajustado para manejar montos monetarios
    CONSTRAINT fk_pago FOREIGN KEY (id_pago) REFERENCES ddbba.Pago(id_pago),
    CONSTRAINT fk_paciente FOREIGN KEY (dni_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.AlianzaComercial (
    id_alianza INT IDENTITY(1,1) PRIMARY KEY,
    id_prestador INT NOT NULL,
    nombre CHAR(50),
    estado BIT DEFAULT 0,
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)
GO

CREATE TABLE ddbba.EstadoTurno (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado CHAR(9) NOT NULL
)
GO

CREATE TABLE ddbba.TipoTurno (
    id_tipo_turno INT IDENTITY(1,1) PRIMARY KEY,
    nombre_del_tipo_de_turno CHAR(10) NOT NULL
)
GO

CREATE TABLE ddbba.ReservaDeTurnoMedico (
    id_turno INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento_paciente INT,
    fecha DATE,
    hora TIME,
    id_medico INT NOT NULL,
    id_especialidad INT,
    id_direccion_atencion INT,
    id_estado_turno INT,
    id_tipo_turno INT,
    CONSTRAINT fk_estado_turno FOREIGN KEY (id_estado_turno) REFERENCES ddbba.EstadoTurno(id_estado),
    CONSTRAINT fk_tipo_turno FOREIGN KEY (id_tipo_turno) REFERENCES ddbba.TipoTurno(id_tipo_turno),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Especialidad (
    id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_especialidad CHAR(50)
)

CREATE TABLE ddbba.Medico (
    id_medico INT IDENTITY(1,1) PRIMARY KEY,
    id_especialidad INT,
    nombre CHAR(50),
    apellido CHAR(50),
    nro_matricula CHAR(10),
    CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES ddbba.Especialidad(id_especialidad)
)
GO

CREATE TABLE ddbba.SedeDeAtencion (
    id_sede INT IDENTITY(1,1) PRIMARY KEY,
    nombre_de_la_sede CHAR(50),
    direccion_sede CHAR(50)
)
GO

CREATE TABLE ddbba.Dias_x_sede (
    id_sede INT,
    id_medico INT,
    dia CHAR(9),
    hora_inicio TIME,
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES ddbba.Medico(id_medico),
    CONSTRAINT fk_sede FOREIGN KEY (id_sede) REFERENCES ddbba.SedeDeAtencion(id_sede)
)
GO