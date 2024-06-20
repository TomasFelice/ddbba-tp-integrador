USE com2900g09
GO

DROP TABLE IF EXISTS Hospital.MedicoEspecialidad
GO
DROP TABLE IF EXISTS Hospital.DiasPorSede
GO
DROP TABLE IF EXISTS Hospital.Medico
GO
DROP TABLE IF EXISTS Hospital.Especialidad
GO
DROP TABLE IF EXISTS Hospital.SedeDeAtencion
GO

DROP SCHEMA IF EXISTS Hospital
GO

CREATE SCHEMA Hospital
GO

CREATE TABLE Hospital.Especialidad (
    id_especialidad INT IDENTITY(1,1),
    nombre_especialidad VARCHAR(50) UNIQUE,
	CONSTRAINT pk_especialidad PRIMARY KEY CLUSTERED (id_especialidad)
)
GO


CREATE TABLE Hospital.Medico (
    id_medico INT IDENTITY(1,1),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nro_matricula CHAR(10),
	CONSTRAINT pk_medico PRIMARY KEY CLUSTERED (id_medico)
)
GO

/*
    Agregamos esta entidad para poder tener una relación muchos a muchos entre Medico y Especialidad
    Debido a que un medico puede tener varias especialidades
    y una especialidad puede ser ejercida por varios medicos
*/
CREATE TABLE Hospital.MedicoEspecialidad (
    id_medico_especialidad INT IDENTITY(1,1),
    id_medico INT,
    id_especialidad INT,
    CONSTRAINT pk_medico_especialidad PRIMARY KEY CLUSTERED (id_medico_especialidad),
    CONSTRAINT fk_medico_especialidad_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_medico_especialidad_especialidad FOREIGN KEY (id_especialidad) REFERENCES Hospital.Especialidad(id_especialidad) ON DELETE NO ACTION ON UPDATE NO ACTION
)
GO

CREATE TABLE Hospital.SedeDeAtencion (
    id_sede INT IDENTITY(1,1),
    nombre_sede VARCHAR(100),
    direccion_sede VARCHAR(100),
	CONSTRAINT pk_sede PRIMARY KEY CLUSTERED (id_sede)
)
GO

/*
    hora_inicio se refiere a la hora a la que empieza a operar un medico en la sede
    hora_fin se refiere a la hora a la que termina de operar un medico en la sede
*/
CREATE TABLE Hospital.DiasPorSede (
	id_dia_sede INT IDENTITY(1,1),
    id_sede INT NOT NULL,
    id_medico INT NOT NULL,
    dia VARCHAR(9) CHECK (dia IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo')),
    hora_inicio TIME,
    hora_fin TIME,
    estado_turno_inicial INT DEFAULT 1, -- Disponible
	CONSTRAINT pk_dia_sede PRIMARY KEY CLUSTERED (id_dia_sede),
    CONSTRAINT fk_dia_sede_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dia_sede_sede FOREIGN KEY (id_sede) REFERENCES Hospital.SedeDeAtencion(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
