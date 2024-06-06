-- ## CONVENCIONES ##

-- DB: com2900g09
-- SCHEMA: ddbba
-- TABLAS: UpperCamelCase 
-- CAMPOS: camel_case+
-- ROLES: UpperCamelCase

--------------------------------------------------
------  CREACION DB
--------------------------------------------------
USE master
GO
DROP DATABASE IF EXISTS com2900g09
GO
CREATE DATABASE com2900g09
GO
USE com2900g09
GO

/*
    * Colocamos ON DELETE CASCADE y ON UPDATE CASCADE en las relaciones para que si se elimina un registro padre, se eliminen los registros hijos
    * Definimos manualmente las CONSTRAINTS para poder nombrarlas y tener un mejor control de las mismas
    * Todo el manejo de imagenes se hará con URLS generadas desde otro sistema. No se almacenarán imagenes en la base de datos
    * El borrado lógico se realiza registrando la fecha y hora de borrado en un campo de la tabla
*/


-- Definir a donde va

CREATE PROCEDURE ddbba.actualizarAutorizacionEstudios(@id_estudio INT, @id_historia_clinica_paciente INT) --Nacho: saqué el @monto de acá, no le veo sentido
AS
BEGIN
    -- Declarar variables para los costos
    DECLARE @CostoFactura DECIMAL(10, 2);
    DECLARE @CostoAbonadoPago DECIMAL(10, 2);

    -- Obtener el costo de la factura del estudio para el paciente
    SELECT @CostoFactura = costo_factura_inicial 
    FROM Paciente.Factura 
    WHERE id_historia_clinica = @id_historia_clinica_paciente 
    AND id_estudio = @id_estudio;

    -- Obtener el monto abonado por el paciente
    SELECT @CostoAbonadoPago = SUM(p.monto)
    FROM Paciente.Pago p
    JOIN Paciente.Factura f ON p.id_pago = f.id_pago 
    WHERE f.id_historia_clinica = @id_historia_clinica_paciente 
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
        WHERE id_historia_clinica = @id_historia_clinica_paciente 
        AND id_estudio = @id_estudio;
    END
    ELSE
    BEGIN
        -- Calcular el porcentaje pagado y actualizar la factura
        UPDATE Paciente.Factura
        SET porcentaje_pagado = (@CostoAbonadoPago / @CostoFactura) * 100
        WHERE id_historia_clinica = @id_historia_clinica_paciente 
        AND id_estudio = @id_estudio;

        -- Nacho: Deberíamos poner un atributo monto adeudado?
    END
END
GO