--Fecha de entrega: 11/06
--Número de grupo: 09
--Materia:BASES DE DATOS APLICADAS
--Alumnos:


--44789809 Felice Tomás Agustín tfelice@alumno.unlam.edu.ar 

--41714018 Nogueira Ignacio Ezequiel inogueira@alumno.unlam.edu.ar 

--43242414 Romano Luciano Javier lromano@alumno.unlam.edu.ar 

--42283011 Saquilan Tomás tsaquilan@alumno.unlam.edu.ar

--Trabajo práctico Integrador

--Se detalla a continuación el proceso de instalación y configuración aplicada para Microsoft SQL Server.
--Ubicación de los Medios: D:\SQL2022
--Nombre de la instancia SQLEXPRESS

--Se utilizara para administrar el motor de base de datos SQL Server Management Studio v19.1.
--En la unidad C:\Program Files (x86)\Microsoft SQL Server Management Studio 19.
--Configuración Aplicada:
--Server Name: DESKTOP-707ICIM\MSSQL
--Lenguaje: Inglés (Estados Unidos)
--Memoria asignada: 7569 MB
--Processors: 12
--Server Collation: SQL_Latin1_General_CP1_CI_AS
--TCP Port: 49172

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

