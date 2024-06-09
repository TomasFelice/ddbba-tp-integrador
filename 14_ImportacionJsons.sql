USE com2900g09
GO

CREATE OR ALTER PROCEDURE Paciente.insertarEstudioDesdeJson
    @RutaArchivo VARCHAR(255)
AS
BEGIN
    CREATE TABLE #JsonTemp (
        jsonData NVARCHAR(MAX)
    );

    DECLARE @jsonData NVARCHAR(MAX);

    SELECT @jsonData = BulkColumn FROM OPENROWSET(
        BULK @RutaArchivo,
        FORMAT = 'JSON'
    );

    INSERT INTO #JsonTemp (jsonData) VALUES (@jsonData);

    -- Completar

    PRINT 'La importación se ha completado exitosamente.';
	DROP TABLE #JsonTemp;
END;
go

EXEC Paciente.insertarEstudioDesdeJson 'C:\importar\Centro_Autorizaciones.Estudios clinicos.csv';
go
SELECT * From Paciente.Prestador
go