USE com2900g09
GO

CREATE OR ALTER PROCEDURE Paciente.insertarEstudioDesdeJson
    @RutaArchivo VARCHAR(255)
AS
BEGIN
	IF @RutaArchivo = '' OR @RutaArchivo IS NULL
	BEGIN
		SELECT 'No se ha especificado una ruta de archivo.';
		RETURN;	
	END

	BEGIN TRY
		CREATE TABLE #TempData (
			id VARCHAR(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
			area VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
			estudio VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
			prestador VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
			plan_prestador VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
			porcentaje_cobertura INT,
			costo DECIMAL(18, 2),
			requiere_autorizacion BIT
		);
		DECLARE @sql NVARCHAR(MAX);
		SET @sql = 
		'insert into #TempData (id, area, estudio, prestador, plan_prestador, porcentaje_cobertura, costo, requiere_autorizacion)
		select id, area, estudio, prestador, plan_prestador, porcentaje_cobertura, costo, requiere_autorizacion
		from openrowset (BULK N''' + @RutaArchivo + ''', SINGLE_CLOB) as j
		cross apply openjson(BulkColumn)
		with (
		id varchar(25) ''$._id."$oid"'', 
		area varchar(50) ''$.Area'', 
		estudio varchar(50) ''$.Estudio'', 
		prestador varchar(50) ''$.Prestador'', 
		plan_prestador varchar(50) ''$.Plan'' , 
		porcentaje_cobertura int ''$."Porcentaje Cobertura"'', 
		costo int ''$.Costo'', 
		requiere_autorizacion bit ''$."Requiere autorizacion"''
		)'
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		SELECT CONCAT('Se produjo un error al importar el archivo: ', ERROR_MESSAGE());
		RETURN;
	END CATCH

	BEGIN TRY

		INSERT INTO Paciente.Estudio (id_estudio, area, nombre_estudio, autorizado, id_historia_clinica, fecha)
        SELECT
            id, COALESCE(area, '') COLLATE SQL_Latin1_General_CP1_CI_AS, COALESCE(estudio, '') COLLATE SQL_Latin1_General_CP1_CI_AS, CASE WHEN requiere_autorizacion = 1 THEN 0 ELSE 1 END, FLOOR(RAND()*(997-1)+1), GETDATE()
        FROM #TempData
        WHERE NOT EXISTS (
            SELECT 1
            FROM Paciente.Estudio AS pe
            WHERE pe.id_estudio = #TempData.id COLLATE SQL_Latin1_General_CP1_CI_AS 
            AND #TempData.id IS NOT NULL
        );

		UPDATE Paciente.Estudio
		SET
			Paciente.Estudio.id_estudio = #TempData.id,
			Paciente.Estudio.area = COALESCE(#TempData.area, '') COLLATE SQL_Latin1_General_CP1_CI_AS,
			Paciente.Estudio.nombre_estudio = COALESCE(#TempData.estudio, '') COLLATE SQL_Latin1_General_CP1_CI_AS,
			Paciente.Estudio.autorizado = CASE WHEN #TempData.requiere_autorizacion = 1 THEN 0 ELSE 1 END
		FROM Paciente.Estudio pe
		INNER JOIN #TempData ON pe.id_estudio = #TempData.id AND pe.area = #TempData.area AND pe.nombre_estudio = #TempData.estudio;

		INSERT INTO Paciente.Factura(id_estudio, id_historia_clinica, costo_factura)
		SELECT
			id, (SELECT pe.id_historia_clinica FROM Paciente.Estudio pe WHERE pe.id_estudio = id) id_historia_clinica, costo
		FROM #TempData
		WHERE EXISTS (
			SELECT 1
			FROM Paciente.Estudio AS pe
			WHERE pe.id_estudio = #TempData.id COLLATE SQL_Latin1_General_CP1_CI_AS
			AND #TempData.costo > 0
		);

		-- Eliminar la tabla temporal
		DROP TABLE #TempData;
	END TRY
	BEGIN CATCH
		SELECT CONCAT('Error al insertar la informacion en las tablas Estudio y Factura: ', ERROR_MESSAGE());
	END CATCH
END;
GO

EXEC Paciente.insertarEstudioDesdeJson 'C:\Users\Ignacio Nogueira\Desktop\Unlam\BDD Aplicadas\Tps\Integrador\ddbba-tp-integrador\Dataset\Centro_Autorizaciones.Estudios clinicos.json';
GO

SELECT * FROM paciente.Estudio
GO
SELECT * FROM paciente.Factura
GO

