USE com2900g09
GO

CREATE SCHEMA Centro_Autorizaciones
GO

CREATE TABLE Centro_Autorizaciones.AutorizacionEstudio (
	id VARCHAR(25),
	area VARCHAR(50),
	estudio VARCHAR(50),
	prestador VARCHAR(50),
	plan_prestador VARCHAR(50),
	porcentaje_cobertura INT,
	costo FLOAT,
	requiere_autorizacion BIT,
)

CREATE OR ALTER PROCEDURE Paciente.insertarEstudioDesdeJson
    @RutaArchivo VARCHAR(255)
AS
BEGIN
    CREATE TABLE #TempData (
		id VARCHAR(25),
        area VARCHAR(255),
        estudio NVARCHAR(255),
        prestador VARCHAR(255),
        plan_prestador NVARCHAR(255),
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
	plan_prestador varchar(50) ''$.Plan'', 
	porcentaje_cobertura int ''$."Porcentaje Cobertura"'', 
	costo int ''$.Costo'', 
	requiere_autorizacion bit ''$."Requiere autorizacion"''
	)'
	EXEC sp_executesql @sql;

    UPDATE Centro_Autorizaciones.AutorizacionEstudio
    SET
		Centro_Autorizaciones.AutorizacionEstudio.id = #TempData.id,
        Centro_Autorizaciones.AutorizacionEstudio.area = #TempData.area,
        Centro_Autorizaciones.AutorizacionEstudio.estudio = #TempData.estudio,
        Centro_Autorizaciones.AutorizacionEstudio.prestador = #TempData.prestador,
        Centro_Autorizaciones.AutorizacionEstudio.plan_prestador = #TempData.plan_prestador,
        Centro_Autorizaciones.AutorizacionEstudio.porcentaje_cobertura = #TempData.porcentaje_cobertura,
        Centro_Autorizaciones.AutorizacionEstudio.costo = #TempData.costo,
        Centro_Autorizaciones.AutorizacionEstudio.requiere_autorizacion = #TempData.requiere_autorizacion
    FROM Centro_Autorizaciones.AutorizacionEstudio ae
    INNER JOIN #TempData ON ae.id = #TempData.id AND ae.area = #TempData.area AND ae.prestador = #TempData.prestador AND ae.estudio = #TempData.estudio AND ae.plan_prestador = #TempData.plan_prestador;

    -- Insertar nuevos registros si no existen
    INSERT INTO Centro_Autorizaciones.AutorizacionEstudio (id, area, estudio, prestador, plan_prestador, porcentaje_cobertura, costo, requiere_autorizacion)
    SELECT
        id, area, estudio, prestador, plan_prestador, porcentaje_cobertura, costo, requiere_autorizacion
    FROM #TempData
    WHERE NOT EXISTS (
        SELECT 1
        FROM Centro_Autorizaciones.AutorizacionEstudio AS ae
        WHERE ae.id = #TempData.id AND ae.area = #TempData.Area AND ae.prestador = #TempData.Prestador AND ae.estudio = #TempData.estudio AND ae.plan_prestador = #TempData.plan_prestador
    );

    -- Eliminar la tabla temporal
    DROP TABLE #TempData;
END;
GO

EXEC Paciente.insertarEstudioDesdeJson 'C:\Users\tomas\OneDrive\Documentos\ddbba-tp-integrador\Dataset\Centro_Autorizaciones.EstudiosClinicos.json';
GO

SELECT * from Centro_Autorizaciones.AutorizacionEstudio
GO
