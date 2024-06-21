USE com2900g09
GO
DROP PROCEDURE IF EXISTS Paciente.ExportarTurnosXML
GO
GO -- Habilitar xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO
CREATE OR ALTER PROCEDURE Paciente.ExportarTurnosXML
    @ObraSocialNombre NVARCHAR(100),
    @FechaInicio DATETIME,
    @FechaFin DATETIME
AS
BEGIN

	CREATE TABLE #TempXML
	(
		nroDocumento INT,
		apellido VARCHAR(100),
		nombre VARCHAR(100),
		nombreMedico VARCHAR(100),
		matricula INT,
		fecha DATE,
		hora TIME,
		especialidad VARCHAR(50)
	)

    INSERT INTO #TempXML(nroDocumento, apellido, nombre, nombreMedico, matricula, fecha, hora, especialidad)
    SELECT
            P.nro_de_documento AS 'Paciente/DNI',
            P.apellido AS 'Paciente/Apellido',
            P.nombre AS 'Paciente/Nombre',
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

	SELECT *
	FROM #TempXML
	FOR XML PATH ('Turno'), ROOT('TurnosAtendidos')

	DECLARE @sqlCmd NVARCHAR(4000);
	SET @sqlCmd = 'SELECT * FROM #TempXML FOR XML AUTO, ROOT(''TurnosAtendidos'')';

    DECLARE @filePath NVARCHAR(255);
	SET @filePath = '"C:\Users\Ignacio Nogueira\Desktop\Unlam\BDD Aplicadas\Tps\Integrador\ddbba-tp-integrador\Archivo.xml"'; -- Ruta y nombre del archivo XML entre comillas dobles
	
	SET @sqlCmd = 'bcp "' + @sqlCmd + '" queryout ' + @filePath + ' -S ' + @@SERVERNAME + ' -T -c';
    EXEC xp_cmdshell @sqlCmd;

    DROP TABLE #TempXML
END;

--********************************************************
-- Reviso los médicos que tengo con sus especialidades, en este caso para jugar y demostrar que funciona la exportación de XML, voy a crear una reserva de turno con los siguientes datos:
-- * Estado turno: 'Atendido' | Tipo de turno: CLINICA MEDICA

-- Ingreso reservas históricas para que se corrobore que solo se exportan los turnos con estado: 'Atendido' 
GO
exec Turno.InsertarReservaTurnoMedico
    @idHistoriaClinica = 2, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @id_prestador =1,
    @idSede = 1,
    @idEstadoTurno = 1, 
    @idTipoTurno =1
GO
UPDATE Turno.ReservaTurnoMedico
set fecha = '2023-06-05'
where id_turno = 1


-- Ingreso reservas históricas con estado: 'Atendido' 
GO
exec Turno.InsertarReservaTurnoMedico
    @idHistoriaClinica = 2, 
    @idmedico = 1,
    @idMedicoEspecialidad = 3,
    @id_prestador =1,
    @idSede = 1,
    @idEstadoTurno = 4,  -- Estado: Atendido
    @idTipoTurno = 1
GO
exec Turno.InsertarReservaTurnoMedico
    @idHistoriaClinica = 3, 
    @idmedico = 1,
    @idMedicoEspecialidad = 3,
    @id_prestador =1,
    @idSede = 1,
    @idEstadoTurno = 4,  -- Estado: Atendido
    @idTipoTurno = 1
GO
UPDATE Turno.ReservaTurnoMedico
set fecha = '2023-06-05'
where id_turno = 3

-- Resultados a visualizar:
GO
-- * Paciente: Samanta Casandra Borrell Maestre (id_historia_clinica = 2)	

	select p.id_historia_clinica, p.nombre,p.apellido
	from Paciente.Paciente p 
	where p.id_historia_clinica = 2

-- * Paciente: Soledad Ani Garrido Duran (id_historia_clinica = 3)	
GO
	select p.id_historia_clinica, p.nombre,p.apellido
	from Paciente.Paciente p 
	where p.id_historia_clinica = 3

-- * Medico: Dra. ALONSO | Especialidad: CLINICA MEDICA
	--select * from Hospital.MedicoEspecialidad 
	--select * from Hospital.Especialidad 
	--select * from Hospital.Medico
GO
	select m.id_medico,m.nombre,m.nro_matricula,e.nombre_especialidad,me.id_especialidad from Hospital.Medico m JOIN
	Hospital.MedicoEspecialidad me ON m.id_medico = me.id_medico
	JOIN Hospital.Especialidad e ON e.id_especialidad = me.id_especialidad
	where m.id_medico = 1 
GO
-- * Prestador: Union Personal - Plan: Unión Personal Classic
	SELECT * FROM ObraSocial.Prestador
	WHERE nombre_prestador = 'Union Personal'
	and plan_prestador = 'Unión Personal Classic'
	

EXEC Paciente.ExportarTurnosXML 'Union Personal', '2023-06-05', '2024-06-20';





