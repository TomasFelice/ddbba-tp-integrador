USE com2900g09
GO

DROP TABLE IF EXISTS Hospital.Medico_Especialidad
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
    nombre_especialidad VARCHAR(50),
	CONSTRAINT pk_especialidad PRIMARY KEY CLUSTERED (id_especialidad)
)
GO


CREATE TABLE Hospital.Medico (
    id_medico INT IDENTITY(1,1),
    id_especialidad INT NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nro_matricula CHAR(10), -- Nacho: @tomi f no debería ser esta la pk? Tomi: na, no es 100% necesario -- Nacho: mmm acá pasa lo mismo que con Paciente
	CONSTRAINT pk_medico PRIMARY KEY CLUSTERED (id_medico)
   -- REVISAR: CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_especialidad) REFERENCES Hospital.Especialidad(id_especialidad) ON DELETE CASCADE ON UPDATE CASCADE -- Nacho: está fk está bien? Ahí puse la entidad en el diagrama para que veas cómo para mí es la unión
)
GO

/*
    Agregamos esta entidad para poder tener una relación muchos a muchos entre Medico y Especialidad
    Debido a que un medico puede tener varias especialidades
    y una especialidad puede ser ejercida por varios medicos
*/
CREATE TABLE Hospital.MedicoEspecialidad ( -- Nacho: acá no tiene sentido hacer un sp de act y eliminación, no? 
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
    nombre_sede VARCHAR(50),
    direccion_sede VARCHAR(50),
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
	CONSTRAINT pk_dia_sede PRIMARY KEY CLUSTERED (id_dia_sede),
    CONSTRAINT fk_dia_sede_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dia_sede_sede FOREIGN KEY (id_sede) REFERENCES Hospital.SedeDeAtencion(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

--------------------------------------------------
------  INSERCION VALORES DEFINIDOS
--------------------------------------------------

INSERT INTO Hospital.Especialidad (nombre_especialidad)
VALUES
('CLINICA MEDICA'),
('MEDICINA FAMILIAR'),
('ALERGIA'),
('CARDIOLOGIA'),
('DERMATOLOGIA'),
('ENDOCRINOLOGIA'),
('FONOAUDIOLOGIA'),
('GASTROENTEROLOGIA'),
('GINECOLOGIA'),
('HEPATOLOGÍA'),
('KINESIOLOGIA'),
('NEUROLOGIA'),
('NUTRICION'),
('OBSTETRICIA'),
('OFTALMOLOGIA'),
('TRAUMATOLOGIA'),
('UROLOGIA')
