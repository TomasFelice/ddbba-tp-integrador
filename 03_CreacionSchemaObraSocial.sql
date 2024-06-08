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

CREATE OR ALTER TABLE ObraSocial.Cobertura (
    id_cobertura INT IDENTITY(1,1),
    id_prestador INT,
    imagen_de_la_credencial VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    nro_de_socio INT,
    fecha_de_registro DATE DEFAULT GETDATE(),
	CONSTRAINT pk_cobertura PRIMARY KEY CLUSTERED (id_cobertura),
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES Obrasocial.Prestador(id_prestador) ON DELETE CASCADE ON UPDATE CASCADE
)
GO