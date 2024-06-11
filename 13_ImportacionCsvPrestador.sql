USE com2900g09
GO
DROP PROCEDURE IF EXISTS ObraSocial.insertarPrestadorDesdeCSV
GO
CREATE PROCEDURE ObraSocial.insertarPrestadorDesdeCSV
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

	INSERT INTO ObraSocial.Prestador(nombre_prestador,plan_prestador)
	SELECT nombrePrestador,planPrestador
	FROM #PrestadorTemp

    PRINT 'La importación se ha completado exitosamente.';
	DROP TABLE #PrestadorTemp;
END;
go

EXEC ObraSocial.insertarPrestadorDesdeCSV 'D:\Dev\ddbba-tp-integrador\Dataset\Prestador.csv';
go
SELECT * From ObraSocial.Prestador
go