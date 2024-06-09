USE com2900g09

--
GO -- Inserción: 
--

-- NACHO: faltan actualizar varios sp con condiciones lógicas de que si se elimina/inserta/actualiza alguno hay que tener en cuenta cómo le pega a las tablas

CREATE OR ALTER PROCEDURE Hospital.InsertarEspecialidad
    @nombre_especialidad VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Especialidad WHERE nombre_especialidad = @nombre_especialidad)
        BEGIN
		SELECT CONCAT('Error la especialidad ya fue insertada previamente', ERROR_MESSAGE());
        END
        ELSE
        BEGIN
            INSERT INTO Hospital.Especialidad (nombre_especialidad)
            VALUES (@nombre_especialidad)
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error al insertar el especialidad: ', ERROR_MESSAGE());
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.InsertarMedico
    @id_especialidad INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @nro_matricula CHAR(10)
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Medico WHERE nro_matricula = @nro_matricula)
        BEGIN
            
            /*UPDATE Hospital.Medico
            SET id_especialidad = @id_especialidad,
                nombre = @nombre,
                apellido = @apellido
            WHERE nro_matricula = @nro_matricula; -- Nacho: en caso de resolver línea 19 de archivo 04_CreacionSchemaHospital.sql actualizarlo por id_medico

            UPDATE Hospital.Medico
            SET id_especialidad = @id_especialidad,
                nombre = @nombre,
                apellido = @apellido
            WHERE nro_matricula = @nro_matricula; -- Nacho: deberíamos tener en cuenta que acá le deberíamos pegar a la tabla de medico_especialidad, no? */
        END
        ELSE
        BEGIN
            INSERT INTO Hospital.Medico (id_especialidad, nombre, apellido, nro_matricula)
            VALUES (@id_especialidad, @nombre, @apellido, @nro_matricula);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error al insertar médico: ', ERROR_MESSAGE())
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.InsertarMedico_Especialidad
    @id_medico INT,
    @id_especialidad INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Medico_Especialidad WHERE id_medico = @id_medico AND id_especialidad = @id_especialidad)
        BEGIN
           SELECT CONCAT('Error: La relacion medico-especialidad ya existen', ERROR_MESSAGE())
        END
        ELSE
        BEGIN
            INSERT INTO Hospital.Medico_Especialidad (id_medico, id_especialidad)
            VALUES (@id_medico, @id_especialidad);
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al insertar la relación medico-especialidad', ERROR_MESSAGE())
    END CATCH
END

CREATE OR ALTER PROCEDURE Hospital.InsertarSedeAtencion
    @nombre_sede VARCHAR(50),
    @direccion_sede VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.SedeDeAtencion WHERE nombre_sede = @nombre_sede)
        BEGIN
            UPDATE Hospital.SedeDeAtencion 
            SET direccion_sede = @direccion_sede 
            WHERE nombre_sede = @nombre_sede; -- Nos guiamos de la actualización si existe el nombre de la sede
        END
        ELSE
        BEGIN
            INSERT INTO Hospital.SedeDeAtencion (nombre_sede, direccion_sede)
            VALUES (@nombre_sede, @direccion_sede);
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al insertar la sede de atención', ERROR_MESSAGE())
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Hospital.InsertarDiasPorSede --------- revisar
    @id_sede INT,
    @id_medico INT,
    @dia VARCHAR(9),
    @hora_inicio TIME,
    @hora_fin TIME
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Hospital.DiasPorSede WHERE id_sede = @id_sede AND id_medico = @id_medico)
        BEGIN
            UPDATE Hospital.DiasPorSede 
            SET hora_inicio = @hora_inicio, hora_fin = @hora_fin 
            WHERE id_sede = @id_sede AND id_medico = @id_medico;
        END
        ELSE IF EXISTS (SELECT 1 FROM Hospital.DiasPorSede WHERE id_sede = @id_sede AND id_medico = @id_medico AND dia = @dia)
        BEGIN
            INSERT INTO Hospital.DiasPorSede (id_sede, id_medico, dia, hora_inicio, hora_fin)
            VALUES (@id_sede, @id_medico, @dia, @hora_inicio, @hora_fin);
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al insertar la relación dias por sede', ERROR_MESSAGE())
    END CATCH
