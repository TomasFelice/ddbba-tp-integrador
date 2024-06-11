USE com2900g09
GO
--
-- Inserción:
--

-- Creo que esto de verificar si ya esta en la db y para ver si acer un update o un insert
-- no aplucaria en estos SP, capaz lo haria solo en los de carga de archivos

--------------------------------------------------------------------------------
-- Inicio Inserción de Paciente
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Paciente.InsertarPaciente
    @id_domicilio INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @apellido_materno VARCHAR(50),
    @fecha_de_nacimiento DATE,
    @tipo_documento VARCHAR(25),
    @nro_de_documento INT,
    @sexo_biologico CHAR(1),
    @genero CHAR(1),
    @nacionalidad VARCHAR(18),
    @foto_de_perfil VARCHAR(255),
    @mail VARCHAR(100),
    @telefono_fijo CHAR(15),
    @telefono_de_contacto_alternativo CHAR(15),
    @telefono_laboral CHAR(15),
    @fecha_de_registro DATE, -- Pasamos como parámetro esto ya que puede que se necesite migrar la información fiel a la db desde otro sistema.
    @fecha_de_actualizacion DATE -- Pasamos como parámetro esto ya que puede que se necesite migrar la información fiel a la db desde otro sistema.
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos -- Nacho: @Tomi f acá sí le dejamos nro de documento? porque la historia clinica se va a autoincrementar 1 en 1 y no va a coincidir nunca. Tomi: Yo acá lo dejaría porque también sabemos que nro_de_documento es UNIQUE entonces no se puede repetir. (agregué la constraint en la creción de la tabla)
        BEGIN
            UPDATE Paciente.Paciente
            SET id_domicilio = @id_domicilio,
                nombre = @nombre, 
                apellido = @apellido,
                apellido_materno = @apellido_materno,
                fecha_de_nacimiento = @fecha_de_nacimiento,
                tipo_documento = @tipo_documento,
                sexo_biologico = @sexo_biologico, 
                genero = @genero,
                nacionalidad = @nacionalidad,
                foto_de_perfil = @foto_de_perfil,
                mail = @mail,
                telefono_fijo = @telefono_fijo,
                telefono_de_contacto_alternativo = @telefono_de_contacto_alternativo,
                telefono_laboral = @telefono_laboral,
                fecha_de_registro = @fecha_de_registro,
                fecha_de_actualizacion = ISNULL(@fecha_de_actualizacion,GETDATE()),
                usuario_actualizacion = SUSER_ID() -- Tomi: Creo que hay que validar si se manda algo x input aca. Si no se manda nada, ahi si ponemos el de la sesion -- Nacho: en la inserción para mi no tiene mucho sentido, porque el id si viene de otro sistema no va a ser el mismo del propio sistema.
            WHERE nro_de_documento = @nro_de_documento ;
            SELECT 'Se actualizo correctamente al paciente ';
        END
        ELSE -- sino lo creo de 0
        BEGIN
                INSERT INTO Paciente.Paciente (
                id_domicilio,
                nombre,
                apellido,
                apellido_materno,
                fecha_de_nacimiento,
                tipo_documento,
                nro_de_documento,
                sexo_biologico,
                genero,
                nacionalidad,
                foto_de_perfil,
                mail,
                telefono_fijo,
                telefono_de_contacto_alternativo,
                telefono_laboral,
                usuario_actualizacion
            ) VALUES (
                @id_domicilio,
                @nombre,
                @apellido,
                @apellido_materno,
                @fecha_de_nacimiento,
                @tipo_documento,
                @nro_de_documento,
                @sexo_biologico,
                @genero,
                @nacionalidad,
                @foto_de_perfil,
                @mail,
                @telefono_fijo,
                @telefono_de_contacto_alternativo,
                @telefono_laboral,
                SUSER_ID() -- obtengo el id del usuario que está ejecutando en la sesión, el sp de inserción
            )
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al insertar el paciente: ', ERROR_MESSAGE();
    END CATCH
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarUsuario
    @id_historia_clinica INT,
    @nombre_usuario VARCHAR(50),
    @contrasenia VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Usuario WHERE id_historia_clinica = @id_historia_clinica) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Usuario
            SET nombre_usuario = @nombre_usuario,
                contrasenia = @contrasenia
            WHERE id_historia_clinica = @id_historia_clinica 
        END
        ELSE
        BEGIN
            INSERT INTO Paciente.Usuario (
                id_historia_clinica,
                nombre_usuario,
                contrasenia
            ) VALUES (
                @id_historia_clinica,
                @nombre_usuario,
                @contrasenia
            )
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al insertar el usuario: ', ERROR_MESSAGE();
    END CATCH
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarDomicilio
    @id_historia_clinica INT,
    @direccion VARCHAR(100),
    @piso INT,
    @departamento CHAR(10),
    @codigo_postal CHAR(10),
    @pais VARCHAR(40),
    @provincia VARCHAR(50),
    @localidad VARCHAR(50)
