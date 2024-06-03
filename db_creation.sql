-- ## CONVENCIONES ##

-- DB: com2900g09
-- SCHEMA: ddbba
-- TABLAS: UpperCamelCase 
-- CAMPOS: camel_case

-- Falta revisar con profundidad los tipos de datos
-- y valores por defecto

-- Cambie la mayoria de los VARCHAR po CHAR para evitar gastar memoria de mas innecesariamente
-- Esto guiandome de lo que dijo jair en una clase de que VARCHAR reserva memoria de mas
-- por las dudas

-- Nacho: En realidad el CHAR es cuando tenés un tipo de dato fijo. 
-- Ejemplo: sé que mi código se compone de 5 valores alfanumérico, no importa cómo.
--  Con un nombre, apellido, correo no es así

-- TOMI: Oka, dejemoslo como varcchar todo eso entonces
--

-- Creo que en vez de DATE nos conviene usar DATETIME para tener la referencia de H, M y S
-- Nacho: no sé en cuáles. Por ahí en algún turno no vendría mal


CREATE DATABASE com2900g09
GO

USE com2900g09
GO

CREATE SCHEMA ddbba
GO

CREATE TABLE ddbba.Prestador (
    id_prestador INT IDENTITY(1,1),
    nombre_prestador VARCHAR(100),
    plan_prestador VARCHAR(50)
	CONSTRAINT pk_prestador PRIMARY KEY CLUSTERED (id_prestador)
)
GO

CREATE TABLE ddbba.Cobertura (
    id_cobertura INT IDENTITY(1,1),
    id_prestador INT,
    imagen_de_la_credencial VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    nro_de_socio INT,
    fecha_de_registro DATE,
	CONSTRAINT pk_cobertura PRIMARY KEY CLUSTERED (id_cobertura),
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)
GO

CREATE TABLE ddbba.Paciente (
    id_historia_clinica INT IDENTITY(1,1),
    id_cobertura INT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(25),
    nro_de_documento INT UNIQUE NOT NULL,
    sexo_biologico CHAR(1),
    genero CHAR(1),
    nacionalidad VARCHAR(18),
    foto_de_perfil VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    mail VARCHAR(100),
    telefono_fijo CHAR(15),
    telefono_de_contacto_alternativo CHAR(15),
    telefono_laboral CHAR(15),
    fecha_de_registro DATE NOT NULL,
    fecha_de_actualizacion DATE,
    usuario_actualizacion DATE,
	CONSTRAINT pk_historia_clinica PRIMARY KEY CLUSTERED (id_historia_clinica),
    CONSTRAINT fk_cobertura FOREIGN KEY (id_cobertura) REFERENCES ddbba.Cobertura(id_cobertura),
    CONSTRAINT fk_cobertura FOREIGN KEY (id_cobertura) REFERENCES ddbba.Cobertura(id_cobertura)
)
GO

CREATE TABLE ddbba.turnoAsignado( -- Sirve para ver la lista de turnos que ya tiene asignado. La reserva del turno es un proceso intermedio a tenerlo asignado
    id_turno_asignado INT IDENTITY(1,1),
    nro_de_documento_paciente INT NOT NULL,
    id_prestador INT NOT NULL,
    id_estado_turno INT,
    fecha DATE,
    hora TIME,
    direccion VARCHAR(100), --POSIBLE UNION CON SEDE
	CONSTRAINT pk_turno_asignado PRIMARY KEY CLUSTERED (id_turno_asignado),
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)

GO