END
GO


--
GO -- Actualización
-- 

CREATE OR ALTER PROCEDURE Hospital.ActualizarEspecialidad
    @id_especialidad INT,
    @nombre_especialidad VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Especialidad WHERE id_especialidad = @id_especialidad)
        BEGIN
            UPDATE Hospital.Especialidad
            SET nombre_especialidad = @nombre_especialidad
            WHERE id_especialidad = @id_especialidad
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: La especialidad buscada a actualizar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al actualizar la especialidad', ERROR_MESSAGE())
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.ActualizarMedico
    @id_medico INT,
    @id_especialidad INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @nro_matricula CHAR(10)
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Medico WHERE id_medico = @id_medico)
        BEGIN
            UPDATE Hospital.Medico
            SET
                id_especialidad = @id_especialidad,
                nombre = @nombre,
                apellido = @apellido,
                nro_matricula = @nro_matricula
            WHERE id_medico = @id_medico; -- Nacho: en caso de resolver línea 19 de archivo 04_CreacionSchemaHospital.sql actualizarlo por nro_matricula
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: El médico buscado a actualizar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al actualizar medico', ERROR_MESSAGE())
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.ActualizarMedico_Especialidad
    @id_medico INT,
    @id_especialidad INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Medico WHERE id_medico = @id_medico AND EXISTS(SELECT 1 FROM Hospital.Especialidad WHERE id_especialidad = @id_especialidad))
        BEGIN
            UPDATE Hospital.Medico_Especialidad
            SET
                id_especialidad = @id_especialidad
            WHERE id_medico = @id_medico;
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: La relación medico-especialidad buscada a actualizar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al actualizar la relación medico-especialidad', ERROR_MESSAGE())
    END CATCH
END


CREATE OR ALTER PROCEDURE Hospital.ActualizarSedeAtencion
    @nombre_sede VARCHAR(50),
    @direccion_sede VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.SedeDeAtencion WHERE nombre_sede = @nombre_sede)
        BEGIN
            UPDATE Hospital.SedeDeAtencion
            SET
                nombre_sede = @nombre_sede,
                direccion_sede = @direccion_sede
            WHERE nombre_sede = @nombre_sede;
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: La sede de atención buscada a actualizar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al actualizar la sede de atencion', ERROR_MESSAGE())
    END CATCH
END


--
GO -- Eliminación:
--

CREATE OR ALTER PROCEDURE Hospital.EliminarEspecialidad
    @id_especialidad INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Especialidad WHERE id_especialidad = @id_especialidad)
        BEGIN
            DELETE FROM Hospital.Especialidad
            WHERE id_especialidad = @id_especialidad;
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: La especialidad buscada a eliminar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al eliminar la especialidad', ERROR_MESSAGE())
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.EliminarMedico -- PENDIENTE: acá deberíamos tener en cuenta también que si eliminamos un médico puede impactar en las tablas médico especialidad, los días por sede, la reserva del algún turno y los días x sede
    @id_medico INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Medico WHERE id_medico = @id_medico)
        BEGIN
            DELETE FROM Hospital.Medico
            WHERE id_medico = @id_medico;
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: El médico buscado a eliminar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al eliminar el médico', ERROR_MESSAGE())
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.EliminarMedico_Especialidad
    @id_medico INT,
    @id_especialidad INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Hospital.Medico WHERE id_medico = @id_medico AND EXISTS(SELECT 1 FROM Hospital.Especialidad WHERE id_especialidad = @id_especialidad))
        BEGIN
            DELETE FROM Hospital.Medico_Especialidad
            WHERE id_medico = @id_medico AND id_especialidad = @id_especialidad;
        END
        ELSE
        BEGIN
           SELECT CONCAT('Error: La relación medico-especialidad buscada a eliminar no existe', ERROR_MESSAGE())
        END
    END TRY
    BEGIN CATCH
           SELECT CONCAT('Error: Error al eliminar la relación medico-especialidad', ERROR_MESSAGE())
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.EliminarMedico_Especialidad


