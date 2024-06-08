USE com2900g09
GO

CREATE SCHEMA Turno
GO

CREATE OR ALTER TABLE Turno.EstadoTurno (
    id_estado INT IDENTITY(1,1),
    nombre_estado VARCHAR(10) NOT NULL UNIQUE,
	CONSTRAINT pk_estado PRIMARY KEY CLUSTERED (id_estado)
)
GO

CREATE OR ALTER TABLE Turno.TipoTurno (
    id_tipo_turno INT IDENTITY(1,1),
    nombre_tipo_turno VARCHAR(10) NOT NULL,
	CONSTRAINT pk_tipo_turno PRIMARY KEY CLUSTERED (id_tipo_turno)
)
GO

CREATE OR ALTER TABLE Turno.ReservaTurnoMedico (
    id_turno INT IDENTITY(1,1),
	id_historia_clinica INT NOT NULL,
    id_medico_especialidad INT NOT NULL,
    id_sede INT NOT NULL,
    id_estado_turno INT,
    id_tipo_turno INT,
    fecha DATE,
    hora TIME,
	fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_turno PRIMARY KEY CLUSTERED (id_turno),
    CONSTRAINT fk_estado_turno FOREIGN KEY (id_estado_turno) REFERENCES Turnos.EstadoTurno(id_estado) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tipo_turno FOREIGN KEY (id_tipo_turno) REFERENCES Turnos.TipoTurno(id_tipo_turno) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Paciente.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_medico_especialidad) REFERENCES Hospital.Medico_Especialidad(id_medico_especialidad) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sede FOREIGN KEY (id_sede) REFERENCES Hospital.SedeDeAtencion(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

--------------------------------------------------
------  INSERCION VALORES DEFINIDOS
--------------------------------------------------
INSERT INTO Turno.EstadoTurno (nombre_estado)
VALUES ('Disponible'), ('Reservado'), ('Cancelado'), ('Atendido'), ('Ausente')
GO

INSERT INTO Turno.TipoTurno (nombre_estado)
VALUES ('Presencial'), ('Virtual')
GO