AS
BEGIN

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Domicilio WHERE id_historia_clinica = @id_historia_clinica) -- Si existe, actualizo los datos
       BEGIN
            UPDATE Paciente.Domicilio
            SET direccion = @direccion,
                piso = @piso,
                departamento = @departamento,
                codigo_postal = @codigo_postal,
                pais = @pais,
                provincia = @provincia,
                localidad = @localidad
            WHERE id_historia_clinica = @id_historia_clinica
       END
       ELSE
       BEGIN
            INSERT INTO Paciente.Domicilio (
                id_historia_clinica,
                direccion,
                piso,
                departamento,
                codigo_postal,
                pais,
                provincia,
                localidad
            ) VALUES (
                @id_historia_clinica,
                @direccion,
                @piso,
                @departamento,
                @codigo_postal,
                @pais,
                @provincia,
                @localidad
            )
       END
    END TRY
    BEGIN CATCH
		SELECT 'Error al insertar el domicilio: ', ERROR_MESSAGE();
    END CATCH 
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarEstudio
    @id_historia_clinica INT,
    @fecha DATE,
    @nombre_estudio VARCHAR(100),
    @autorizado BIT,
    @documento_resultado VARCHAR(255),
    @imagen_resultado VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Estudio WHERE id_historia_clinica = @id_historia_clinica) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Estudio
            SET fecha = @fecha,
                nombre_estudio = @nombre_estudio,
                autorizado = @autorizado,
                documento_resultado = @documento_resultado,
                imagen_resultado = @imagen_resultado
            WHERE id_historia_clinica = @id_historia_clinica
        END
        ELSE
        BEGIN
            INSERT INTO Paciente.Estudio (
                id_historia_clinica,
                fecha,
                nombre_estudio,
                autorizado,
                documento_resultado,
                imagen_resultado
            ) VALUES (
                @id_historia_clinica,
                @fecha,
                @nombre_estudio,
                @autorizado,
                @documento_resultado,
                @imagen_resultado
            )
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al insertar el estudio: ', ERROR_MESSAGE();
    END CATCH 
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarPago
    @fecha DATE,
    @monto DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Paciente.Pago (
            fecha,
            monto
        ) VALUES (
            @fecha,
            @monto
        )
    END TRY
    BEGIN CATCH
		SELECT 'Error al insertar el pago: ', ERROR_MESSAGE();
    END CATCH 
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarFactura
    @id_pago INT,
    @id_estudio INT,
	@id_historia_clinica INT,
    @costo_factura DECIMAL(10, 2),
    @porcentaje_pagado DECIMAL(3, 2)
AS
BEGIN
    -- Validaciones de campos obligatorios 
    IF @porcentaje_pagado > 100.00
    BEGIN
        SELECT 'El campo porcentaje_pagado no puede ser mayor que 100%', ERROR_MESSAGE();
        RETURN;
    END

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Factura WHERE id_historia_clinica = @id_historia_clinica) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Factura
            SET id_pago = @id_pago,
                id_estudio = @id_estudio,
                costo_factura = @costo_factura,
                porcentaje_pagado = @porcentaje_pagado
            WHERE id_historia_clinica = @id_historia_clinica
        END
        ELSE
        BEGIN
            -- Inserción de datos
            INSERT INTO Paciente.Factura (
                id_pago,
                id_estudio,
				id_historia_clinica,
                costo_factura,
                porcentaje_pagado
            ) VALUES (
                @id_pago,
                @id_estudio,
				@id_historia_clinica,
                @costo_factura,
                @porcentaje_pagado
            )
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al insertar la factura: ', ERROR_MESSAGE();
    END CATCH 
END
GO 
--------------------------------------------------------------------------------
-- Fin Inserción de Paciente
--------------------------------------------------------------------------------

--
-- Actualización
--

