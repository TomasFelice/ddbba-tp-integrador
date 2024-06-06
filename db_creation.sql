-- ## CONVENCIONES ##

-- DB: com2900g09
-- SCHEMA: ddbba
-- TABLAS: UpperCamelCase 
-- CAMPOS: camel_case+
-- ROLES: UpperCamelCase

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

--------------------------------------------------
------  CREACION DB
--------------------------------------------------
USE master
GO
DROP DATABASE IF EXISTS com2900g09
GO
CREATE DATABASE com2900g09
GO
USE com2900g09
GO

--------------------------------------------------
------  CREACION ROLES
--------------------------------------------------
-- Definir como los vamos a usar --
-- CREATE ROLE Paciente
-- GO
-- CREATE ROLE Medico
-- GO
-- CREATE ROLE AdministradorGeneral
-- GO
-- CREATE ROLE TecnicoClinico
-- GO
-- CREATE ROLE Administrativo
-- GO

--------------------------------------------------
------  CREACION SCHEMAS
--------------------------------------------------
CREATE SCHEMA ObraSocial
GO
CREATE SCHEMA Pacientes
GO
CREATE SCHEMA Hospital
GO
CREATE SCHEMA Turnos

--------------------------------------------------
------  CREACION TABLAS
--------------------------------------------------

/*
    * Colocamos ON DELETE CASCADE y ON UPDATE CASCADE en las relaciones para que si se elimina un registro padre, se eliminen los registros hijos
    * Definimos manualmente las CONSTRAINTS para poder nombrarlas y tener un mejor control de las mismas
    * Todo el manejo de imagenes se hará con URLS generadas desde otro sistema. No se almacenarán imagenes en la base de datos
    * El borrado lógico se realiza registrando la fecha y hora de borrado en un campo de la tabla
*/


CREATE TABLE ObraSocial.Prestador (
    id_prestador INT IDENTITY(1,1),
    nombre_prestador VARCHAR(100),
    plan_prestador VARCHAR(50)
	CONSTRAINT pk_prestador PRIMARY KEY CLUSTERED (id_prestador)
)
GO

