USE com2900g09
GO

/**
    SPs de Prestador
*/ 
CREATE OR ALTER PROCEDURE ObraSocial.insertarPrestador
    @nombrePrestador VARCHAR(100), 
    @planPrestador VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Insertar el registro
        IF EXISTS (SELECT 1 FROM ObraSocial.Prestador WHERE nombrePrestador = @nombrePrestador) -- Si existe, actualizo los datos. En nuestra regla de negocio cada prestador debe llamarse distinto
        BEGIN
            SELECT 'Prestador existía. Actualizado exitosamente.';
        END
        ELSE
        BEGIN
            INSERT INTO Obrasocial.Prestador (nombre_prestador, plan_prestador)
            VALUES (@nombrePrestador, @planPrestador);
            SELECT 'Prestador creado exitosamente.';
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El prestador con nombre: ', @nombrePrestador, ' no se puede insertar');
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ObraSocial.actualizarPrestador
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
		SELECT CONCAT('Error: El prestador con id: ', @idPrestador, ' no se puede actualizar');
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ObraSocial.eliminarPrestador
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
		SELECT CONCAT('Error: El prestador con id: ', @idPrestador, ' no se puede eliminar');
    END CATCH
END
GO

/**
    FIN SPs de Prestador
*/ 
