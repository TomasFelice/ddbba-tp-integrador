USE com2900g09
GO

/**
    SPs de ReservaTurnoMedico
*/ 

CREATE OR ALTER PROCEDURE Turnos.CrearReservaTurnoMedico
    @idHistoriaClinica INT, 
    @idmedico INT,
    @idMedicoEspecialidad INT,
    @id_prestador INT,
    @idSede INT,
    @idEstadoTurno INT, 
    @idTipoTurno INT
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
            AND EXISTS (SELECT 1 FROM Hospital.Medico WHERE id_medico = @idMedico)
            AND EXISTS (SELECT 1 FROM Hospital.MedicoEspecialidad WHERE id_medico_especialidad = @idMedicoEspecialidad)
            AND EXISTS (SELECT 1 FROM Hospital.SedeDeAtencion WHERE id_sede = @idSede)
            AND EXISTS (SELECT 1 FROM ObraSocial.id_prestador WHERE id_prestador = @id_prestador)
            AND EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE id_estado_turno = @idEstadoTurno)
            AND EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            DECLARE @fecha DATE,
                    @hora TIME;

            SELECT  @fecha = GETDATE(),
                    @hora = GETDATE();

            -- Insertar el registro
            INSERT INTO Turnos.ReservaTurnoMedico (id_historia_clinica, fecha, hora, id_medico, id_medico_especialidad, id_prestador,id_sede, id_estado_turno, id_tipo_turno)
            VALUES (@idHistoriaClinica, @fecha, @hora, @idMedico, @idMedicoEspecialidad,@id_prestador, @idSede, @idEstadoTurno, @idTipoTurno);
            
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

CREATE OR ALTER PROCEDURE Turnos.ActualizarReservaTurnoMedico
    @idTurno INT,
    @idHistoriaClinica INT, 
    @idMedico INT,
    @idMedicoEspecialidad INT, 
    @idPrestador INT,
    @idSede INT,
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

        IF NOT EXISTS (SELECT 1 FROM Paciente.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
        BEGIN
            SELECT 'Error: El paciente no existe.';
            RETURN;
        END

           IF NOT EXISTS (SELECT 1 FROM Hospital.Medico WHERE id_medico = @idMedico)
        BEGIN
            SELECT 'Error: El médico no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Hospital.MedicoEspecialidad WHERE id_medico_especialidad = @idMedicoEspecialidad)
        BEGIN
            SELECT 'Error: La especialidad no existe.';
            RETURN;
        END
             IF NOT EXISTS (SELECT 1 FROM ObraSocial.Prestador WHERE id_prestador = @idPrestador)
        BEGIN
            SELECT 'Error: El prestador  no existe.';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Hospital.SedeDeAtencion WHERE id_sede = @idSede)
        BEGIN
            SELECT 'Error: La sede no existe.';
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

        IF @idMedicoEspecialidad IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_medico_especialidad = @idMedicoEspecialidad, ';
        END

        IF @idPrestador IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_prestador = @id_prestador, ';
        END

        IF @idSede IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_sede = @idSede, ';
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
                            N'@idHistoriaClinica INT, @idMedico INT,
                            @idMedicoEspecialidad INT, @idPrestador INT, @idSede INT, @idEstadoTurno INT, @idTipoTurno INT, @idTurno INT',
                            @idHistoriaClinica, @idMedico, @idMedicoEspecialidad, @idPrestador, @idSede, @idEstadoTurno, @idTipoTurno, @idTurno;

        SELECT 'Reserva de turno actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

/**
	Realiza un borrado lógico de la tabla
*/
CREATE OR ALTER PROCEDURE Turnos.EliminarReservaTurnoMedicoLogico
	@idTurno INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_turno = @idTurno )
		BEGIN
			UPDATE Turnos.ReservaTurnoMedico
				SET  fecha_borrado = GETDATE()
				WHERE id_turno = @idTurno
            SELECT 'Reserva de turno eliminada exitosamente.';
		END
        ELSE
			SELECT 'Error el turno no existe';
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

/**
	Realiza un borrado físico de la tabla
*/
CREATE OR ALTER PROCEDURE Turnos.EliminarReservaTurnoMedico
	@idTurno INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_turno = @idTurno )
		BEGIN
			DELETE FROM Turnos.ReservaTurnoMedico
				WHERE id_turno = @idTurno
            SELECT 'Reserva de turno eliminada exitosamente.';
		END
        ELSE
            SELECT 'El turno no existe'
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

/**
    FIN SPs de ReservaTurnoMedico
**/ 

/**
    SPs de EstadoTurno
*/ 

CREATE OR ALTER PROCEDURE Turnos.CrearEstadoTurno
    @nombreEstado VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF NOT EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE nombre_estado LIKE @nombreEstado)
        BEGIN
            INSERT INTO Turnos.EstadoTurno (nombre_estado)
            VALUES (@nombreEstado);
            SELECT 'Estado de turno creado exitosamente.';
        END
        ELSE
            SELECT 'Error: El estado de turno ya existe.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear el estado de turno.', ERROR_MESSAGE();
    END CATCH
