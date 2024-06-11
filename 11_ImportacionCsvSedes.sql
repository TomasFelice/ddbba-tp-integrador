GO
USE com2900g09
GO
DROP PROCEDURE IF EXISTS Hospital.importarSedeDesdeCSV
GO
CREATE PROCEDURE Hospital.importarSedeDesdeCSV
    @RutaArchivo VARCHAR(255)
AS
BEGIN
		CREATE TABLE #SedeTemp (
			nombreSede NVARCHAR (20),
			direccionSede NVARCHAR (50),
			localidad NVARCHAR(50),
			provincia VARCHAR(50),
		);
	
    -- Construye la sentencia BULK INSERT dinámicamente
    DECLARE @SqlQuery NVARCHAR(MAX);
    SET @SqlQuery = '
        BULK INSERT #SedeTemp
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '';'',  -- Delimitador de campos
            ROWTERMINATOR = ''\n'',   -- Delimitador de filas
			CODEPAGE = 65001,         -- Codificación UTF-8
            FIRSTROW = 2            -- Fila a partir de la cual se deben leer los datos (si la primera fila contiene encabezados)
        );
    ';

    -- Ejecuta la sentencia dinámica
    EXEC sp_executesql @SqlQuery;

	INSERT INTO Hospital.SedeDeAtencion(nombre_sede,direccion_sede)
	SELECT nombreSede, CONCAT(direccionSede,', ',localidad,', ',provincia) AS direccion_concat -- Nacho: deberíamos dividir los atributos y ponerlo con dirección? o lo dejamos concat así?. Tomi: Tenemos que ver de que manera lo podemos encjar en la tabla xd
	FROM #SedeTemp

    PRINT 'La importación se ha completado exitosamente.';
	DROP TABLE #SedeTemp;
END
go
EXEC Hospital.importarSedeDesdeCSV 'D:\Dev\ddbba-tp-integrador\Dataset\Sedes.csv';
go
SELECT * From Hospital.SedeDeAtencion