--------------------------------------------------------------------------------
-- Inicio Actualización de Paciente
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Paciente.ActualizarPaciente
	@id_historia_clinica INT,
    @id_domicilio INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @apellido_materno VARCHAR(50),
    @fecha_de_nacimiento DATE,
    @tipo_documento VARCHAR(25),
    @nro_de_documento INT,
    @sexo_biologico CHAR(1),
    @genero CHAR(1),
    @nacionalidad VARCHAR(18),
    @foto_de_perfil VARCHAR(255),
    @mail VARCHAR(100),
    @telefono_fijo CHAR(15),
    @telefono_de_contacto_alternativo CHAR(15),
    @telefono_laboral CHAR(15)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE id_historia_clinica = @id_historia_clinica)
        BEGIN
            UPDATE Paciente.Paciente
            SET id_domicilio = @id_domicilio,
                nombre = @nombre, 
                apellido = @apellido,
                apellido_materno = @apellido_materno,
                fecha_de_nacimiento = @fecha_de_nacimiento,
                nro_de_documento = @nro_de_documento,
                tipo_documento = @tipo_documento,
                sexo_biologico = @sexo_biologico, 
                genero = @genero,
                nacionalidad = @nacionalidad,
                foto_de_perfil = @foto_de_perfil,
                mail = @mail,
                telefono_fijo = @telefono_fijo,
                telefono_de_contacto_alternativo = @telefono_de_contacto_alternativo,
                telefono_laboral = @telefono_laboral,
                fecha_de_actualizacion = GETDATE(),
                usuario_actualizacion = SUSER_ID()
            WHERE nro_de_documento = @nro_de_documento
        END
        ELSE
        BEGIN
            SELECT 'El paciente con el id especificado no existe.', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al actualizar el paciente: ', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarUsuario
    @id_usuario INT,
    @nombre_usuario VARCHAR(50),
    @contrasenia VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Usuario WHERE id_usuario = @id_usuario)
        BEGIN
            UPDATE Paciente.Usuario
            SET nombre_usuario = @nombre_usuario,
                contrasenia = @contrasenia
            WHERE id_usuario = @id_usuario 
        END
        ELSE
        BEGIN
            SELECT 'El usuario con el id especificado no existe.', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al actualizar el usuario: ', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarDomicilio
    @id_domicilio INT,
    @id_historia_clinica INT,
    @direccion VARCHAR(100),
    @piso INT,
    @departamento CHAR(10),
    @codigo_postal CHAR(10),
    @pais VARCHAR(40),
    @provincia VARCHAR(50),
    @localidad VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Domicilio WHERE id_domicilio = @id_domicilio AND id_historia_clinica = @id_historia_clinica)
        BEGIN
            UPDATE Paciente.Domicilio
            SET direccion = @direccion,
                piso = @piso,
                departamento = @departamento,
                codigo_postal = @codigo_postal,
                pais = @pais,
                provincia = @provincia,
                localidad = @localidad
            WHERE id_domicilio = @id_domicilio AND id_historia_clinica = @id_historia_clinica
        END
        ELSE
        BEGIN
           SELECT 'El domicilio con el id especificado no existe.', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al actualizar el domicilio: ', ERROR_MESSAGE();
    END CATCH 
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarEstudio
    @id_estudio INT,
    @fecha DATE,
    @nombre_estudio VARCHAR(100),
    @autorizado BIT,
    @documento_resultado VARCHAR(255),
    @imagen_resultado VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Estudio WHERE id_estudio = @id_estudio)
        BEGIN
            UPDATE Paciente.Estudio
            SET fecha = @fecha,
                nombre_estudio = @nombre_estudio,
                autorizado = @autorizado,
                documento_resultado = @documento_resultado,
                imagen_resultado = @imagen_resultado
            WHERE id_estudio = @id_estudio
        END
        ELSE
        BEGIN
            SELECT 'El estudio con el id especificado no existe.', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al actualizar el estudio: ', ERROR_MESSAGE();
    END CATCH 
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarPago
    @id_pago INT,
    @fecha DATE,
    @monto DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Pago WHERE id_pago = @id_pago)
        BEGIN
            UPDATE Paciente.Pago
            SET fecha = @fecha,
                monto = @monto
            WHERE id_pago = @id_pago
        END
        ELSE 
        BEGIN
            SELECT 'El pago con el id especificado no existe.', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al actualizar el pago: ', ERROR_MESSAGE();
    END CATCH 
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarFactura
    @id_factura INT,
    @id_pago INT,
    @id_estudio INT,
	@id_historia_clinica INT,
    @costo_factura DECIMAL(10, 2),
    @porcentaje_pagado DECIMAL(3, 2)
