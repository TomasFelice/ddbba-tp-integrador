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
            SELECT CONCAT('Error: La especialidad con nombre: ', @nombre_especialidad, ' ya existe');
        END
        ELSE
        BEGIN
            INSERT INTO Hospital.Especialidad (nombre_especialidad)
            VALUES (@nombre_especialidad)
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: La especialidad con nombre: ', @nombre_especialidad, ' no se puede insertar')
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
		SELECT CONCAT('Error: El medico con matricula: ', @nro_matricula, ' no se puede insertar')
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
           SELECT CONCAT('Error: La relacion medico-especialidad con id_medico: ', @id_medico, ' y id_especialidad: ', @id_especialidad, ' ya existe');
        END
        ELSE
        BEGIN
            INSERT INTO Hospital.Medico_Especialidad (id_medico, id_especialidad)
            VALUES (@id_medico, @id_especialidad);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: la relación medico-especialidad con id_medico: ', @id_medico, ' y id_especialidad: ', @id_especialidad, ' no se puede insertar')
    END CATCH
END

CREATE OR ALTER PROCEDURE Hospital.InsertarSedeAtencion
    @nombre_sede VARCHAR(50),
    @direccion_sede VARCHAR(50)
AS
BEGIN
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
END
GO

CREATE OR ALTER PROCEDURE Hospital.InsertarDiasPorSede
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
        SELECT CONCAT('Error: El dia de la sede de atencion con id_sede: ', @id_sede, ' y id_medico: ', @id_medico, ' no se puede insertar ya que ', ERROR_MESSAGE());
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
            WHERE id_especialidad = @id_especialidad;
        END
        ELSE
        BEGIN
            SELECT CONCAT('Error: La especialidad con id: ', @id_especialidad, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La actualización de la especialidad con id: ', @id_especialidad, ' no se pudo realizar');
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
            SELECT CONCAT('Error: El medico con id: ', @id_medico, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La actualización del medico con id: ', @id_medico, ' no se pudo realizar');
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
            SELECT CONCAT('Relacion medico-especialidad actualizada correctamente.');
        END
        ELSE
        BEGIN
            SELECT CONCAT('Error: El medico con id: ', @id_medico, ' o la especialidad con id: ', @id_especialidad, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La actualización de la relacion medico-especialidad con id_medico: ', @id_medico, ' y id_especialidad: ', @id_especialidad, ' no se pudo realizar');
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
            SELECT CONCAT('Error: La sede de atencion con nombre: ', @nombre_sede, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La actualización de la sede de atencion con nombre: ', @nombre_sede, ' no se pudo realizar');
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
            SELECT CONCAT('Error: La especialidad con id: ', @id_especialidad, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La eliminación de la especialidad con id: ', @id_especialidad, ' no se pudo realizar');
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
            SELECT CONCAT('Error: El medico con id: ', @id_medico, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La eliminación del medico con id: ', @id_medico, ' no se pudo realizar');
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
            SELECT CONCAT('Relacion medico-especialidad eliminada correctamente.');
        END
        ELSE
        BEGIN
            SELECT CONCAT('Error: El medico con id: ', @id_medico, ' o la especialidad con id: ', @id_especialidad, ' no existe');
        END
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Error: La eliminación de la relacion medico-especialidad con id_medico: ', @id_medico, ' y id_especialidad: ', @id_especialidad, ' no se pudo realizar');
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE Hospital.EliminarMedico_Especialidad


