GO
USE com2900g09
GO
DROP PROCEDURE IF EXISTS Hospital.importarMedicosDesdeCSV
GO
CREATE PROCEDURE Hospital.importarMedicosDesdeCSV
    @RutaArchivo VARCHAR(255)
AS
BEGIN
		CREATE TABLE #MedicoTemp (
			nombre VARCHAR(50),
            apellido VARCHAR(50),
			especialidad VARCHAR(50),
			nroMatricula int
		);
	
    -- Construye la sentencia BULK INSERT dinámicamente
    DECLARE @SqlQuery NVARCHAR(MAX);
    SET @SqlQuery = '
        BULK INSERT #MedicoTemp
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

	INSERT INTO Hospital.Medico (nombre,apellido,nro_matricula)
	SELECT  mt.nombre,
            mt.apellido,
			mt.nroMatricula
	FROM #MedicoTemp mt

	INSERT INTO Hospital.Especialidad(nombre_especialidad)
	SELECT  mt.especialidad
	FROM #MedicoTemp mt

	INSERT INTO Hospital.MedicoEspecialidad(id_medico, id_especialidad)
	SELECT	hm.id_medico,
			he.id_especialidad
	FROM #MedicoTemp mt
	INNER JOIN Hospital.Medico hm ON hm.nro_matricula = mt.nroMatricula
	INNER JOIN Hospital.Especialidad he ON he.nombre_especialidad = mt.especialidad

    PRINT 'La importación se ha completado exitosamente.';
	DROP TABLE #MedicoTemp;
END;
go

EXEC Hospital.importarMedicosDesdeCSV 'D:\Dev\ddbba-tp-integrador\Dataset\Medicos.csv';
go
SELECT * From Hospital.Medico
SELECT * From Hospital.Especialidad
SELECT * From Hospital.MedicoEspecialidad