AS
BEGIN
    IF @porcentaje_pagado > 100.00
    BEGIN
        SELECT 'El campo porcentaje_pagado no puede ser mayor que 100%', ERROR_MESSAGE();
        RETURN;
    END

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Factura WHERE id_factura = @id_factura)
        BEGIN
            UPDATE Paciente.Factura
            SET id_pago = @id_pago,
				id_estudio = @id_estudio,
				id_historia_clinica = @id_historia_clinica,
				costo_factura = @costo_factura,
                porcentaje_pagado = @porcentaje_pagado
            WHERE id_factura = @id_factura
        END
        ELSE
        BEGIN
            SELECT 'La factura con el id especificado no existe.', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
		SELECT 'Error al actualizar la factura: ', ERROR_MESSAGE();
    END CATCH 
END

--------------------------------------------------------------------------------
-- Fin Actualización de Paciente
--------------------------------------------------------------------------------

--
GO -- Eliminación
--
--------------------------------------------------------------------------------
-- Inicio Eliminar físicamente:
--------------------------------------------------------------------------------

--- Nacho: si eliminamos paciente deberíamos borrar absolutamente todo lo que está relacionado a él? :s alto quilombito. ¿Qué opinan?
--- Nacho: otra cosa, me dio pajita porque me quiero concentrar en otra cosa, pero los mensajes de error en los catch no lo puse con select concat como los otros. PENDIENTE

CREATE OR ALTER PROCEDURE Paciente.EliminarPaciente
    @id_historia_clinica INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Paciente WHERE id_historia_clinica = @id_historia_clinica)
        BEGIN
            DELETE FROM Paciente.Paciente WHERE id_historia_clinica = @id_historia_clinica;
            SELECT 'Usuario eliminado exitosamente.';
        END
        ELSE
        BEGIN
            SELECT 'Error al eliminar el usuario ya que no existe', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el usuario.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarUsuario
    @id_usuario INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Usuario WHERE id_usuario = @id_usuario)
        BEGIN
            DELETE FROM Paciente.Usuario WHERE id_usuario = @id_usuario;
            SELECT 'Usuario eliminado exitosamente.';
        END
        ELSE
        BEGIN
            SELECT 'Error al eliminar el usuario ya que no existe', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el usuario.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarDomicilio
    @id_domicilio INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Domicilio WHERE id_domicilio = @id_domicilio)
        BEGIN
            DELETE FROM Paciente.Domicilio WHERE id_domicilio = @id_domicilio;
            SELECT 'Domicilio eliminado exitosamente.';
        END
        ELSE 
        BEGIN 
            SELECT 'Error al eliminar el domicilio ya que no existe', ERROR_MESSAGE(); 
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el domicilio.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarEstudio
    @id_estudio INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Estudio WHERE id_estudio = @id_estudio)
        BEGIN
            DELETE FROM Paciente.Estudio WHERE id_estudio = @id_estudio;
            SELECT 'Estudio eliminado exitosamente.';
        END
        ELSE
        BEGIN
		    SELECT 'Error al eliminar el estudio ya que no existe', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el estudio.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarPago
    @id_pago INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Pago WHERE id_pago = @id_pago)
        BEGIN
            DELETE FROM Paciente.Pago WHERE id_pago = @id_pago;
            SELECT 'Pago eliminado exitosamente.';
        END
        ELSE
        BEGIN
		    SELECT 'Error al eliminar el pago ya que no existe', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el pago.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarFactura
    @id_factura INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Factura WHERE id_factura = @id_factura)
        BEGIN
            DELETE FROM Paciente.Factura WHERE id_factura = @id_factura;
            SELECT 'Factura eliminada exitosamente.';

            DELETE FROM Paciente.Pago WHERE id_pago 
            IN (SELECT id_pago FROM Paciente.Factura WHERE id_factura = @id_factura); -- Si elimino la factura, elimino también los pagos relacionados

        END
        ELSE
        BEGIN
		    SELECT 'Error al eliminar el domicilio ya que no existe', ERROR_MESSAGE();
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la factura.', ERROR_MESSAGE();
    END CATCH
