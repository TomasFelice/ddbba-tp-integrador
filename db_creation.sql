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

-- Nacho: En realidad el CHAR es cuando tenés un tipo de dato fijo. 
-- Ejemplo: sé que mi código se compone de 5 valores alfanumérico, no importa cómo.
--  Con un nombre, apellido, correo no es así
--

-- Creo que en vez de DATE nos conviene usar DATETIME para tener la referencia de H, M y S
-- Nacho: no sé en cuáles. Por ahí en algún turno no vendría mal


CREATE DATABASE com2900g09
GO

USE com2900g09
GO

CREATE SCHEMA ddbba
GO

CREATE TABLE ddbba.Prestador (
    id_prestador INT IDENTITY(1,1) PRIMARY KEY,
    nombre_prestador VARCHAR(100),
    plan_prestador VARCHAR(50)
)
GO

CREATE TABLE ddbba.Cobertura (
    id_cobertura INT IDENTITY(1,1) PRIMARY KEY,
    id_prestador INT,
    imagen_de_la_credencial VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    nro_de_socio INT,
    fecha_de_registro DATE,
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)
GO

CREATE TABLE ddbba.Paciente (
    id_historia_clinica INT IDENTITY(1,1) PRIMARY KEY,
    id_cobertura INT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50), -- Np creo que sea necesario -- Nacho: lo dice el diagrama, por eso lo dejé
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(25),
    nro_de_documento INT UNIQUE NOT NULL,
    sexo_biologico CHAR(1),
    genero CHAR(1),
    nacionalidad CHAR(18),
    foto_de_perfil VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    mail VARCHAR(100),
    telefono_fijo CHAR(15),
    telefono_de_contacto_alternativo CHAR(15),
    telefono_laboral CHAR(15),
    fecha_de_registro DATE NOT NULL,
    fecha_de_actualizacion DATE,
    usuario_actualizacion DATE,
    CONSTRAINT fk_cobertura FOREIGN KEY (id_cobertura) REFERENCES ddbba.Cobertura(id_cobertura)
)
GO

CREATE TABLE ddbba.Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nro_de_documento INT NOT NULL,
    contrasenia VARCHAR(255),
    fecha_de_creacion DATE,
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Domicilio (
    id_domicilio INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento_paciente INT NOT NULL,
    calle VARCHAR(50),
    numero INT,
    piso int, -- es texto o es numero? yo me imagino: Piso 1 por ej. --- Nacho: lo podemos considerar como int, está bien
    departamento CHAR(10), -- testo o unmero? yo me imagino: dpto 2 por ej o dpto A por ej
    codigo_postal CHAR(10),
    pais VARCHAR(40),
    provincia VARCHAR(50),
    localidad VARCHAR(50),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Estudio (
    id_estudio INT IDENTITY(1,1) PRIMARY KEY,
    nro_documento_paciente INT NOT NULL,
    fecha DATE,
    nombre_estudio VARCHAR(50) NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado BIT DEFAULT 0,
    imagen_resultado VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Pago (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    monto NUMERIC(10, 2)
)
GO

CREATE TABLE ddbba.Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    id_pago INT,
    dni_paciente INT,
    costo_factura NUMERIC(10, 2),
    CONSTRAINT fk_pago FOREIGN KEY (id_pago) REFERENCES ddbba.Pago(id_pago),
    CONSTRAINT fk_paciente FOREIGN KEY (dni_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.AlianzaComercial (
    id_alianza INT IDENTITY(1,1) PRIMARY KEY,
    id_prestador INT NOT NULL,
    nombre --Aquí se insertarán URLS generadas desde otro sistema(50),
    estado BIT DEFAULT 0, -- este tipo de dato nunca lo vi. No dejamos int mejor?
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)
GO

CREATE TABLE ddbba.EstadoTurno (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado VARCHAR(9) NOT NULL
)
GO

CREATE TABLE ddbba.TipoTurno (
    id_tipo_turno INT IDENTITY(1,1) PRIMARY KEY,
    nombre_del_tipo_de_turno VARCHAR(10) NOT NULL
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
    nombre_especialidad VARCHAR(50)
)

CREATE TABLE ddbba.Medico (
    id_medico INT IDENTITY(1,1) PRIMARY KEY,
    id_especialidad INT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nro_matricula CHAR(10),
    CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES ddbba.Especialidad(id_especialidad)
)
GO

CREATE TABLE ddbba.SedeDeAtencion (
    id_sede INT IDENTITY(1,1) PRIMARY KEY,
    nombre_de_la_sede VARCHAR(50),
    direccion_sede VARCHAR(50)
)
GO

CREATE TABLE ddbba.Dias_x_sede (
    id_sede INT,
    id_medico INT,
    dia VARCHAR(9),
    hora_inicio TIME,
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES ddbba.Medico(id_medico),
    CONSTRAINT fk_sede FOREIGN KEY (id_sede) REFERENCES ddbba.SedeDeAtencion(id_sede)
)
GO