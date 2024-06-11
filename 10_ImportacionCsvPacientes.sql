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

	INSERT INTO Paciente.Paciente(nombre, apellido, fecha_de_nacimiento, tipo_documento, nro_de_documento, sexo_biologico, genero, nacionalidad, mail,telefono_fijo, usuario_actualizacion)
    SELECT
        nombre, apellido, CONVERT(DATE, fecha_nacimiento, 103), tipo_documento, nro_documento, COALESCE(sexo, 'X'), genero, nacionalidad, mail, telefono, SUSER_ID()
    FROM #PacienteTemp
	WHERE nro_documento not in (select nro_de_documento from Paciente.Paciente);

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


EXEC Paciente.importarPacienteDesdeCSV 'D:\Dev\ddbba-tp-integrador\Dataset\Pacientes.csv';
go
SELECT * From Paciente.Paciente
SELECT * From Paciente.Domicilio

ALTER TABLE Paciente.Domicilio
DROP COLUMN calle
GO
ALTER TABLE Paciente.Domicilio
DROP COLUMN numero
GO
ALTER TABLE Paciente.Domicilio
ADD  direccion VARCHAR(100)