CREATE TABLE ObraSocial.Cobertura (
    id_cobertura INT IDENTITY(1,1),
    id_prestador INT,
    imagen_de_la_credencial VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    nro_de_socio INT,
    fecha_de_registro DATE DEFAULT GETDATE(),
	CONSTRAINT pk_cobertura PRIMARY KEY CLUSTERED (id_cobertura),
    CONSTRAINT fk_prestador FOREIGN KEY (id_prestador) REFERENCES Obrasocial.Prestador(id_prestador) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Pacientes.Paciente (
    id_historia_clinica INT IDENTITY(1,1),
    id_cobertura INT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_de_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(25),
    sexo_biologico CHAR(1),
    genero CHAR(1),
    nacionalidad VARCHAR(18),
    foto_de_perfil VARCHAR(255), --Aquí se insertarán URLS generadas desde otro sistema
    mail VARCHAR(100),
    telefono_fijo CHAR(15),
    telefono_de_contacto_alternativo CHAR(15),
    telefono_laboral CHAR(15),
    fecha_de_registro DATE DEFAULT GETDATE(),
    fecha_de_actualizacion DATE DEFAULT GETDATE(),
    usuario_actualizacion DATE,
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_historia_clinica PRIMARY KEY CLUSTERED (id_historia_clinica),
    CONSTRAINT fk_cobertura FOREIGN KEY (id_cobertura) REFERENCES ObraSocial.Cobertura(id_cobertura) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Pacientes.Usuario (
    id_usuario INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    nombre_usuario VARCHAR(50) UNIQUE,
    contrasenia VARCHAR(255),
    fecha_de_creacion DATE DEFAULT GETDATE(),
    fecha_borrado DATETIME DEFAULT NULL,
	CONSTRAINT pk_usuario PRIMARY KEY CLUSTERED (id_usuario),
    CONSTRAINT fk_paciente FOREIGN KEY (id_historia_clinica) REFERENCES Pacientes.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Pacientes.Domicilio (
    id_domicilio INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    calle VARCHAR(50),
    numero INT,
    piso INT,
    departamento CHAR(10),
    codigo_postal CHAR(10),
    pais VARCHAR(40),
    provincia VARCHAR(50),
    localidad VARCHAR(50),
	CONSTRAINT pk_domicilio PRIMARY KEY CLUSTERED (id_domicilio),
    CONSTRAINT fk_paciente FOREIGN KEY (id_historia_clinica) REFERENCES Pacientes.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Pacientes.Estudio (
    id_estudio INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    fecha DATE NOT NULL,
    nombre_estudio VARCHAR(100) NOT NULL,
    autorizado BIT DEFAULT 0,
    documento_resultado VARCHAR(255), -- Se intepreta con la URL al documento
    imagen_resultado VARCHAR(255), -- Aquí se insertarán URLS generadas desde otro sistema
	CONSTRAINT pk_estudio PRIMARY KEY CLUSTERED (id_estudio),
    CONSTRAINT fk_paciente FOREIGN KEY (id_historia_clinica) REFERENCES Pacientes.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Pacientes.Pago (
    id_pago INT IDENTITY(1,1),
    id_historia_clinica INT NOT NULL,
    fecha DATE DEFAULT GETDATE(),
    monto DECIMAL(10, 2),
	CONSTRAINT pk_pago PRIMARY KEY CLUSTERED (id_pago),
    CONSTRAINT fk_paciente FOREIGN KEY (id_historia_clinica) REFERENCES Pacientes.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Pacientes.Factura (
    id_factura INT IDENTITY(1,1),
    id_pago INT,
    id_estudio INT,
    id_historia_clinica INT,
    costo_factura_inicial DECIMAL(10, 2),
    costo_adeudado DECIMAL(10,2),
    porcentaje_pagado DECIMAL(3,2), -- Nacho: sirve para poder dejar asentado si pagó el porcentaje de la factura o no, se insertar con el SP actualizarAutorizacionEstudios
	CONSTRAINT pk_factura PRIMARY KEY CLUSTERED (id_factura),
    CONSTRAINT fk_pago FOREIGN KEY (id_pago) REFERENCES Pacientes.Pago(id_pago) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_paciente FOREIGN KEY (id_historia_clinica) REFERENCES Pacientes.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_estudio FOREIGN KEY (id_estudio) REFERENCES Pacientes.Estudio(id_estudio) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Turnos.EstadoTurno (
    id_estado INT IDENTITY(1,1), -- Nacho: acá hay algo que no me gusta, id estado es medio falopa
											 -- Tomi: Para mi esta OK. es para que sea mas facil referenciarlo y hacer joins si es necesario
														-- Es mucho mas eficiente comparar ints que cadenas d texto
                                                        -- Nacho: dale, lo dejamos así
    nombre_estado VARCHAR(9) NOT NULL,
	CONSTRAINT pk_estado PRIMARY KEY CLUSTERED (id_estado)
)
GO

CREATE TABLE Turnos.TipoTurno (
    id_tipo_turno INT IDENTITY(1,1),
    nombre_del_tipo_de_turno VARCHAR(10) NOT NULL,
    minutos_duracion INT DEFAULT 15,
	CONSTRAINT pk_tipo_turno PRIMARY KEY CLUSTERED (id_tipo_turno)
)
GO

CREATE TABLE Hospital.Especialidad (
    id_especialidad INT IDENTITY(1,1),
    nombre_especialidad VARCHAR(50),
	CONSTRAINT pk_especialidad PRIMARY KEY CLUSTERED (id_especialidad),
)

CREATE TABLE Hospital.Medico (
    id_medico INT IDENTITY(1,1),
    id_especialidad INT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nro_matricula CHAR(10),
	CONSTRAINT pk_medico PRIMARY KEY CLUSTERED (id_medico),
    CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES Hospital.Especialidad(id_especialidad) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE TABLE Turnos.ReservaTurnoMedico (
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
    CONSTRAINT fk_estado_turno FOREIGN KEY (id_estado_turno) REFERENCES Turnos.EstadoTurno(id_estado) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tipo_turno FOREIGN KEY (id_tipo_turno) REFERENCES Turnos.TipoTurno(id_tipo_turno) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_historia_clinica FOREIGN KEY (id_historia_clinica) REFERENCES Pacientes.Paciente(id_historia_clinica) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES Hospital.Especialidad(id_especialidad) ON DELETE CASCADE ON UPDATE CASCADE
    --CONSTRAINT fk_paciente FOREIGN KEY (nro_documento_paciente) REFERENCES Pacientes.Paciente(nro_de_documento)
)
GO

CREATE TABLE Hospital.SedeDeAtencion (
    id_sede INT IDENTITY(1,1),
    nombre_de_la_sede VARCHAR(50),
    direccion_sede VARCHAR(50),
	CONSTRAINT pk_sede PRIMARY KEY CLUSTERED (id_sede)
)
GO

CREATE TABLE Hospital.DiasPorSede (
	id_dia_sede INT IDENTITY(1,1),
    id_sede INT,
    id_medico INT,
    dia VARCHAR(9),
    hora_inicio TIME,
	CONSTRAINT pk_dia_sede PRIMARY KEY CLUSTERED (id_dia_sede),
    CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES Hospital.Medico(id_medico) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sede FOREIGN KEY (id_sede) REFERENCES Hospital.SedeDeAtencion(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

/**
    FIN CREACION TABLAS
*/

--------------------------------------------------
------  INSERCION VALORES DEFINIDOS
--------------------------------------------------
INSERT INTO Turnos.EstadoTurno (nombre_estado)
VALUES ('Disponible'), ('Reservado'), ('Cancelado'), ('Atendido'), ('Ausente')
GO


/**
    SPs de Prestador
*/ 
CREATE OR ALTER PROCEDURE ddbba.CrearPrestador
    @nombrePrestador VARCHAR(100), 
    @planPrestador VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Insertar el registro
        INSERT INTO Obrasocial.Prestador (nombre_prestador, plan_prestador)
        VALUES (@nombrePrestador, @planPrestador);
        
        SELECT 'Prestador creado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear el prestador.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarPrestador
    @idPrestador INT,
    @nombrePrestador VARCHAR(100), 
    @planPrestador VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Obrasocial.Prestador WHERE id_prestador = @idPrestador)
        BEGIN
            SELECT 'Error: El prestador a actualizar no existe.';
            RETURN;
        END

        -- Se arma la consulta SQL dinámica
        DECLARE @consulta NVARCHAR(MAX);
        SET @consulta = N'UPDATE Obrasocial.Prestador
                            SET ';

        -- Se agregan las asignaciones de campos a actualizar, solo si se envía un valor distinto de NULL
        IF @nombrePrestador IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'nombre_prestador = @nombrePrestador, ';
        END

        IF @planPrestador IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'plan_prestador = @planPrestador, ';
        END

        -- Se elimina la última coma si es necesario
        IF SUBSTRING(@consulta, LEN(@consulta) - 1, 1) = ','
        BEGIN
            SET @consulta = SUBSTRING(@consulta, 0, LEN(@consulta) - 1);
        END

        -- Se agrega la condición WHERE
        SET @consulta = @consulta + N'WHERE id_prestador = @idPrestador;';

        -- Se ejecuta la consulta SQL dinámica
        EXEC sp_executesql @consulta,
                            N'@nombrePrestador VARCHAR(100), @planPrestador VARCHAR(50), @idPrestador INT',
                            @nombrePrestador, @planPrestador, @idPrestador;
        
        SELECT 'Prestador actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar el prestador.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarPrestador
	@idPrestador INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM ddbba.EliminarPrestador WHERE id_prestador = @idPrestador )
		BEGIN
			DELETE Turnos.ReservaTurnoMedico
				WHERE id_prestador = @idPrestador;
            SELECT 'Prestador eliminado exitosamente.';
		END
        ELSE
			SELECT CONCAT('Error: El prestador con id: ', @idPrestador, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el prestador.', ERROR_MESSAGE();
    END CATCH
END
GO

/**
    FIN SPs de Prestador
*/ 

/**
    SPs de ReservaTurnoMedico
*/ 

CREATE OR ALTER PROCEDURE ddbba.CrearReservaTurnoMedico
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
        IF EXISTS (SELECT 1 FROM Pacientes.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
            AND EXISTS (SELECT 1 FROM Hospital.Medico WHERE id_medico = @idMedico)
            AND EXISTS (SELECT 1 FROM Hospital.Especialidad WHERE id_especialidad = @idEspecialidad)
            AND EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE id_estado_turno = @idEstadoTurno)
            AND EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            DECLARE @fecha DATE,
                    @hora TIME;

            SELECT  @fecha = GETDATE(),
                    @hora = GETDATE();

            -- Insertar el registro
            INSERT INTO Turnos.ReservaTurnoMedico (id_historia_clinica, fecha, hora, id_medico, id_especialidad, id_direccion_atencion, id_estado_turno, id_tipo_turno)
            VALUES (@idHistoriaClinica, @fecha, @hora, @idMedico, @idEspecialidad, @id_direccion_atencion, @idEstadoTurno, @idTipoTurno);
            
            SELECT 'Reserva de turno creada exitosamente.';
        END
        ELSE
            SELECT 'Error: Uno o más identificadores de referencia no existen.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarReservaTurnoMedico
    @idTurno INT,
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
        IF NOT EXISTS (SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_turno = @idTurno)
        BEGIN
            SELECT 'Error: El turno a actualizar no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Pacientes.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
        BEGIN
            SELECT 'Error: El paciente no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Hospital.Medico WHERE id_medico = @idMedico)
        BEGIN
            SELECT 'Error: El médico no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Hospital.Especialidad WHERE id_especialidad = @idEspecialidad)
        BEGIN
            SELECT 'Error: La especialidad no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE id_estado_turno = @idEstadoTurno)
        BEGIN
            SELECT 'Error: El estado del turno no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            SELECT 'Error: El tipo de turno no existe.';
            RETURN;
        END

        -- Se arma la consulta SQL dinámica
        DECLARE @consulta NVARCHAR(MAX);
        SET @consulta = N'UPDATE Turnos.ReservaTurnoMedico
                            SET ';

        -- Se agregan las asignaciones de campos a actualizar, solo si se envía un valor distinto de NULL
        IF @idHistoriaClinica IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_historia_clinica = @idHistoriaClinica, ';
        END

        IF @idMedico IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_medico = @idMedico, ';
        END

        IF @idEspecialidad IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_especialidad = @idEspecialidad, ';
        END

        IF @idDireccionAtencion IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_direccion_atencion = @idDireccionAtencion, ';
        END

        IF @idEstadoTurno IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_estado_turno = @idEstadoTurno, ';
        END

        IF @idTipoTurno IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_tipo_turno = @idTipoTurno ';
        END

        -- Se elimina la última coma si es necesario
        IF SUBSTRING(@consulta, LEN(@consulta) - 1, 1) = ','
        BEGIN
            SET @consulta = SUBSTRING(@consulta, 0, LEN(@consulta) - 1);
        END

        -- Se agrega la condición WHERE
        SET @consulta = @consulta + N'WHERE id_turno = @idTurno;';

        -- Se ejecuta la consulta SQL dinámica
        EXEC sp_executesql @consulta,
                            N'@idHistoriaClinica INT, @idMedico INT, @idEspecialidad INT, @idDireccionAtencion INT, @idEstadoTurno INT, @idTipoTurno INT, @idTurno INT',
                            @idHistoriaClinica, @idMedico, @idEspecialidad, @idDireccionAtencion, @idEstadoTurno, @idTipoTurno, @idTurno;

        SELECT 'Reserva de turno actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO



/**
	Realiza un borrado lógico de la tabla
	No es lo mismo que cancelar un turno
*/
CREATE OR ALTER PROCEDURE ddbba.EliminarReservaTurnoMedico
	@idTurno INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_turno = @idTurno )
		BEGIN
			UPDATE Turnos.ReservaTurnoMedico
				SET  deleted = 1
				WHERE id_turno = @idTurno
            SELECT 'Reserva de turno eliminada exitosamente.';
		END
        ELSE
			SELECT CONCAT('Error: El turno con id: ', @idTurno, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ddbba.CancelarReservaTurnoMedico
	@idTurno INT,
	@idEstadoCancelado INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_turno = @idTurno )
		BEGIN
			UPDATE Turnos.ReservaTurnoMedico
				SET  id_estado_turno = @idEstadoCancelado
				WHERE id_turno = @idTurno
            SELECT 'Reserva de turno cancelada exitosamente.';
		END
        ELSE
			SELECT CONCAT('Error: El turno con id: ', @idTurno, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al cancelar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO
-- Decidir si poner borrado fisico o no

/**
    FIN SPs de ReservaTurnoMedico
**/ 


CREATE PROCEDURE ddbba.actualizarAutorizacionEstudios(@id_estudio INT, @id_historia_clinica_paciente INT) --Nacho: saqué el @monto de acá, no le veo sentido
AS
BEGIN
    -- Declarar variables para los costos
    DECLARE @CostoFactura DECIMAL(10, 2);
    DECLARE @CostoAbonadoPago DECIMAL(10, 2);

    -- Obtener el costo de la factura del estudio para el paciente
    SELECT @CostoFactura = costo_factura_inicial 
    FROM Pacientes.Factura 
    WHERE id_historia_clinica = @id_historia_clinica_paciente 
    AND id_estudio = @id_estudio;

    -- Obtener el monto abonado por el paciente
    SELECT @CostoAbonadoPago = SUM(p.monto)
    FROM Pacientes.Pago p
    JOIN Pacientes.Factura f ON p.id_pago = f.id_pago 
    WHERE f.id_historia_clinica = @id_historia_clinica_paciente 
    AND f.id_estudio = @id_estudio;

    -- Verificar si el monto abonado es mayor o igual al costo de la factura
    IF(@CostoAbonadoPago >= @CostoFactura)
    BEGIN
        -- Actualizar el estudio como autorizado
        UPDATE Pacientes.Estudio
        SET autorizado = 1
        WHERE id_estudio = @id_estudio;

        -- Registrar que el costo ha sido cubierto completamente
        UPDATE Pacientes.Factura
        SET porcentaje_pagado = 100
        WHERE id_historia_clinica = @id_historia_clinica_paciente 
        AND id_estudio = @id_estudio;
    END
    ELSE
    BEGIN
        -- Calcular el porcentaje pagado y actualizar la factura
        UPDATE Pacientes.Factura
        SET porcentaje_pagado = (@CostoAbonadoPago / @CostoFactura) * 100
        WHERE id_historia_clinica = @id_historia_clinica_paciente 
        AND id_estudio = @id_estudio;

        -- Nacho: Deberíamos poner un atributo monto adeudado?
    END
END

GO
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
        SET @id_estado_cancelado = (SELECT id_estado FROM Turnos.EstadoTurno
                                    WHERE nombre_estado = 'Cancelado')

        DECLARE @id_estado_disponible INT
        SET @id_estado_disponible = (SELECT id_estado FROM Turnos.EstadoTurno
                                    WHERE nombre_estado = 'Disponible') -- Nacho: esto me parece que tenés razón amigo, no va @tomi felice

        UPDATE ddbba.turnoAsignado
        SET id_estado_turno = @id_estado_cancelado
        WHERE id_prestador = @idPrestador
        AND id_estado_turno = @id_estado_disponible

        INSERT INTO Turnos.ReservaTurnoMedico

    END

END
GO

CREATE 

CREATE OR ALTER PROCEDURE ddbba.DisponibilizarTurnosSegunMedicoEspecialidadSede(@idMedico INT, @idEspecialidad INT, @idSedeAtencion INT) --Deberíamos hacer un SP para disponibilizar las reserva de turnos médicos. 
AS
BEGIN

END
GO -- Nacho: Podemos poner nosotros las reglas de negocio para esto:

--Condiciones para NO contar con el default de turno DISPONIBLE:
-- 1) Todo lo que sea médico de especialidad clínica, podemos poner por default Disponible si es cede Central
-- 2) Podemos decir que tenemos 2 Sedes: Central y secundaria. Si es primaria, default Disponible

-- Tomi : No entiendo por que no tendriamos el turno DISPONIBLE por defecto si no es en la sede Central