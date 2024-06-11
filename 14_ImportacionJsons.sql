USE com2900g09
GO

DROP TABLE IF EXISTS Centro_Autorizaciones.AutorizacionEstudio
GO

DROP SCHEMA IF EXISTS Centro_Autorizaciones
GO

CREATE SCHEMA Centro_Autorizaciones
GO

CREATE TABLE Centro_Autorizaciones.AutorizacionEstudio (
	id VARCHAR(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
	area VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	estudio VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	prestador VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	plan_prestador VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	porcentaje_cobertura INT,
	costo FLOAT,
	requiere_autorizacion BIT,
)
GO 

CREATE OR ALTER PROCEDURE Paciente.insertarEstudioDesdeJson
    @RutaArchivo VARCHAR(255)
AS
BEGIN
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

    -- UPDATE Centro_Autorizaciones.AutorizacionEstudio
    -- SET
	-- 	Centro_Autorizaciones.AutorizacionEstudio.id = #TempData.id,
    --     Centro_Autorizaciones.AutorizacionEstudio.area = #TempData.area,
    --     Centro_Autorizaciones.AutorizacionEstudio.estudio = #TempData.estudio,
    --     Centro_Autorizaciones.AutorizacionEstudio.prestador = #TempData.prestador,
    --     Centro_Autorizaciones.AutorizacionEstudio.plan_prestador = #TempData.plan_prestador,
    --     Centro_Autorizaciones.AutorizacionEstudio.porcentaje_cobertura = #TempData.porcentaje_cobertura,
    --     Centro_Autorizaciones.AutorizacionEstudio.costo = #TempData.costo,
    --     Centro_Autorizaciones.AutorizacionEstudio.requiere_autorizacion = #TempData.requiere_autorizacion
    -- FROM Centro_Autorizaciones.AutorizacionEstudio ae
    -- INNER JOIN #TempData ON ae.id = #TempData.id AND ae.area = #TempData.area AND ae.prestador = #TempData.prestador AND ae.estudio = #TempData.estudio AND ae.plan_prestador = #TempData.plan_prestador;

    -- -- Insertar nuevos registros si no existen
    -- INSERT INTO Centro_Autorizaciones.AutorizacionEstudio (id, area, estudio, prestador, plan_prestador, porcentaje_cobertura, costo, requiere_autorizacion)
    -- SELECT
    --     id, area, estudio, prestador, plan_prestador, porcentaje_cobertura, costo, requiere_autorizacion
    -- FROM #TempData
    -- WHERE NOT EXISTS (
    --     SELECT 1
    --     FROM Centro_Autorizaciones.AutorizacionEstudio AS ae
    --     WHERE ae.id = #TempData.id COLLATE SQL_Latin1_General_CP1_CI_AS 
	-- 	AND ae.area = #TempData.Area COLLATE SQL_Latin1_General_CP1_CI_AS 
	-- 	AND ae.prestador = #TempData.Prestador COLLATE SQL_Latin1_General_CP1_CI_AS 
	-- 	AND ae.estudio = #TempData.estudio COLLATE SQL_Latin1_General_CP1_CI_AS 
	-- 	AND ae.plan_prestador = #TempData.plan_prestador COLLATE SQL_Latin1_General_CP1_CI_AS
    -- );

	-- me falla porque todavia no tenemos ningun paciente, seguir acá

    INSERT INTO Paciente.Estudio (id_estudio, area, nombre_estudio, autorizado, id_historia_clinica, fecha)
    SELECT
        id, area, estudio, CASE WHEN requiere_autorizacion = 1 THEN 0 ELSE 1 END, 1, GETDATE()
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
        Paciente.Estudio.area = #TempData.area,
        Paciente.Estudio.nombre_estudio = #TempData.estudio,
        Paciente.Estudio.autorizacion = CASE WHEN #TempData.requiere_autorizacion = 1 THEN 0 ELSE 1 END
    FROM Paciente.Estudio pe
    INNER JOIN #TempData ON pe.id = #TempData.id AND pe.area = #TempData.area AND pe.nombre_estudio = #TempData.estudio;


    -- Eliminar la tabla temporal
    DROP TABLE #TempData;
END;
GO

EXEC Paciente.insertarEstudioDesdeJson 'D:\Dev\ddbba-tp-integrador\Dataset\Centro_Autorizaciones.Estudios clinicos.json';
GO

SELECT * FROM paciente.Estudio
GO

-- SELECT * from Centro_Autorizaciones.AutorizacionEstudio
-- GO