USE com2900g09
GO

CREATE SCHEMA Hospital
GO

CREATE TABLE Hospital.Especialidad (
    id_especialidad INT IDENTITY(1,1),
    nombre_especialidad VARCHAR(50),
	CONSTRAINT pk_especialidad PRIMARY KEY CLUSTERED (id_especialidad),
)


CREATE TABLE Hospital.Medico (
    id_medico INT IDENTITY(1,1),
    id_especialidad INT NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nro_matricula CHAR(10), -- Nacho: @tomi f no debería ser esta la pk?
	CONSTRAINT pk_medico PRIMARY KEY CLUSTERED (id_medico),
    CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES Hospital.Especialidad(id_especialidad) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

/*
    Agregamos esta entidad para poder tener una relación muchos a muchos entre Medico y Especialidad
    Debido a que un medico puede tener varias especialidades
    y una especialidad puede ser ejercida por varios medicos
*/
CREATE OR ALTER TABLE Hospital.Medico_Especialidad (
    id_medico_especialidad INT IDENTITY(1,1),
    id_medico INT,
    id_especialidad INT,
    CONSTRAINT pk_medico_especialidad PRIMARY KEY CLUSTERED (id_medico_especialidad),
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES Hospital.Especialidad(id_especialidad) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE OR ALTER TABLE Hospital.SedeDeAtencion (
    id_sede INT IDENTITY(1,1),
    nombre_sede VARCHAR(50),
    direccion_sede VARCHAR(50),
	CONSTRAINT pk_sede PRIMARY KEY CLUSTERED (id_sede)
)
GO

/*
    hora_inicio se refiere a la hora a la que empieza a operar un medico en la sede
    hora_fin se refiere a la hora a la que termina de operar un medico en la sede
*/
CREATE OR ALTER TABLE Hospital.DiasPorSede (
	id_dia_sede INT IDENTITY(1,1),
    id_sede INT NOT NULL,
    id_medico INT NOT NULL,
    dia VARCHAR(9) CHECK (dia IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo')) UNIQUE
    hora_inicio TIME,
    hora_fin TIME,
	CONSTRAINT pk_dia_sede PRIMARY KEY CLUSTERED (id_dia_sede),
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sede FOREIGN KEY (id_sede) REFERENCES Hospital.SedeDeAtencion(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
)
GO