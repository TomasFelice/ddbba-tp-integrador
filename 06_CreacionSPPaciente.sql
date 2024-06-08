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
    @id_cobertura INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @apellido_materno VARCHAR(50),
    @fecha_de_nacimiento DATE,
    @tipo_documento VARCHAR(25),
    nro_de_documento INT,
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
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Paciente
            SET id_cobertura = @id_cobertura,
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
                fecha_de_actualizacion = GETDATE(),
                usuario_actualizacion = SUSER_ID() -- obtengo el id del usuario que está ejecutando en la sesión, el sp de inserción -- Tomi: Creo que hay que validar si se manda algo x input aca. Si no se manda nada, ahi si ponemos el de la sesion
            WHERE nro_de_documento = @nro_de_documento 
        END
        ELSE -- sino lo creo de 0
        BEGIN
                INSERT INTO Paciente.Paciente (
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
                telefono_laboral
            ) VALUES (
                @id_cobertura,
                @nombre,
                @apellido,
                @apellido_materno,
                @fecha_de_nacimiento,
                @nro_de_documento,
                @tipo_documento,
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
		SELECT CONCAT('Error: El paciente con dni: ', @nro_de_documento, ' no se puede insertar');
    END CATCH
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarUsuario
    @nro_de_documento INT,
    @nombre_usuario VARCHAR(50),
    @contrasenia VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Usuario WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Usuario
            SET nombre_usuario = @nombre_usuario,
                contrasenia = @contrasenia
            WHERE nro_de_documento = @nro_de_documento 
        END
        ELSE
        BEGIN
            INSERT INTO Paciente.Usuario (
                nro_de_documento,
                nombre_usuario,
                contrasenia
            ) VALUES (
                @nro_de_documento,
                @nombre_usuario,
                @contrasenia
            )
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El usuario con dni: ', @nro_de_documento, ' no se puede insertar');
    END CATCH
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarDomicilio
    @nro_de_documento INT,
    @calle VARCHAR(50),
    @numero INT,
    @piso INT,
    @departamento CHAR(10),
    @codigo_postal CHAR(10),
    @pais VARCHAR(40),
    @provincia VARCHAR(50),
    @localidad VARCHAR(50)
AS
BEGIN

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Domicilio WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos
       BEGIN
            UPDATE Paciente.Domicilio
            SET calle = @calle,
                numero = @numero,
                piso = @piso,
                departamento = @departamento,
                codigo_postal = @codigo_postal,
                pais = @pais,
                provincia = @provincia,
                localidad = @localidad
            WHERE nro_de_documento = @nro_de_documento
       END
       ELSE
       BEGIN
            INSERT INTO Paciente.Domicilio (
                nro_de_documento,
                calle,
                numero,
                piso,
                departamento,
                codigo_postal,
                pais,
                provincia,
                localidad
            ) VALUES (
                @nro_de_documento,
                @calle,
                @numero,
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
		SELECT CONCAT('Error: El domicilio del paciente con dni: ', @nro_de_documento, ' no se puede insertar');
    END CATCH 
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarEstudio
    @nro_de_documento INT,
    @fecha DATE,
    @nombre_estudio VARCHAR(100),
    @autorizado BIT,
    @documento_resultado VARCHAR(255),
    @imagen_resultado VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Estudio WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Estudio
            SET fecha = @fecha,
                nombre_estudio = @nombre_estudio,
                autorizado = @autorizado,
                documento_resultado = @documento_resultado,
                imagen_resultado = @imagen_resultado,
            WHERE nro_de_documento = @nro_de_documento
        END
        ELSE
        BEGIN
            INSERT INTO Paciente.Estudio (
                nro_de_documento,
                fecha,
                nombre_estudio,
                autorizado,
                documento_resultado,
                imagen_resultado
            ) VALUES (
                @nro_de_documento,
                @fecha,
                @nombre_estudio,
                @autorizado,
                @documento_resultado,
                @imagen_resultado
            )
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El estudio del paciente con dni: ', @nro_de_documento, ' no se puede insertar');
    END CATCH 
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarPago
    @nro_de_documento INT,
    @fecha DATE,
    @monto DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Pago WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Pago
            SET fecha = @fecha,
                monto = @monto,
            WHERE nro_de_documento = @nro_de_documento
        END
        ELSE 
        BEGIN
            INSERT INTO Paciente.Pago (
                nro_de_documento,
                fecha,
                monto
            ) VALUES (
                @nro_de_documento,
                @fecha,
                @monto
            )
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El pago del paciente con dni: ', @nro_de_documento, ' no se puede insertar');
    END CATCH 
END

--
GO
--

CREATE OR ALTER PROCEDURE Paciente.InsertarFactura
    @id_pago INT,
    @id_estudio INT,
    @costo_factura_inicial DECIMAL(10, 2),
    @costo_adeudado DECIMAL(10, 2),
    @porcentaje_pagado DECIMAL(3, 2)
AS
BEGIN
    -- Validaciones de campos obligatorios 
    IF @porcentaje_pagado > 100.00
    BEGIN
        RAISERROR ('El campo porcentaje_pagado no puede ser mayor que 100%', 16, 1);
        RETURN;
    END

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Factura WHERE nro_de_documento = @nro_de_documento) -- Si existe, actualizo los datos
        BEGIN
            UPDATE Paciente.Factura
            SET id_pago = @id_pago,
                id_estudio = @id_estudio,
                costo_factura_inicial = @costo_factura_inicial,
                costo_adeudado = @costo_adeudado,
                porcentaje_pagado = @porcentaje_pagado,
            WHERE nro_de_documento = @nro_de_documento
        END
        ELSE
        BEGIN
            -- Inserción de datos
            INSERT INTO Paciente.Factura (
                id_pago,
                id_estudio,
                costo_factura_inicial,
                costo_adeudado,
                porcentaje_pagado
            ) VALUES (
                @id_pago,
                @id_estudio,
                @costo_factura_inicial,
                @costo_adeudado,
                @porcentaje_pagado
            )
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: La factura del estudio con id', @id_estudio, ' no se puede insertar');
    END CATCH 
END

--------------------------------------------------------------------------------
-- Fin Inserción de Paciente
--------------------------------------------------------------------------------

--
GO -- Actualización
--

--------------------------------------------------------------------------------
-- Inicio Actualización de Paciente
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Paciente.ActualizarPaciente
    @id_cobertura INT,
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
        IF EXISTS (SELECT 1 FROM Paciente.Paciente WHERE nro_de_documento = @nro_de_documento)
        BEGIN
            UPDATE Paciente.Paciente
            SET id_cobertura = @id_cobertura,
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
                fecha_de_actualizacion = GETDATE(),
                usuario_actualizacion = SUSER_ID()
            WHERE nro_de_documento = @nro_de_documento
        END
        ELSE
        BEGIN
            RAISERROR ('El paciente con el documento especificado no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El paciente con con dni', @nro_de_documento, ' no se puede actualizar');
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarUsuario
    @nro_de_documento INT,
    @nombre_usuario VARCHAR(50),
    @contrasenia VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Usuario WHERE nro_de_documento = @nro_de_documento)
        BEGIN
            UPDATE Paciente.Usuario
            SET nombre_usuario = @nombre_usuario,
                contrasenia = @contrasenia
            WHERE nro_de_documento = @nro_de_documento 
        END
        ELSE
        BEGIN
            RAISERROR ('El usuario con el documento especificado no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El usuario con dni', @nro_de_documento, ' no se puede actualizar');
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarDomicilio
    @id_domicilio INT,
    @nro_de_documento INT,
    @calle VARCHAR(50),
    @numero INT,
    @piso INT,
    @departamento CHAR(10),
    @codigo_postal CHAR(10),
    @pais VARCHAR(40),
    @provincia VARCHAR(50),
    @localidad VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Domicilio WHERE id_domicilio = @id_domicilio AND nro_de_documento = @nro_de_documento)
        BEGIN
            UPDATE Paciente.Domicilio
            SET calle = @calle,
                numero = @numero,
                piso = @piso,
                departamento = @departamento,
                codigo_postal = @codigo_postal,
                pais = @pais,
                provincia = @provincia,
                localidad = @localidad
            WHERE id_domicilio = @id_domicilio AND nro_de_documento = @nro_de_documento
        END
        ELSE
        BEGIN
            RAISERROR ('El domicilio con el documento especificado no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El domicilio con id', @id_domicilio,' del paciente con dni', @nro_de_documento,' no se puede actualizar'); 
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
            RAISERROR ('El estudio con el documento especificado no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El estudio con id', @id_estudio,' no se puede actualizar'); 
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
            RAISERROR ('El pago con el documento especificado no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: El pago con id', @id_pago,' no se puede actualizar'); 
    END CATCH 