CREATE TABLE ddbba.Usuario (
    id_usuario INT IDENTITY(1,1),
    nro_de_documento INT NOT NULL,
    contrasenia VARCHAR(255),
    fecha_de_creacion DATE,
	CONSTRAINT pk_usuario PRIMARY KEY CLUSTERED (id_usuario),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_de_documento) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Domicilio (
    id_domicilio INT IDENTITY(1,1),
    nro_documento_paciente INT NOT NULL,
    calle VARCHAR(50),
    numero INT,
    piso int, -- es texto o es numero? yo me imagino: Piso 1 por ej. --- Nacho: lo podemos considerar como int, está bien
    departamento CHAR(10), -- testo o unmero? yo me imagino: dpto 2 por ej o dpto A por ej
    codigo_postal CHAR(10),
    pais VARCHAR(40),
    provincia VARCHAR(50),
    localidad VARCHAR(50),
	CONSTRAINT pk_domicilio PRIMARY KEY CLUSTERED (id_domicilio),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Estudio (
    id_estudio INT IDENTITY(1,1),
    nro_documento_paciente INT NOT NULL,
    fecha DATE,
    nombre_estudio VARCHAR(50) NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado BIT DEFAULT 0,
    imagen_resultado VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
	CONSTRAINT pk_estudio PRIMARY KEY CLUSTERED (id_estudio),
    CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.Pago (
    id_pago INT IDENTITY(1,1),
    fecha DATE,
    monto NUMERIC(10, 2),
	CONSTRAINT pk_pago PRIMARY KEY CLUSTERED (id_pago),
)
GO

CREATE TABLE ddbba.Factura (
    id_factura INT IDENTITY(1,1),
    id_pago INT,
    dni_paciente INT,
    costo_factura NUMERIC(10, 2),
	CONSTRAINT pk_factura PRIMARY KEY CLUSTERED (id_factura),
    CONSTRAINT fk_pago FOREIGN KEY (id_pago) REFERENCES ddbba.Pago(id_pago),
    CONSTRAINT fk_paciente FOREIGN KEY (dni_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.AlianzaComercial (
    id_alianza INT IDENTITY(1,1),
    id_prestador INT NOT NULL,
    nombre VARCHAR(50),-- Aquí se insertarán URLS generadas desde otro sistema
    estado BIT DEFAULT 0, -- Nacho: este tipo de dato nunca lo vi. No dejamos int mejor?
						  -- Tomi: Bit es como un boolean - 1 o 0. Igual no se por que lo puse, si es habilitado / deshabilitado esta OK
								-- SI es un estado mas variablke (como el de estadoturno) hay q ponerle int y vincularlo con el id del estado
	CONSTRAINT id_alianza PRIMARY KEY CLUSTERED (id_alianza),
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES ddbba.Prestador(id_prestador)
)
GO

CREATE TABLE ddbba.EstadoTurno (
    id_estado INT IDENTITY(1,1), -- Nacho: acá hay algo que no me gusta, id estado es medio falopa
											 -- Tomi: Para mi esta OK. es para que sea mas facil referenciarlo y hacer joins si es necesario
														-- Es mucho mas eficiente comparar ints que cadenas d texto
    nombre_estado VARCHAR(9) NOT NULL,
	CONSTRAINT pk_estado PRIMARY KEY CLUSTERED (id_estado)
)
GO

CREATE TABLE ddbba.TipoTurno (
    id_tipo_turno INT IDENTITY(1,1),
    nombre_del_tipo_de_turno VARCHAR(10) NOT NULL,
	CONSTRAINT pk_tipo_turno PRIMARY KEY CLUSTERED (id_tipo_turno)
)
GO

CREATE TABLE ddbba.Especialidad (
    id_especialidad INT IDENTITY(1,1),
    nombre_especialidad VARCHAR(50),
	CONSTRAINT pk_especialidad PRIMARY KEY CLUSTERED (id_especialidad),
)

CREATE TABLE ddbba.Medico (
    id_medico INT IDENTITY(1,1),
    id_especialidad INT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nro_matricula CHAR(10),
	CONSTRAINT pk_medico PRIMARY KEY CLUSTERED (id_medico),
    CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES ddbba.Especialidad(id_especialidad)
)
GO

CREATE TABLE ddbba.ReservaTurnoMedico (
    id_turno INT IDENTITY(1,1),
    --nro_documento_paciente INT, -- Nacho: comento esto ya que para un SP tengo que encontrar todos los pacientes que reservaron turno para cancelarlos
									-- Tomi: Podemos agregar el id_historia_clinica (PACIENTE) y con eso va joya creo. Procedo a hacerlo
    fecha DATE,
    hora TIME,
	id_historia_clinica INT,
    id_medico INT NOT NULL,
    id_especialidad INT,
    id_direccion_atencion INT, -- Tomi: Se que esta en el diagrama pero no entiendo a que hace referencia, capaz podriamos poner el id de la sede
    id_estado_turno INT,
    id_tipo_turno INT,
	deleted BIT NOT NULL DEFAULT 0, -- Tomi: Lo agrego para realizar solo borrado logico y mantener un historial de turnos,
									-- Podemos debatir si es mejor hacer una tabla aparte "de auditoria" que mantenga todos los registros
									-- y aca hacer el borrado fisico
	CONSTRAINT pk_turno PRIMARY KEY CLUSTERED (id_turno),
    CONSTRAINT fk_estado_turno FOREIGN KEY (id_estado_turno) REFERENCES ddbba.EstadoTurno(id_estado),
    CONSTRAINT fk_tipo_turno FOREIGN KEY (id_tipo_turno) REFERENCES ddbba.TipoTurno(id_tipo_turno),
	CONSTRAINT fk_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES ddbba.Paciente(id_historia_clinica),
	CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES ddbba.Medico(id_medico),
	CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES ddbba.Especialidad(id_especialidad)
    --CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES ddbba.Paciente(nro_de_documento)
)
GO

CREATE TABLE ddbba.SedeDeAtencion (
    id_sede INT IDENTITY(1,1),
    nombre_de_la_sede VARCHAR(50),
    direccion_sede VARCHAR(50),
	CONSTRAINT pk_sede PRIMARY KEY CLUSTERED (id_sede)
)
GO

CREATE TABLE ddbba.DiasPorSede (
	id_dia_sede INT IDENTITY(1,1),
    id_sede INT,
    id_medico INT,
    dia VARCHAR(9),
    hora_inicio TIME,
	CONSTRAINT pk_dia_sede PRIMARY KEY CLUSTERED (id_dia_sede),
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES ddbba.Medico(id_medico),
    CONSTRAINT fk_sede FOREIGN KEY (id_sede) REFERENCES ddbba.SedeDeAtencion(id_sede)
)
GO

CREATE OR ALTER PROCEDURE ddbba.CrearTurno 
    @idHistoriaClinica INT, 
    @idMedico INT, 
    @idEspecialidad INT, 
    @idDireccionAtencion INT, 
    @idEstadoTurno INT, 
    @idTipoTurno INT
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF EXISTS (SELECT 1 FROM ddbba.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
            AND EXISTS (SELECT 1 FROM ddbba.Medico WHERE id_medico = @idMedico)
            AND EXISTS (SELECT 1 FROM ddbba.Especialidad WHERE id_especialidad = @idEspecialidad)
            AND EXISTS (SELECT 1 FROM ddbba.EstadoTurno WHERE id_estado_turno = @idEstadoTurno)
            AND EXISTS (SELECT 1 FROM ddbba.TipoTurno WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            -- Insertar el registro
            INSERT INTO ddbba.ReservaTurnoMedico (id_historia_clinica, fecha, hora, id_medico, id_especialidad, id_direccion_atencion, id_estado_turno, id_tipo_turno)
            VALUES (@id_historia_clinica, @fecha, @hora, @id_medico, @id_especialidad, @id_direccion_atencion, @id_estado_turno, @id_tipo_turno);
            
            SELECT 'Reserva de turno creada exitosamente.';
        END
        ELSE
            SELECT 'Error: Uno o más identificadores de referencia no existen.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END

/**
	Realiza un borrado lógico de la tabla
	No es lo mismo que cancelar un turno
*/
CREATE OR ALTER PROCEDURE ddbba.EliminarTurno
	@idTurno INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM ddbba.ReservaTurnoMedico WHERE id_turno = @idTurno )
		BEGIN
			UPDATE ddbba.ReservaTurnoMedico
				SET  deleted = 1
				WHERE id_turno = @idTurno
            SELECT 'Reserva de turno eliminada exitosamente.';
		END
        ELSE
			SELECT CONCAT('Error: El turno con id: ', @idTurno, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la reserva de turno.', ERROR_MESSAGE();
    END CATCH

END

CREATE OR ALTER PROCEDURE ddbba.CancelarTurno
	@idTurno INT,
	@idEstadoCancelado INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM ddbba.ReservaTurnoMedico WHERE id_turno = @idTurno )
		BEGIN
			UPDATE ddbba.ReservaTurnoMedico
				SET  id_estado_turno = @idEstadoCancelado
				WHERE id_turno = @idTurno
            SELECT 'Reserva de turno cancelada exitosamente.';
		END
        ELSE
			SELECT CONCAT('Error: El turno con id: ', @idTurno, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al cancelar la reserva de turno.', ERROR_MESSAGE();
    END CATCH

END

-- Nacho: Tenemos que ver en esto que si hay estudios en progreso, esto tampoco se autorice, no? Esto está en el alcance?
--

CREATE OR ALTER PROCEDURE ddbba.ActualizarAlianzasYTurnos(@idPrestador INT, @nuevoEstado BIT)
AS
BEGIN

    UPDATE ddbba.AlianzaComercial
    SET estado = @nuevoEstado
    WHERE id_prestador = @idPrestador


    IF @nuevoEstado = 0 --CANCELO LOS TURNOS QUE ESTÁN RESERVADOS POR EL PACIENTE Y LOS VUELVO DISPONBILES EN LA RESERVA PARA OTRA PERSONA
    BEGIN

        DECLARE @id_estado_cancelado INT
        SET @id_estado_cancelado = SELECT id_estado FROM ddbba.EstadoTurno
                                    WHERE nombre_estado = 'Cancelado'

        DECLARE @id_estado_disponible INT
        SET @id_estado_disponible = SELECT id_estado FROM ddbba.EstadoTurno
                                    WHERE nombre_estado = 'Disponible'

        UPDATE ddbba.turnoAsignado
        SET id_estado_turno = @id_estado_cancelado
        WHERE id_prestador = @idPrestador
        AND id_estado_turno = 'Disponible'

        UPDATE ddbba.ReservaTurnoMedico
        SET id_estado_turno = @id_estado_disponible
        WHERE id_estado_turno = 'Atendido'

    END

END



CREATE OR ALTER PROCEDURE ddbba.DisponibilizarTurnosSegunMedicoEspecialidadSede(@idMedico INT, @idEspecialidad INT, @SedeAtencion INT) --Deberíamos hacer un SP para disponibilizar las reserva de turnos médicos. 
AS
BEGIN

END -- Nacho: Podemos poner nosotros las reglas de negocio para esto:

--Condiciones para NO contar con el default de turno DISPONIBLE:
-- 1) Todo lo que sea médico de especialidad clínica, podemos poner por default Disponible si es cede Central
-- 2) Podemos decir que tenemos 2 Sedes: Central y secundaria. Si es primaria, default Disponible

-- Tomi : No entiendo por que no tendriamos el turno DISPONIBLE por defecto si no es en la sede Central