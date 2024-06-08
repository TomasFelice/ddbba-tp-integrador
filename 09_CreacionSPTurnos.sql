USE com2900g09
GO

/**
    SPs de ReservaTurnoMedico
*/ 

CREATE OR ALTER PROCEDURE Turnos.CrearReservaTurnoMedico
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
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
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

CREATE OR ALTER PROCEDURE Turnos.ActualizarReservaTurnoMedico
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
			SELECT CONCAT('Error: El turno con id: ', @idTurno, ' no existe');
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
			SELECT CONCAT('Error: El turno con id: ', @idTurno, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

/**
    FIN SPs de ReservaTurnoMedico
**/ 