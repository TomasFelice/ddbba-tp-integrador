GO
USE com2900g09
GO
DROP PROCEDURE IF EXISTS Paciente.importarPacienteDesdeCSV
GO
CREATE PROCEDURE Paciente.importarPacienteDesdeCSV 
    @RutaArchivo VARCHAR(255)
AS
BEGIN
    CREATE TABLE #PacienteTemp (
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        fecha_nacimiento varchar(10),
        tipo_documento VARCHAR(25),
        nro_documento INT,
        sexo VARCHAR(10),
        genero VARCHAR(10),
        telefono VARCHAR(15),
        nacionalidad VARCHAR(50),
        mail VARCHAR(100),
        calle_nro VARCHAR(50),
        localidad VARCHAR(50),
        provincia VARCHAR(50)
    )

    -- Construye la sentencia BULK INSERT dinámicamente
    DECLARE @SqlQuery NVARCHAR(MAX);
    SET @SqlQuery = '
        BULK INSERT #PacienteTemp
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '';'',  -- Delimitador de campos
            ROWTERMINATOR = ''\n'',   -- Delimitador de filas
			CODEPAGE = 65001,         -- Codificación UTF-8
            FIRSTROW = 4            -- Fila a partir de la cual se deben leer los datos (si la primera fila contiene encabezados)
        );
    ';

    -- Ejecuta la sentencia dinámica
    EXEC sp_executesql @SqlQuery;

    -- Insertar datos en la tabla Paciente
    nombre VARCHAR(50),
        apellido VARCHAR(50),
        fecha_nacimiento varchar(10),
        tipo_documento VARCHAR(25),
        nro_documento INT,
        sexo VARCHAR(10),
        genero VARCHAR(10),
        telefono VARCHAR(15),
        nacionalidad VARCHAR(50),
        mail VARCHAR(100),
        calle_nro VARCHAR(50),
        localidad VARCHAR(50),
        provincia VARCHAR(50)


	INSERT INTO Paciente.Paciente(nombre, apellido, fecha_de_nacimiento, tipo_documento, nro_de_documento, sexo_biologico, genero, nacionalidad, mail,telefono_fijo)
    SELECT
        nombre, apellido, CONVERT(DATE, fecha_nacimiento, 103), tipo_documento, nro_documento, sexo, genero, nacionalidad, mail, telefono
    FROM #PacienteTemp
	WHERE nro_documento not in (select nro_de_documento from Pacientes.Paciente);

    -- Insertar datos en la tabla Domicilio
    INSERT INTO Paciente.Domicilio(calle, numero, provincia, localidad)
    SELECT
    SUBSTRING(calle_nro, 1, CHARINDEX(' ', calle_nro) - 1) AS calle, -- Extraer la calle del atributo calle_nro
    SUBSTRING(calle_nro, CHARINDEX(' ', calle_nro) + 1, LEN(calle_nro)) AS numero, -- Extraer el número de la calle del atributo calle_nro
    provincia,
    localidad
    FROM #PacienteTemp;

    PRINT 'La importación de pacientes se ha completado exitosamente.';
    DROP TABLE #PacienteTemp;
END;
go


EXEC Pacientes.importarPacienteDesdeCSV 'C:\Dataset\Pacientes.csv';
go
go
SELECT * From Pacientes.Paciente
SELECT * From Pacientes.Domicilio