END
GO

CREATE OR ALTER PROCEDURE Paciente.ActualizarFactura
    @id_factura INT,
    @id_pago INT,
    @id_estudio INT,
    @costo_factura_inicial DECIMAL(10, 2),
    @costo_adeudado DECIMAL(10, 2),
    @porcentaje_pagado DECIMAL(3, 2)
AS
BEGIN
    IF @porcentaje_pagado > 100.00
    BEGIN
        RAISERROR ('El campo porcentaje_pagado no puede ser mayor que 100%', 16, 1);
        RETURN;
    END

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Paciente.Factura WHERE id_factura = @id_factura)
        BEGIN
            UPDATE Paciente.Factura
            SET costo_factura_inicial = @costo_factura_inicial,
                costo_adeudado = @costo_adeudado,
                porcentaje_pagado = @porcentaje_pagado
            WHERE id_pago = @id_pago AND id_estudio = @id_estudio
        END
        ELSE
        BEGIN
            RAISERROR ('La factura con los datos especificados no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
		SELECT CONCAT('Error: La factura con id', @id_factura,' no se puede actualizar'); 
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
CREATE OR ALTER PROCEDURE Paciente.EliminarUsuario
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Usuario WHERE nro_de_documento = @nro_de_documento)
        BEGIN
            DELETE FROM Paciente.Usuario WHERE nro_de_documento = @nro_de_documento;
            SELECT 'Usuario eliminado exitosamente.';
        END
        ELSE
            SELECT CONCAT('Error: El usuario con nro de documento: ', @nro_de_documento, ' no existe');
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
            SELECT CONCAT('Error: El domicilio con nro de documento: ', @nro_de_documento, ' no existe');
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
            SELECT CONCAT('Error: El estudio con nro de documento: ', @nro_de_documento, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el estudio.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarPago
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Pago WHERE nro_de_documento = @nro_de_documento)
        BEGIN
            DELETE FROM Paciente.Pago WHERE nro_de_documento = @nro_de_documento;
            SELECT 'Pago eliminado exitosamente.';
        END
        ELSE
            SELECT CONCAT('Error: El pago con nro de documento: ', @nro_de_documento, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el pago.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarFactura
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Paciente.Factura WHERE nro_de_documento = @nro_de_documento)
        BEGIN
            DELETE FROM Paciente.Factura WHERE nro_de_documento = @nro_de_documento;
            SELECT 'Factura eliminada exitosamente.';
        END
        ELSE
            SELECT CONCAT('Error: La factura con nro de documento: ', @nro_de_documento, ' no existe');
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar la factura.', ERROR_MESSAGE

