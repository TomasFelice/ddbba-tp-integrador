USE com2900g09
GO
DROP PROCEDURE IF EXISTS Paciente.ExportarTurnosXML
GO
CREATE PROCEDURE Paciente.ExportarTurnosXML
@ObraSocialNombre NVARCHAR(100),
@FechaInicio DATETIME,
@FechaFin DATETIME
AS
BEGIN
    DECLARE @XMLData XML;
    DECLARE @FileName NVARCHAR(255);
    DECLARE @Query NVARCHAR(MAX);
    DECLARE @FormatFileContent NVARCHAR(MAX);
    DECLARE @FormatFile NVARCHAR(255);
    DECLARE @BCPCmd NVARCHAR(1000);

	-- Convertir las fechas a formato ISO
    SET @FechaInicio = CONVERT(VARCHAR(23), @FechaInicio, 126);
    SET @FechaFin = CONVERT(VARCHAR(23), @FechaFin, 126);

    -- Exportar xml a una variable XML
    SET @XMLData = (
        SELECT
            P.apellido AS 'Paciente/Apellido',
            P.nombre AS 'Paciente/Nombre',
            P.nro_de_documento AS 'Paciente/DNI',
            PR.nombre AS 'Profesional/Nombre',
            PR.nro_matricula AS 'Profesional/Matricula',
            T.fecha AS 'Fecha',
            T.hora AS 'Hora',
            E.nombre_especialidad AS 'Especialidad'
        FROM Turno.ReservaTurnoMedico AS T
        INNER JOIN Paciente.Paciente AS P ON T.id_historia_clinica = P.id_historia_clinica
        INNER JOIN Hospital.Medico AS PR ON T.id_medico = PR.id_medico
        INNER JOIN Hospital.MedicoEspecialidad AS ME ON T.id_medico_especialidad = ME.id_medico_especialidad
        INNER JOIN Hospital.Especialidad AS E ON ME.id_especialidad = E.id_especialidad
        INNER JOIN Turno.EstadoTurno AS ET ON T.id_estado_turno = ET.id_estado
        INNER JOIN ObraSocial.Prestador AS OS ON T.id_prestador = OS.id_prestador
        WHERE OS.nombre_prestador = @ObraSocialNombre
            AND T.fecha >= @FechaInicio
            AND T.fecha <= @FechaFin
            AND ET.nombre_estado = 'Atendido'
        FOR XML PATH('Turno'), ROOT('TurnosAtendidos')
    );

    -- Escribir el XMLData en un archivo temporal
    SET @FileName = 'D:\Dev\ddbba-tp-integrador\exportar\archivo.xml';
    SET @Query = 'SELECT CAST(''' + REPLACE(CONVERT(NVARCHAR(MAX), @XMLData), '''', '''''') + ''' AS XML) AS XmlData';

    -- Crear el archivo de formato XML
    SET @FormatFile = 'D:\Dev\ddbba-tp-integrador\exportar\FormatFile.xml';
    SET @FormatFileContent = '<?xml version="1.0" encoding="utf-8" ?>  
<BCPFORMAT xmlns="https://schemas.microsoft.com/sqlserver/2004/bulkload/format" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">  
   <RECORD>  
      <FIELD ID="1" xsi:type="CharTerm" TERMINATOR="\r\n" MAX_LENGTH="8000" COLLATION="SQL_Latin1_General_CP1_CI_AS"/>  
   </RECORD>  
</BCPFORMAT>';

    -- Escribir el contenido del formato en una tabla temporal
    CREATE TABLE #TempFormatFile (FormatContent NVARCHAR(MAX));
    INSERT INTO #TempFormatFile (FormatContent) VALUES (@FormatFileContent);

    -- Construir el comando BCP
    /*SET @BCPCmd = 'bcp "' + @Query + '" queryout "' + @FileName + '" -T -c -S' + @@SERVERNAME + ' -f "' + @FormatFile + '"';*/
	SET @BCPCmd = 'bcp "' + @Query + '" queryout "' + @FileName + '" -T -c -S' + @@SERVERNAME;
    EXEC xp_cmdshell @BCPCmd;

    -- Limpiar la tabla temporal
    DROP TABLE #TempFormatFile;
END;



--********************************************************

go

--Comandos para la exportación

SELECT * FROM ObraSocial.Prestador
GO
EXEC Paciente.ExportarTurnosXML 'Union Personal', '2005-01-15', '2009-03-12';

exec Turno.CrearReservaTurnoMedico
    @idHistoriaClinica = 2, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @id_prestador =1,
    @idSede = 1,
    @idEstadoTurno = 1, 
    @idTipoTurno =1

	-- Habilitar xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

