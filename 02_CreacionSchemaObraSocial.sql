USE com2900g09
GO

DROP TABLE IF EXISTS ObraSocial.Cobertura
GO
DROP TABLE IF EXISTS ObraSocial.Prestador
GO
DROP TABLE IF EXISTS ObraSocial.TipoCobertura
GO

DROP SCHEMA IF EXISTS ObraSocial
GO

CREATE SCHEMA ObraSocial
GO

CREATE TABLE ObraSocial.Prestador (
    id_prestador INT IDENTITY(1,1),
    nombre_prestador VARCHAR(100) NOT NULL,
    plan_prestador VARCHAR(50) NOT NULL,
	CONSTRAINT pk_prestador PRIMARY KEY CLUSTERED (id_prestador),
    CONSTRAINT uq_prestador_nombre_plan UNIQUE (nombre_prestador, plan_prestador)
)
GO

CREATE TABLE ObraSocial.TipoCobertura (
    id_tipo_cobertura INT IDENTITY(1,1),
    nombre_tipo_cobertura VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT pk_tipo_cobertura PRIMARY KEY CLUSTERED (id_tipo_cobertura)
)
GO

CREATE TABLE ObraSocial.Cobertura (
    id_cobertura INT IDENTITY(1,1),
    id_tipo_cobertura INT NOT NULL,
    id_prestador INT NOT NULL,
    id_historia_clinica INT NOT NULL,
    imagen_de_la_credencial VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    nro_de_socio INT NOT NULL,
    fecha_de_registro DATE DEFAULT GETDATE(),
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_cobertura PRIMARY KEY CLUSTERED (id_cobertura),
    CONSTRAINT fk_cobertura_prestador FOREIGN KEY (id_prestador) REFERENCES Obrasocial.Prestador(id_prestador) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cobertura_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cobertura_tipo_cobertura FOREIGN KEY (id_tipo_cobertura) REFERENCES ObraSocial.TipoCobertura(id_tipo_cobertura) ON DELETE CASCADE ON UPDATE CASCADE
)
GO