GO
--------------------------------------------------------------------------------
-- Fin Eliminar físicamente:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Eliminar lógicamente:
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Paciente.EliminarPacienteLogicamente
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Paciente
        SET fecha_borrado = GETDATE()
        WHERE nro_de_documento = @nro_de_documento;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT CONCAT('Error: El paciente con nro de documento: ', @nro_de_documento, ' no existe');
        END
        ELSE
        BEGIN
            SELECT 'Paciente eliminado lógicamente.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el paciente lógicamente.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarUsuarioLogicamente
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Usuario
        SET fecha_borrado = GETDATE()
        WHERE nro_de_documento = @nro_de_documento;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT CONCAT('Error: El usuario con nro de documento: ', @nro_de_documento, ' no existe');
        END
        ELSE
        BEGIN
            SELECT 'Usuario eliminado lógicamente.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el usuario lógicamente.', ERROR_MESSAGE();
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- Inicio Eliminar lógicamente: (Esto es lo que buscabas @Tomas F?)
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Paciente.EliminarPacienteLogicamente
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Paciente
        SET fecha_borrado = GETDATE()
        WHERE nro_de_documento = @nro_de_documento;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT CONCAT('Error: El paciente con nro de documento: ', @nro_de_documento, ' no existe');
        END
        ELSE
        BEGIN
            SELECT 'Paciente eliminado lógicamente.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el paciente lógicamente.', ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Paciente.EliminarUsuarioLogicamente
    @nro_de_documento INT
