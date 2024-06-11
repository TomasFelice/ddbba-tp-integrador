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

GRANT SELECT ON SCHEMA::Pacientes TO Paciente;
GRANT CONTROL ON OBJECT::Turno.ReservaTurnoMedico TO Paciente;

GRANT SELECT ON SCHEMA::Hospital TO Medico;

GRANT CONTROL ON SCHEMA::Pacientes TO AdministradorGeneral;
GRANT CONTROL ON SCHEMA::ObraSocial TO AdministradorGeneral;
GRANT CONTROL ON SCHEMA::Hospital TO AdministradorGeneral;
GRANT CONTROL ON SCHEMA::Turno TO AdministradorGeneral;

GRANT CONTROL ON SCHEMA::Turno TO TecnicoClinico;
GRANT CONTROL ON SCHEMA::Hospital TO TecnicoClinico;

GRANT CONTROL ON SCHEMA::Pacientes TO Administrativo;
GRANT CONTROL ON SCHEMA::Turno TO Administrativo;
