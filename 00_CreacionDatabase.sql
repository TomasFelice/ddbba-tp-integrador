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
CREATE DATABASE com2900g09 COLLATE SQL_Latin1_General_CP1_CI_AS
GO
USE com2900g09
GO

/*
    * Colocamos ON DELETE CASCADE y ON UPDATE CASCADE en las relaciones para que si se elimina un registro padre, se eliminen los registros hijos
    * Definimos manualmente las CONSTRAINTS para poder nombrarlas y tener un mejor control de las mismas
    * Todo el manejo de imagenes se hará con URLS generadas desde otro sistema. No se almacenarán imagenes en la base de datos
    * El borrado lógico se realiza registrando la fecha y hora de borrado en un campo de la tabla
*/

