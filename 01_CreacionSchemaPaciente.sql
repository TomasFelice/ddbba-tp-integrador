USE com2900g09
GO

DROP TABLE IF EXISTS Paciente.Usuario
GO
DROP TABLE IF EXISTS Paciente.Estudio
GO
DROP TABLE IF EXISTS Paciente.Pago
GO
DROP TABLE IF EXISTS Paciente.Factura
GO
DROP TABLE IF EXISTS Paciente.Paciente
GO
DROP TABLE IF EXISTS Paciente.Domicilio
GO
DROP SCHEMA IF EXISTS Paciente
GO

CREATE SCHEMA Paciente
GO
CREATE TABLE Paciente.Domicilio (
    id_domicilio INT IDENTITY(1,1),
    direccion VARCHAR(50),
    piso INT DEFAULT NULL, -- Puede que el paciente no viva en un departamento
    departamento CHAR(10) DEFAULT NULL,
    codigo_postal CHAR(10),
    pais VARCHAR(40),
    provincia VARCHAR(50),
    localidad VARCHAR(50),
    fecha_borrado DATETIME DEFAULT NULL, -- Se deja este atributo ya que si se elimina lógicamente el paciente, se deben eliminar todo lo relacionado a él
	CONSTRAINT pk_domicilio PRIMARY KEY CLUSTERED (id_domicilio)
)
GO
CREATE TABLE Paciente.Paciente (
    id_historia_clinica INT IDENTITY(1,1),
    id_domicilio INT DEFAULT NULL,
    nombre VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
    apellido VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    apellido_materno VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
    nro_de_documento INT NOT NULL UNIQUE,
    sexo_biologico CHAR(10) NOT NULL,
    genero CHAR(10) NOT NULL,
    nacionalidad VARCHAR(18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
    foto_de_perfil VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS, --Aquí se insertarán URLS generadas desde otro sistema
    mail VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, -- Lo hacemos not null ya que al paciente le avisamos que está autorizado su estudio por correo
    telefono_fijo CHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT NULL, -- Los dejamoss nulos  ya que en nuestro sistema no nos interesa saber sí o sí el nro de teléfono del paciente
    telefono_de_contacto_alternativo CHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT NULL,
    telefono_laboral CHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT NULL,
    fecha_de_registro DATE DEFAULT GETDATE(),
    fecha_de_actualizacion DATE DEFAULT GETDATE(),
    usuario_actualizacion INT NOT NULL,
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_historia_clinica PRIMARY KEY CLUSTERED (id_historia_clinica),
    CONSTRAINT fk_paciente_domicilio FOREIGN KEY (id_domicilio) REFERENCES Paciente.Domicilio(id_domicilio) ON DELETE NO ACTION ON UPDATE NO ACTION
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
CREATE TABLE Paciente.Estudio (
    id_estudio VARCHAR(25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    id_historia_clinica INT NOT NULL,
    fecha DATE NOT NULL,
    nombre_estudio VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT NULL, -- Se intepreta con la URL al documento. En nuestro sistema delimitamos el ingreso de urls a máx 255 caracteres. Hay otro sistema que acorta las urls para tener ese máx
    imagen_resultado VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT NULL, -- Aquí se insertarán URLS generadas desde otro sistema. En nuestro sistema delimitamos el ingreso de urls a máx 255 caracteres. Hay otro sistema que acorta las urls para tener ese máx
	fecha_borrado DATETIME DEFAULT NULL, -- Se deja este atributo ya que si se elimina lógicamente el paciente, se deben eliminar todo lo relacionado a él
	area VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
    CONSTRAINT pk_estudio PRIMARY KEY CLUSTERED (id_estudio),
    CONSTRAINT fk_estudio_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE TABLE Paciente.Pago (
    id_pago INT IDENTITY(1,1),
    fecha DATE DEFAULT GETDATE(),
    monto DECIMAL(10, 2) NOT NULL,
    fecha_borrado DATETIME DEFAULT NULL, -- Se deja este atributo ya que si se elimina lógicamente el paciente, se deben eliminar todo lo relacionado a él
	CONSTRAINT pk_pago PRIMARY KEY CLUSTERED (id_pago)
)
GO
CREATE TABLE Paciente.Factura (
    id_factura INT IDENTITY(1,1),
    id_pago INT,
    id_estudio VARCHAR(25) NOT NULL,
    id_historia_clinica INT,
    costo_factura DECIMAL(10, 2) NOT NULL,
    porcentaje_pagado DECIMAL(3,2) DEFAULT 0.0, -- Sirve para poder dejar asentado si pagó el porcentaje de la factura o no, se insertar con el SP actualizarAutorizacionEstudios
    fecha_borrado DATETIME DEFAULT NULL, -- Se deja este atributo ya que si se elimina lógicamente el paciente, se deben eliminar todo lo relacionado a él
	CONSTRAINT pk_factura PRIMARY KEY CLUSTERED (id_factura),
    CONSTRAINT fk_factura_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_factura_pago FOREIGN KEY (id_pago) REFERENCES Paciente.Pago(id_pago) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_factura_estudio FOREIGN KEY (id_estudio) REFERENCES Paciente.Estudio(id_estudio) ON DELETE NO ACTION ON UPDATE NO ACTION
)