END

GO
--------------------------------------------------------------------------------
-- Fin Eliminar físicamente:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Eliminar lógicamente:
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Paciente.EliminarPacienteLogicamente
    @id_historia_clinica INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Paciente
        SET fecha_borrado = GETDATE()
        WHERE id_historia_clinica = @id_historia_clinica;

        UPDATE Paciente.Usuario
        SET fecha_borrado = GETDATE()
        WHERE id_historia_clinica = @id_historia_clinica;

        UPDATE Paciente.Domicilio
        SET fecha_borrado = GETDATE()
        WHERE id_historia_clinica = @id_historia_clinica;

        UPDATE Paciente.Estudio
        SET fecha_borrado = GETDATE()
        WHERE id_historia_clinica = @id_historia_clinica;

        UPDATE ObraSocial.Cobertura
        SET fecha_borrado = GETDATE()
        WHERE id_historia_clinica = @id_historia_clinica;

        UPDATE Turno.ReservaTurnoMedico
        SET id_estado_turno = (SELECT id_estado FROM Turno.EstadoTurno WHERE nombre_estado = 'Cancelado')
        WHERE id_historia_clinica = @id_historia_clinica;
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el paciente lógicamente.', ERROR_MESSAGE();
    END CATCH
END

GO

CREATE OR ALTER PROCEDURE Paciente.EliminarUsuarioLogicamente 
    @id_usuario INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Usuario
        SET fecha_borrado = GETDATE()
        WHERE id_usuario = @id_usuario
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el usuario lógicamente.', ERROR_MESSAGE();
    END CATCH
END

GO

CREATE OR ALTER PROCEDURE Paciente.EliminarDomicilioLogicamente
    @id_domicilio INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Domicilio
        SET fecha_borrado = GETDATE()
        WHERE id_domicilio = @id_domicilio;
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el domicilio lógicamente.', ERROR_MESSAGE();
    END CATCH
END
GO
    

CREATE OR ALTER PROCEDURE Paciente.EliminarEstudioLogicamente
    @id_estudio INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Estudio
        SET fecha_borrado = GETDATE()
        WHERE id_estudio = @id_estudio;

        IF @@ROWCOUNT = 0 -- se utiliza para verificar si alguna de las actualizaciones realizadas en las tablas afectó alguna fila. Contiene el número de filas afectadas por la última instrucción UPDATE o DELETE.
        BEGIN
		    SELECT 'Error: El estudio a eliminar lógicamente no existe', ERROR_MESSAGE();
        END
        ELSE
        BEGIN
            SELECT 'Eomicilio eliminado lógicamente.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el estudio lógicamente.', ERROR_MESSAGE();
    END CATCH
END

GO
--------------------------------------------------------------------------------
-- Fin Eliminar lógicamente:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Inicio SP Funcionalidades:
--------------------------------------------------------------------------------

--CREATE PROCEDURE Paciente.actualizarAutorizacionEstudios(@_id NVARCHAR(40), @Area NVARCHAR(50), @Estudio NVARCHAR(100), @Prestador NVARCHAR(50), @Plan NVARCHAR(50), @Porcentaje_Cobertura INT, @Costo INT, @Requiere_Autorizacion BIT)
--AS
--BEGIN
--    -- Obtener el id de estudio correspondiente a los datos proporcionados
--    DECLARE @id_estudio INT;
--    SELECT @id_estudio = id_estudio
--    FROM Paciente.Estudio
--    WHERE Area = @Area
--    AND nombre_estudio = @Estudio
--    AND prestador = @Prestador
--    AND plan = @Plan;

--    -- Si el estudio existe, actualizar la autorización y el costo
--    IF @id_estudio IS NOT NULL
--    BEGIN
--        UPDATE Paciente.Estudio
--        SET autorizado = @Requiere_Autorizacion,
--            costo_factura_inicial = @Costo
--        WHERE id_estudio = @id_estudio;

--        -- Actualizar el porcentaje de cobertura en la factura
--        UPDATE Paciente.Factura
--        SET porcentaje_pagado = @Porcentaje_Cobertura
--        WHERE id_estudio = @id_estudio;
--    END
--    ELSE
--    BEGIN
--        SELECT 'El estudio no existe en la base de datos.';
--    END
--END
--GO

--------------------------------------------------------------------------------
-- Fin SP Funcionalidades:
--------------------------------------------------------------------------------