--Testing Turno
use com2900g09
go
select * from Turno.TipoTurno
select * from Turno.EstadoTurno
select * from Turno.ReservaTurnoMedico

--Creación de una nueva reserva de turno médico
exec Turno.CrearReservaTurnoMedico
    @idHistoriaClinica = 2, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @id_prestador =1,
    @idSede = 1,
    @idEstadoTurno = 1, 
    @idTipoTurno =1
--Respuesta: Reserva de turno creada exitosamente.

--Intento crear una reserva de turno médico con algun parámetro incorrecto
exec Turno.CrearReservaTurnoMedico
    @idHistoriaClinica = 2, 
    @idmedico = 2,
    @idMedicoEspecialidad = 1,
    @id_prestador =1,
    @idSede = 1,
    @idEstadoTurno = 1, 
    @idTipoTurno =1
--Respuesta: Error: Uno o más identificadores de referencia no existen.

--Actualizo una reserva de turno existente
exec Turno.ActualizarReservaTurnoMedico
    @idTurno =1,
	@idHistoriaClinica = 2, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @idPrestador =1,
    @idSede = 1,
    @idEstadoTurno = 3, 
    @idTipoTurno = 2
--Respuesta: Reserva de turno actualizada exitosamente.

--Intento actualizar una reserva de turno que no existe
exec Turno.ActualizarReservaTurnoMedico
    @idTurno =3,
	@idHistoriaClinica = 2, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @idPrestador =1,
    @idSede = 1,
    @idEstadoTurno = 3, 
    @idTipoTurno = 2
--Respuesta: Error: El turno a actualizar no existe.

--Intento actualizar una reserva de turno de un paciente que no existe
exec Turno.ActualizarReservaTurnoMedico
    @idTurno =1,
	@idHistoriaClinica = 6, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @idPrestador =1,
    @idSede = 1,
    @idEstadoTurno = 3, 
    @idTipoTurno = 2
--Respuesta: Error: El paciente no existe.

--Validamos todos los parámetros de entradad del SP, ejemplo:
--Intento actualizar una reserva de turno de un paciente que no existe
exec Turno.ActualizarReservaTurnoMedico
    @idTurno =1,
	@idHistoriaClinica = 6, 
    @idmedico = 1,
    @idMedicoEspecialidad = 1,
    @idPrestador =1,
    @idSede = 1,
    @idEstadoTurno = 3, 
    @idTipoTurno = 2
--Respuesta: Error: El paciente no existe.

--Borramos lógicamente la reserva de turno
exec Turno.EliminarReservaTurnoMedicoLogico
	@idTurno = 1
--Respuesta: Reserva de turno eliminada exitosamente.

--Intentamos borrar lógicamente la reserva de un turno que no existe
exec Turno.EliminarReservaTurnoMedicoLogico
	@idTurno = 6
--Respuesta: Error el turno no existe.

--Borramos la reserva de turno físicamente
exec Turno.EliminarReservaTurnoMedico
	@idTurno = 1
--Respuesta: Reserva de turno eliminada exitosamente.

--Intentamos borrar físicamente la reserva de un turno que no existe
exec Turno.EliminarReservaTurnoMedicoLogico
	@idTurno = 6
--Respuesta: Error el turno no existe.

--Creamos un nuevo estado de turno
exec Turno.CrearEstadoTurno
    @nombreEstado = 'Reprogramado'
--Respuesta: Estado de turno creado exitosamente.

--Intentamos crear un estado de turno que ya existe
exec Turno.CrearEstadoTurno
    @nombreEstado = 'Reprogramado'
--Respuesta: Error: El estado de turno ya existe.

--Actualizo un estado de turno
exec Turno.ActualizarEstadoTurno
    @idEstado = 6,
    @nombreEstado = 'En espera'
--Respuesta: Estado de turno actualizado exitosamente.

--Intento actualizar un estado de turno que no existe
exec Turno.ActualizarEstadoTurno
    @idEstado = 8,
    @nombreEstado = 'En espera'
--Respuesta: Error: El estado de turno a actualizar no existe.

--Intento actualizar un estado de turno con nombre vacio
exec Turno.ActualizarEstadoTurno
    @idEstado = 6,
    @nombreEstado = ''
--Respuesta: Error: El nombre del estado de turno no puede ser nulo o vacío.

--Elimino un estado de turno
exec Turno.EliminarEstadoTurno
    @idEstado = 6
--Respuesta: Estado de turno eliminado exitosamente.

--Intento eliminar un estado de turno que no existe
exec Turno.EliminarEstadoTurno
    @idEstado = 6
--Respuesta: Error: El estado de turno a eliminar no existe.

--Creamos un nuevo tipo de turno
exec Turno.CrearTipoTurno
    @nombreTipoTurno = 'Remoto'
--Respuesta: Tipo de turno creado exitosamente.

--Intentamos crear un nuevo tipo de turno que ya existe.
exec Turno.CrearTipoTurno
    @nombreTipoTurno = 'Remoto'
--Respuesta: Error: El tipo de turno ya existe.

--Eliminamos un tipo de turno
exec Turno.EliminarTipoTurno
    @idTipoTurno = 3
--Respuesta: Tipo de turno eliminado exitosamente.

--Intentamos eliminar un tipo de turno
exec Turno.EliminarTipoTurno
    @idTipoTurno = 3
--Respuesta: Error: El tipo de turno a eliminar no existe.