USE com2900g09
GO

/**
    SPs de Prestador
*/ 
CREATE OR ALTER PROCEDURE ObraSocial.CrearPrestador
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

CREATE OR ALTER PROCEDURE ObraSocial.ActualizarPrestador
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

CREATE OR ALTER PROCEDURE ObraSocial.EliminarPrestador
	@idPrestador INT
AS
BEGIN
	BEGIN TRY
        IF EXISTS( SELECT 1 FROM ObraSocial.Prestador WHERE id_prestador = @idPrestador )
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
