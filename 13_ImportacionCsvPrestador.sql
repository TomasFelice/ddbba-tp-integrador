USE com2900g09
GO
DROP PROCEDURE IF EXISTS ObraSocial.insertarPrestadorDesdeCSV
GO
CREATE OR ALTER PROCEDURE ObraSocial.insertarPrestadorDesdeCSV
    @RutaArchivo VARCHAR(255)
AS
BEGIN
		CREATE TABLE #PrestadorTemp (
			nombrePrestador VARCHAR(100),
			planPrestador NVARCHAR(50)
		)
	
    -- Construye la sentencia BULK INSERT dinámicamente
    DECLARE @SqlQuery NVARCHAR(MAX);
    SET @SqlQuery = '
        BULK INSERT #PrestadorTemp
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '';'',  -- Delimitador de campos
            ROWTERMINATOR = '';;\n'',   -- Delimitador de filas
			CODEPAGE = 65001,         -- Codificación UTF-8
            FIRSTROW = 2            -- Fila a partir de la cual se deben leer los datos (si la primera fila contiene encabezados)
        );
    ';

    -- Ejecuta la sentencia dinámica
    EXEC sp_executesql @SqlQuery;

 -- Insertar en ObraSocial.Prestador, sin duplicados
    INSERT INTO ObraSocial.Prestador(nombre_prestador, plan_prestador)
    SELECT nombrePrestador, planPrestador
    FROM #PrestadorTemp mt
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ObraSocial.Prestador p 
        WHERE p.nombre_prestador = mt.nombrePrestador COLLATE SQL_Latin1_General_CP1_CI_AS
          AND p.plan_prestador = mt.planPrestador COLLATE SQL_Latin1_General_CP1_CI_AS
    );

    -- Insertar en ObraSocial.TipoCobertura, sin duplicados
    INSERT INTO ObraSocial.TipoCobertura(nombre_tipo_cobertura)
    SELECT DISTINCT planPrestador
    FROM #PrestadorTemp mt
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ObraSocial.TipoCobertura tc 
        WHERE tc.nombre_tipo_cobertura = mt.planPrestador COLLATE SQL_Latin1_General_CP1_CI_AS
    );

    PRINT 'La importación se ha completado exitosamente.';
	DROP TABLE #PrestadorTemp;
END;
go


EXEC ObraSocial.insertarPrestadorDesdeCSV 'C:\Users\Ignacio Nogueira\Desktop\Unlam\BDD Aplicadas\Tps\Integrador\ddbba-tp-integrador\Dataset\Prestador.csv';
go
SELECT * From ObraSocial.Prestador
go
SELECT * From ObraSocial.TipoCobertura


