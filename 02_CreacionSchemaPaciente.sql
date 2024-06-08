USE com2900g09
GO
CREATE SCHEMA Paciente
GO
CREATE OR ALTER TABLE Paciente.Paciente (
    id_historia_clinica INT IDENTITY(1,1),
    id_cobertura INT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(25) NOT NULL,
    nro_de_documento INT NOT NULL
    sexo_biologico CHAR(1) NOT NULL,
    genero CHAR(1) NOT NULL,
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
	CONSTRAINT pk_historia_clinica PRIMARY KEY CLUSTERED (nro_de_documento),
    CONSTRAINT fk_cobertura FOREIGN KEY (id_cobertura) REFERENCES ObraSocial.Cobertura(id_cobertura) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE OR ALTER TABLE Paciente.Usuario (
    id_usuario INT IDENTITY(1,1),
    nro_de_documento INT NOT NULL,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasenia VARCHAR(255) NOT NULL,
    fecha_de_creacion DATE DEFAULT GETDATE(),
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_usuario PRIMARY KEY CLUSTERED (id_usuario),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES Pacientes.Paciente(nro_de_documento) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE OR ALTER TABLE Paciente.Domicilio (
    id_domicilio INT IDENTITY(1,1),
    nro_de_documento INT NOT NULL,
    calle VARCHAR(50),
    numero INT,
    piso INT DEFAULT NULL, -- Puede que el paciente no viva en un departamento
    departamento CHAR(10) DEFAULT NULL,
    codigo_postal CHAR(10),
    pais VARCHAR(40),
    provincia VARCHAR(50),
    localidad VARCHAR(50),
	CONSTRAINT pk_domicilio PRIMARY KEY CLUSTERED (id_domicilio),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES Pacientes.Paciente(nro_de_documento) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE OR ALTER TABLE Paciente.Estudio (
    id_estudio INT IDENTITY(1,1),
    nro_de_documento INT NOT NULL,
    fecha DATE NOT NULL,
    nombre_estudio VARCHAR(100) NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado VARCHAR(255) DEFAULT NULL, -- Se intepreta con la URL al documento. En nuestro sistema delimitamos el ingreso de urls a máx 255 caracteres. Hay otro sistema que acorta las urls para tener ese máx
    imagen_resultado VARCHAR(255) DEFAULT NULL, -- Aquí se insertarán URLS generadas desde otro sistema. En nuestro sistema delimitamos el ingreso de urls a máx 255 caracteres. Hay otro sistema que acorta las urls para tener ese máx
	CONSTRAINT pk_estudio PRIMARY KEY CLUSTERED (id_estudio),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES Pacientes.Paciente(nro_de_documento) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE OR ALTER TABLE Paciente.Pago (
    id_pago INT IDENTITY(1,1),
    nro_de_documento INT NOT NULL,
    fecha DATE DEFAULT GETDATE(),
    monto DECIMAL(10, 2) NOT NULL,
	CONSTRAINT pk_pago PRIMARY KEY CLUSTERED (id_pago),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES Pacientes.Paciente(nro_de_documento) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE OR ALTER TABLE Paciente.Factura (
    id_factura INT IDENTITY(1,1),
    id_pago INT NOT NULL,
    id_estudio INT NOT NULL,
    nro_de_documento INT,
    costo_factura_inicial DECIMAL(10, 2) NOT NULL,
    costo_adeudado DECIMAL(10,2) NOT NULL,
    porcentaje_pagado DECIMAL(3,2) DEFAULT 0.0, -- Sirve para poder dejar asentado si pagó el porcentaje de la factura o no, se insertar con el SP actualizarAutorizacionEstudios
	CONSTRAINT pk_factura PRIMARY KEY CLUSTERED (id_factura),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES Pacientes.Paciente(nro_de_documento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pago FOREIGN KEY (id_pago) REFERENCES Paciente.Pago(id_pago) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_estudio FOREIGN KEY (id_estudio) REFERENCES Paciente.Estudio(id_estudio) ON DELETE CASCADE ON UPDATE CASCADE
)