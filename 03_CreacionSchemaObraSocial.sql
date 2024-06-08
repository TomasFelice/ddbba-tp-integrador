USE com2900g09
GO

CREATE SCHEMA ObraSocial
GO

CREATE OR ALTER TABLE ObraSocial.Prestador (
    id_prestador INT IDENTITY(1,1),
    nombre_prestador VARCHAR(100),
    plan_prestador VARCHAR(50)
	CONSTRAINT pk_prestador PRIMARY KEY CLUSTERED (id_prestador)
)
GO

CREATE OR ALTER TABLE ObraSocial.TipoCobertura (
    id_tipo_cobertura INT IDENTITY(1,1),
    nombre_tipo_cobertura VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT pk_tipo_cobertura PRIMARY KEY CLUSTERED (id_tipo_cobertura)
)
GO

CREATE OR ALTER TABLE ObraSocial.Cobertura (
    id_cobertura INT IDENTITY(1,1),
    id_tipo_cobertura INT NOT NULL,
    id_prestador INT NOT NULL,
    id_historia_clinica INT NOT NULL,
    imagen_de_la_credencial VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    nro_de_socio INT NOT NULL,
    fecha_de_registro DATE DEFAULT GETDATE(),
    borrado_en DATETIME DEFAULT NULL,
	CONSTRAINT pk_cobertura PRIMARY KEY CLUSTERED (id_cobertura),
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES Obrasocial.Prestador(id_prestador) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tipo_cobertura FOREIGN KEY (id_tipo_cobertura) REFERENCES ObraSocial.TipoCobertura(id_tipo_cobertura) ON DELETE CASCADE ON UPDATE CASCADE
)
GO