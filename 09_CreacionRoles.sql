--------------------------------------------------
------  CREACION ROLES
--------------------------------------------------
-- Definir como los vamos a usar --
-- CREATE ROLE Paciente
-- GO
-- CREATE ROLE Medico
-- GO
-- CREATE ROLE AdministradorGeneral
-- GO
-- CREATE ROLE TecnicoClinico
-- GO
-- CREATE ROLE Administrativo
-- GO

USE com2900g09 
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Paciente')
DROP LOGIN Paciente;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Medico')
DROP LOGIN Medico;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'AdministradorGeneral')
DROP LOGIN AdministradorGeneral;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'TecnicoClinico')
DROP LOGIN TecnicoClinico;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Administrativo')
DROP LOGIN Administrativo;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Paciente')
DROP USER Paciente;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Medico')
DROP USER Medico;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministradorGeneral')
DROP USER AdministradorGeneral;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TecnicoClinico')
DROP USER TecnicoClinico;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrativo')
DROP USER Administrativo;

CREATE LOGIN Paciente WITH PASSWORD = 'BocaJuniors'
CREATE LOGIN Medico WITH PASSWORD = 'BocaJuniors'
CREATE LOGIN AdministradorGeneral WITH PASSWORD = 'BocaJuniors'
CREATE LOGIN TecnicoClinico WITH PASSWORD = 'BocaJuniors'
CREATE LOGIN Administrativo WITH PASSWORD = 'BocaJuniors'

CREATE USER Paciente FOR LOGIN Paciente
CREATE USER Medico FOR LOGIN Medico
CREATE USER AdministradorGeneral FOR LOGIN AdministradorGeneral
CREATE USER TecnicoClinico FOR LOGIN TecnicoClinico
CREATE USER Administrativo FOR LOGIN Administrativo

GRANT SELECT ON SCHEMA::Paciente TO Paciente;
GRANT CONTROL ON OBJECT::Turno.ReservaTurnoMedico TO Paciente;

GRANT SELECT ON SCHEMA::Hospital TO Medico;

GRANT CONTROL ON SCHEMA::Paciente TO AdministradorGeneral;
GRANT CONTROL ON SCHEMA::ObraSocial TO AdministradorGeneral;
GRANT CONTROL ON SCHEMA::Hospital TO AdministradorGeneral;
GRANT CONTROL ON SCHEMA::Turno TO AdministradorGeneral;

GRANT CONTROL ON SCHEMA::Turno TO TecnicoClinico;
GRANT CONTROL ON SCHEMA::Hospital TO TecnicoClinico;

GRANT CONTROL ON SCHEMA::Paciente TO Administrativo;
GRANT CONTROL ON SCHEMA::Turno TO Administrativo;
