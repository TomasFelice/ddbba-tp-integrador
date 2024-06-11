USE com2900g09
GO

DROP TABLE IF EXISTS Paciente.Usuario
GO
DROP TABLE IF EXISTS Paciente.Domicilio
GO
DROP TABLE IF EXISTS Paciente.Estudio
GO
DROP TABLE IF EXISTS Paciente.Pago
GO
DROP TABLE IF EXISTS Paciente.Factura
GO
DROP TABLE IF EXISTS Paciente.Paciente
GO
DROP SCHEMA IF EXISTS Paciente
GO

CREATE SCHEMA Paciente
GO

-- Nacho: amigo, lo de la historia clínica no me suena muy bien todavía. Porque si obtenés el id de eso podés traer info de más del paciente. Con el dni es más fácil identificarlo.
-- Nacho: lo dejo igualmente así hasta que decidamos.
-- Tomi: En el contexto de un hospital, la manera de identifiar una persona es por la historia clinica para mí. Si bien los dos datos sabemos que van a ser únicos, yo prefiero usar la historia clínica. (le agregué la constraint de unique al nro doc)

CREATE TABLE Paciente.Paciente (
    id_historia_clinica INT IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(25) NOT NULL,
    nro_de_documento INT NOT NULL UNIQUE,
    sexo_biologico CHAR(1) NOT NULL,
    genero CHAR(10) NOT NULL,
    nacionalidad VARCHAR(18) NOT NULL,
    foto_de_perfil VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    mail VARCHAR(100) NOT NULL, -- Lo hacemos not null ya que al paciente le avisamos que está autorizado su estudio por correo
    telefono_fijo CHAR(15) DEFAULT NULL, -- Los dejamoss nulos  ya que en nuestro sistema no nos interesa saber sí o sí el nro de teléfono del paciente
    telefono_de_contacto_alternativo CHAR(15) DEFAULT NULL,
    telefono_laboral CHAR(15) DEFAULT NULL,
    fecha_de_registro DATE DEFAULT GETDATE(),
    fecha_de_actualizacion DATE DEFAULT GETDATE(),
    usuario_actualizacion INT NOT NULL,
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_historia_clinica PRIMARY KEY CLUSTERED (id_historia_clinica)
)
GO
CREATE TABLE Paciente.Usuario (
    id_usuario INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasenia VARCHAR(255) NOT NULL,
    fecha_de_creacion DATE DEFAULT GETDATE(),
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_usuario PRIMARY KEY CLUSTERED (id_usuario),
    CONSTRAINT fk_usuario_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE TABLE Paciente.Domicilio (
    id_domicilio INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    calle VARCHAR(50),
    numero INT,
    piso INT DEFAULT NULL, -- Puede que el paciente no viva en un departamento
    departamento CHAR(10) DEFAULT NULL,
    codigo_postal CHAR(10),
    pais VARCHAR(40),
    provincia VARCHAR(50),
    localidad VARCHAR(50),
    fecha_borrado DATETIME DEFAULT NULL, -- Se deja este atributo ya que si se elimina lógicamente el paciente, se deben eliminar todo lo relacionado a él
	CONSTRAINT pk_domicilio PRIMARY KEY CLUSTERED (id_domicilio),
    CONSTRAINT fk_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE TABLE Paciente.Estudio (
    id_estudio INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    fecha DATE NOT NULL,
    nombre_estudio VARCHAR(100) NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado VARCHAR(255) DEFAULT NULL, -- Se intepreta con la URL al documento. En nuestro sistema delimitamos el ingreso de urls a máx 255 caracteres. Hay otro sistema que acorta las urls para tener ese máx
    imagen_resultado VARCHAR(255) DEFAULT NULL, -- Aquí se insertarán URLS generadas desde otro sistema. En nuestro sistema delimitamos el ingreso de urls a máx 255 caracteres. Hay otro sistema que acorta las urls para tener ese máx
	fecha_borrado DATETIME DEFAULT NULL, -- Se deja este atributo ya que si se elimina lógicamente el paciente, se deben eliminar todo lo relacionado a él
	area VARCHAR(50),
    CONSTRAINT pk_estudio PRIMARY KEY CLUSTERED (id_estudio),
    CONSTRAINT fk_estudio_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE TABLE Paciente.Pago (
    id_pago INT IDENTITY(1,1),
    fecha DATE DEFAULT GETDATE(),
    monto DECIMAL(10, 2) NOT NULL,
	CONSTRAINT pk_pago PRIMARY KEY CLUSTERED (id_pago)
)
GO
CREATE TABLE Paciente.Factura (
    id_factura INT IDENTITY(1,1),
    id_pago INT NOT NULL,
    id_estudio INT NOT NULL,
    id_historia_clinica INT,
    costo_factura DECIMAL(10, 2) NOT NULL,
    porcentaje_pagado DECIMAL(3,2) DEFAULT 0.0, -- Sirve para poder dejar asentado si pagó el porcentaje de la factura o no, se insertar con el SP actualizarAutorizacionEstudios
	CONSTRAINT pk_factura PRIMARY KEY CLUSTERED (id_factura),
    CONSTRAINT fk_factura_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_factura_pago FOREIGN KEY (id_pago) REFERENCES Paciente.Pago(id_pago) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_factura_estudio FOREIGN KEY (id_estudio) REFERENCES Paciente.Estudio(id_estudio) ON DELETE NO ACTION ON UPDATE NO ACTION
)