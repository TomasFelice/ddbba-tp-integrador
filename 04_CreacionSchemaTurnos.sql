USE com2900g09
GO

DROP TABLE IF EXISTS Turno.ReservaTurnoMedico
GO
DROP TABLE IF EXISTS Turno.TipoTurno
GO
DROP TABLE IF EXISTS Turno.EstadoTurno
GO
DROP SCHEMA IF EXISTS Turno
GO

CREATE SCHEMA Turno
GO

CREATE TABLE Turno.EstadoTurno (
    id_estado INT IDENTITY(1,1),
    nombre_estado VARCHAR(10) NOT NULL UNIQUE,
	CONSTRAINT pk_estado PRIMARY KEY CLUSTERED (id_estado)
)
GO

CREATE TABLE Turno.TipoTurno (
    id_tipo_turno INT IDENTITY(1,1),
    nombre_tipo_turno VARCHAR(10) NOT NULL,
	CONSTRAINT pk_tipo_turno PRIMARY KEY CLUSTERED (id_tipo_turno)
)
GO

CREATE TABLE Turno.ReservaTurnoMedico (
    id_turno INT IDENTITY(1,1),
	id_historia_clinica INT NOT NULL,
    id_medico INT NOT NULL,
    id_medico_especialidad INT NOT NULL,
    id_prestador INT NOT NULL,
    id_sede INT NOT NULL,
    id_estado_turno INT DEFAULT 1,
    id_tipo_turno INT,
    fecha DATE,
    hora TIME,
	fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_turno PRIMARY KEY CLUSTERED (id_turno),
    CONSTRAINT fk_turno_estado_turno FOREIGN KEY (id_estado_turno) REFERENCES Turno.EstadoTurno(id_estado) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_turno_tipo_turno FOREIGN KEY (id_tipo_turno) REFERENCES Turno.TipoTurno(id_tipo_turno) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_turno_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_turno_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_turno_medico_especialidad FOREIGN KEY (id_medico_especialidad) REFERENCES Hospital.MedicoEspecialidad(id_medico_especialidad) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_turno_prestador FOREIGN KEY (id_prestador) REFERENCES ObraSocial.Prestador(id_prestador) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_turno_sede FOREIGN KEY (id_sede) REFERENCES Hospital.SedeDeAtencion(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

--------------------------------------------------
------  INSERCION VALORES DEFINIDOS
--------------------------------------------------
INSERT INTO Turno.EstadoTurno (nombre_estado)
VALUES ('Disponible'), ('Reservado'), ('Cancelado'), ('Atendido'), ('Ausente')
GO

INSERT INTO Turno.TipoTurno (nombre_tipo_turno)
VALUES ('Presencial'), ('Virtual')
GO