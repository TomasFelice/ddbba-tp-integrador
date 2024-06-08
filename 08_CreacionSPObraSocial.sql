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

/**
    SPs de Cobertura
*/

CREATE OR ALTER PROCEDURE ObraSocial.insertarCobertura
    @idPrestador INT,
    @idHistoriaClinica INT,
    @idTipoCobertura INT,
    @imagenDeLaCredencial VARCHAR(255),
    @nroDeSocio INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE id_historia_clinica = @idHistoriaClinica)
            AND EXISTS (SELECT 1 FROM ObraSocial.Prestador WHERE id_prestador = @idPrestador)
            AND EXISTS (SELECT 1 FROM ObraSocial.TipoCobertura WHERE id_tipo_cobertura = @idTipoCobertura)
        BEGIN
            DECLARE @fechaRegistro DATE;

            SELECT  @fechaRegistro = GETDATE();

            -- Insertar el registro
            INSERT INTO ObraSocial.Cobertura (id_tipo_cobertura, id_prestador, id_historia_clinica, imagen_de_la_credencial, nro_de_socio, fecha_de_registro)
            VALUES (@idTipoCobertura, @idPrestador, @idHistoriaClinica, @imagenDeLaCredencial, @nroDeSocio, @fechaRegistro);
        END
        ELSE
            SELECT 'Error: Uno o más identificadores de referencia no existen.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear la reserva de turno.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ObraSocial.actualizarCobertura
    @idCobertura INT,
    @idPrestador INT,
    @idHistoriaClinica INT,
    @idTipoCobertura INT,
    @imagenDeLaCredencial VARCHAR(255),
    @nroDeSocio INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ObraSocial.Cobertura WHERE id_cobertura = @idCobertura)
        BEGIN
            SELECT 'Error: La cobertura a actualizar no existe.';
            RETURN;
        END

        -- Se arma la consulta SQL dinámica
        DECLARE @consulta NVARCHAR(MAX);
        SET @consulta = N'UPDATE ObraSocial.Cobertura
                            SET ';

        -- Se agregan las asignaciones de campos a actualizar, solo si se envía un valor distinto de NULL
        IF @idPrestador IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_prestador = @idPrestador, ';
        END

        IF @idHistoriaClinica IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_historia_clinica = @idHistoriaClinica, ';
        END

        IF @idTipoCobertura IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'id_tipo_cobertura = @idTipoCobertura, ';
        END

        IF @imagenDeLaCredencial IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'imagen_de_la_credencial = @imagenDeLaCredencial, ';
        END

        IF @nroDeSocio IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'nro_de_socio = @nroDeSocio, ';
        END

        -- Se elimina la última coma si es necesario
        IF SUBSTRING(@consulta, LEN(@consulta) - 1, 1) = ','
        BEGIN
            SET @consulta = SUBSTRING(@consulta, 0, LEN(@consulta) - 1);
        END

        -- Se agrega la condición WHERE
        SET @consulta = @consulta + N'WHERE id_cobertura = @idCobertura;';

        -- Se ejecuta la consulta SQL dinámica
        EXEC sp_executesql @consulta,
                            N'@idPrestador INT, @idHistoriaClinica INT, @idTipoCobertura INT, @imagenDeLaCredencial VARCHAR(255), @nroDeSocio INT, @idCobertura INT',
                            @idPrestador, @idHistoriaClinica, @idTipoCobertura, @imagenDeLaCredencial, @nroDeSocio, @idCobertura;

        SELECT 'Cobertura actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar la cobertura.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ObraSocial.eliminarCobertura
    @idCobertura INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS( SELECT 1 FROM ObraSocial.Cobertura WHERE id_cobertura = @idCobertura )
        BEGIN
            DELETE ObraSocial.Cobertura
                WHERE id_cobertura = @idCobertura;
            SELECT 'Cobertura eliminada exitosamente.';
        END
        ELSE
            SELECT 'Error: La cobertura a eliminar no existe.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la cobertura.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ObraSocial.eliminarCoberturaLogico
    @idCobertura INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS( SELECT 1 FROM ObraSocial.Cobertura WHERE id_cobertura = @idCobertura )
        BEGIN
            UPDATE ObraSocial.Cobertura
                SET borrado_en = GETDATE()
                WHERE id_cobertura = @idCobertura;
            SELECT 'Cobertura eliminada lógicamente con éxito.';
        END
        ELSE
            SELECT 'Error: La cobertura a eliminar no existe.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la cobertura.', ERROR_MESSAGE();
    END CATCH
END
/**
    FIN SPs de Cobertura
*/

/**
    SPs de TipoCobertura
*/

CREATE OR ALTER PROCEDURE ObraSocial.insertarTipoCobertura
    @nombreTipoCobertura VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Insertar el registro
        IF EXISTS (SELECT 1 FROM ObraSocial.TipoCobertura WHERE nombre_tipo_cobertura = @nombreTipoCobertura)
        BEGIN
            SELECT 'Tipo de cobertura ya existente.';
        END
        ELSE
        BEGIN
            INSERT INTO ObraSocial.TipoCobertura (nombre_tipo_cobertura)
            VALUES (@nombreTipoCobertura);
            SELECT 'Tipo de cobertura creado exitosamente.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al crear el tipo de cobertura.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE ObraSocial.actualizarTipoCobertura
    @idTipoCobertura INT,
    @nombreTipoCobertura VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ObraSocial.TipoCobertura WHERE id_tipo_cobertura = @idTipoCobertura)
        BEGIN
            SELECT 'Error: El tipo de cobertura a actualizar no existe.';
            RETURN;
        END

        -- Se arma la consulta SQL dinámica
        DECLARE @consulta NVARCHAR(MAX);
        SET @consulta = N'UPDATE ObraSocial.TipoCobertura
                            SET ';

        -- Se agregan las asignaciones de campos a actualizar, solo si se envía un valor distinto de NULL
        IF @nombreTipoCobertura IS NOT NULL
        BEGIN
            SET @consulta = @consulta + N'nombre_tipo_cobertura = @nombreTipoCobertura, ';
        END

        -- Se elimina la última coma si es necesario
        IF SUBSTRING(@consulta, LEN(@consulta) - 1, 1) = ','
        BEGIN
            SET @consulta = SUBSTRING(@consulta, 0, LEN(@consulta) - 1);
        END

        -- Se agrega la condición WHERE
        SET @consulta = @consulta + N'WHERE id_tipo_cobertura = @idTipoCobertura;';

        -- Se ejecuta la consulta SQL dinámica
        EXEC sp_executesql @consulta,
                            N'@nombreTipoCobertura VARCHAR(50), @idTipoCobertura INT',
                            @nombreTipoCobertura, @idTipoCobertura;

        SELECT 'Tipo de cobertura actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al actualizar el tipo de cobertura.', ERROR_MESSAGE();
    END CATCH
END

CREATE OR ALTER PROCEDURE ObraSocial.eliminarTipoCobertura
    @idTipoCobertura INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS( SELECT 1 FROM ObraSocial.TipoCobertura WHERE id_tipo_cobertura = @idTipoCobertura )
        BEGIN
            DELETE ObraSocial.TipoCobertura
                WHERE id_tipo_cobertura = @idTipoCobertura;
            SELECT 'Tipo de cobertura eliminado exitosamente.';
        END
        ELSE
            SELECT 'Error: El tipo de cobertura a eliminar no existe.';
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el tipo de cobertura.', ERROR_MESSAGE();
    END CATCH
END
GO

/**
    FIN SPs de TipoCobertura
*/