END

CREATE OR ALTER PROCEDURE Turnos.ActualizarEstadoTurno
    @idEstado INT,
    @nombreEstado VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF NOT EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE id_estado = @idEstado)
        BEGIN
            SELECT 'Error: El estado de turno a actualizar no existe.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE nombre_estado LIKE @nombreEstado)
        BEGIN
            SELECT 'Error: El estado de turn ya existe.';
            RETURN;
        END

        IF (@nombreEstado IS NULL OR @nombreEstado = '')
        BEGIN
            SELECT 'Error: El nombre del estado de turno no puede ser nulo o vacío.';
            RETURN;
        END

        -- Se arma la consulta SQL dinámica
        DECLARE @consulta NVARCHAR(MAX);
        SET @consulta = N'UPDATE Turnos.EstadoTurno
                            SET nombre_estado = @nombreEstado
                            WHERE id_estado = @idEstado;';

        -- Se ejecuta la consulta SQL dinámica
        EXEC sp_executesql @consulta,
                            N'@nombreEstado VARCHAR(10), @idEstado INT',
                            @nombreEstado, @idEstado;

        SELECT 'Estado de turno actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar el estado de turno.', ERROR_MESSAGE();
    END CATCH
END

CREATE OR ALTER PROCEDURE Turnos.EliminarEstadoTurno
    @idEstado INT
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF NOT EXISTS (SELECT 1 FROM Turnos.EstadoTurno WHERE id_estado = @idEstado)
        BEGIN
            SELECT 'Error: El estado de turno a eliminar no existe.';
            RETURN;
        END

        -- La foreign key esta creada con ON DELETE CASCADE, por lo que no es necesario validar la existencia de referenciados, solo lanzaremos un mensaje si existen

        IF EXISTS (SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_estado_turno = @idEstado)
        BEGIN
            SELECT 'Advertencia: Existen reservas de turno que hacen referencia a este estado de turno. Se eliminaran junto con el estado de turno.';
            RETURN;
        END

        DELETE FROM Turnos.EstadoTurno
            WHERE id_estado = @idEstado;

        SELECT 'Estado de turno eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el estado de turno.', ERROR_MESSAGE();
    END CATCH
END

/**
    FIN SPs de EstadoTurno
**/

/**
    SPs de TipoTurno
*/

CREATE OR ALTER PROCEDURE Turnos.CrearTipoTurno
    @nombreTipoTurno VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF NOT EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE nombre_tipo_turno LIKE @nombreTipoTurno)
        BEGIN
            INSERT INTO Turnos.TipoTurno (nombre_tipo_turno)
            VALUES (@nombreTipoTurno);
            SELECT 'Tipo de turno creado exitosamente.';
        END
        ELSE
            SELECT 'Error: El tipo de turno ya existe.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear el tipo de turno.', ERROR_MESSAGE();
    END CATCH
END

CREATE OR ALTER PROCEDURE Turnos.ActualizarTipoTurno
    @idTipoTurno INT,
    @nombreTipoTurno VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF NOT EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            SELECT 'Error: El tipo de turno a actualizar no existe.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE nombre_tipo_turno LIKE @nombreTipoTurno)
        BEGIN
            SELECT 'Error: El tipo de turno con nombre  ya existe.';
            RETURN;
        END

        IF (@nombreTipoTurno IS NULL OR @nombreTipoTurno = '')
        BEGIN
            SELECT 'Error: El nombre del tipo de turno no puede ser nulo o vacío.';
            RETURN;
        END

        UPDATE Turnos.TipoTurno
            SET nombre_tipo_turno = @nombreTipoTurno
            WHERE id_tipo_turno = @idTipoTurno;

        SELECT 'Tipo de turno actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar el tipo de turno.', ERROR_MESSAGE();
    END CATCH
END

CREATE OR ALTER PROCEDURE Turnos.EliminarTipoTurno
    @idTipoTurno INT
AS
BEGIN
    BEGIN TRY
        -- Validación de existencia de referenciados
        IF NOT EXISTS (SELECT 1 FROM Turnos.TipoTurno WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            SELECT 'Error: El tipo de turno a eliminar no existe.';
            RETURN;
        END

        -- La foreign key esta creada con ON DELETE CASCADE, por lo que no es necesario validar la existencia de referenciados, solo lanzaremos un mensaje si existen

        IF EXISTS (SELECT 1 FROM Turnos.ReservaTurnoMedico WHERE id_tipo_turno = @idTipoTurno)
        BEGIN
            SELECT 'Advertencia: Existen reservas de turno que hacen referencia a este tipo de turno. Se eliminaran junto con el tipo de turno.';
            RETURN;
        END

        DELETE FROM Turnos.TipoTurno
            WHERE id_tipo_turno = @idTipoTurno;

        SELECT 'Tipo de turno eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el tipo de turno.', ERROR_MESSAGE();
    END CATCH
END

/**
    FIN SPs de TipoTurno
**/