AS
BEGIN
    BEGIN TRY
        UPDATE Paciente.Usuario
        SET fecha_borrado = GETDATE()
        WHERE nro_de_documento = @nro_de_documento;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT CONCAT('Error: El usuario con nro de documento: ', @nro_de_documento, ' no existe');
        END
        ELSE
        BEGIN
            SELECT 'Usuario eliminado lógicamente.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error al eliminar el usuario lógicamente.', ERROR_MESSAGE();
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- Fin Eliminar lógicamente:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Inicio SP Funcionalidades:
--------------------------------------------------------------------------------

CREATE PROCEDURE ddbba.actualizarAutorizacionEstudios(@id_estudio INT, @nro_de_documento_paciente INT) --Nacho: saqué el @monto de acá, no le veo sentido
AS
BEGIN
    -- Declarar variables para los costos
    DECLARE @CostoFactura DECIMAL(10, 2);
    DECLARE @CostoAbonadoPago DECIMAL(10, 2);

    -- Obtener el costo de la factura del estudio para el paciente
    SELECT @CostoFactura = costo_factura_inicial 
    FROM Paciente.Factura 
    WHERE nro_de_documento = @nro_de_documento_paciente 
    AND id_estudio = @id_estudio;

    -- Obtener el monto abonado por el paciente
    SELECT @CostoAbonadoPago = SUM(p.monto)
    FROM Paciente.Pago p
    JOIN Paciente.Factura f ON p.id_pago = f.id_pago 
    WHERE f.nro_de_documento = @nro_de_documento_paciente 
    AND f.id_estudio = @id_estudio;

    -- Verificar si el monto abonado es mayor o igual al costo de la factura
    IF(@CostoAbonadoPago >= @CostoFactura)
    BEGIN
        -- Actualizar el estudio como autorizado
        UPDATE Paciente.Estudio
        SET autorizado = 1
        WHERE id_estudio = @id_estudio;

        -- Registrar que el costo ha sido cubierto completamente
        UPDATE Paciente.Factura
        SET porcentaje_pagado = 100
        WHERE nro_de_documento = @nro_de_documento_paciente 
        AND id_estudio = @id_estudio;
    END
    ELSE
    BEGIN
        -- Calcular el porcentaje pagado y actualizar la factura
        UPDATE Paciente.Factura
        SET porcentaje_pagado = (@CostoAbonadoPago / @CostoFactura) * 100
        WHERE nro_de_documento = @nro_de_documento_paciente 
        AND id_estudio = @id_estudio;

        -- Nacho: Deberíamos poner un atributo monto adeudado?
    END
END
GO

--------------------------------------------------------------------------------
-- Fin SP Funcionalidades:
--------------------------------------------------------------------------------