--Tests SP Hospital

--INSERCIONES

--Inserto una nueva especialidad
EXEC Hospital.InsertarEspecialidad
	@nombre_especialidad = 'Neurología'
--Respuesta: Se insertó correctamente la especialidad

--Inserto una especialidad que ya existe
EXEC Hospital.InsertarEspecialidad
	@nombre_especialidad = 'Neurología'
--Respuesta: La especialidad ya fue insertada previamente

--Inserto un nuevo Medico
EXEC Hospital.InsertarMedico
    @nombre = 'Jorge Ezquiel',
    @apellido = 'Polito',
    @nro_matricula = 9341
--Respuesta: Se insertó correctamente el medico

--Inserto una especialidad a Medico
EXEC Hospital.InsertarMedico_Especialidad
	@id_medico = 1,
    @id_especialidad = 1
--Respuesta: Se insertó correctamente la especialidad al medico

--Inserto una especialidad a Medico que no existe
EXEC Hospital.InsertarMedico_Especialidad
	@id_medico = 39,
    @id_especialidad = 1
--Respuesta: No se puede añadir una especialidad al medico porque no existe

--Insertar Sede de Atencion
EXEC Hospital.InsertarSedeAtencion
	@nombre_sede = 'Trinidad',
    @direccion_sede 'Rivadavia 1400'
--Respuesta: Se insertó correctamente la sede de atencion

--Insertar dias por sede
EXEC Hospital.InsertarDiasPorSede
	@id_sede = 1,
    @id_medico = 1,
    @dia = '2024-06-01',
    @hora_inicio = '08:30:00',
    @hora_fin = '18:00:00'
--Respuesta: Se insertó correctamente los dias por sede

--Se actualiza una Especialidad
EXEC Hospital.ActualizarEspecialidad
	@id_especialidad = 1,
    @nombre_especialidad = 'Neurocirugía' 
--Respuesta: La especialidad se actualizo correctamente

--Se actualiza una Especialidad que no existe
EXEC Hospital.ActualizarEspecialidad
	@id_especialidad = 32,
    @nombre_especialidad = 'Neurocirugía' 
--Respuesta: La especialidad que intenta actualizar no existe

--Actualizar Medico
EXEC Hospital.ActualizarMedico
	@id_medico = 1,
    @nombre = 'Juan Jose',
    @apellido = 'Rivalta',
    @nro_matricula = 198227
--Respuesta: Se actualizo correctamente el medico
--Actualizar Medico que no existe
EXEC Hospital.ActualizarMedico
	@id_medico = 43,
    @nombre = 'Juan Jose',
    @apellido = 'Rivalta',
    @nro_matricula = 198227
--Respuesta: El medico que se intenta actualizar no existe

--Actualizar Sede de Atencion
EXEC Hospital.ActualizarSedeAtencion
	@id_sede = 1,
	@nombre_sede = 'San Juan de Dios',
    @direccion_sede = 'Sarmiento 1397'
--Respuesta: Se actualizo la sede correctamente

--Actualizar Sede de Atencion que no existe
EXEC Hospital.ActualizarSedeAtencion
	@id_sede = 112,
	@nombre_sede = 'San Juan de Dios',
    @direccion_sede = 'Sarmiento 1397'
--Respuesta: La sede que intenta actualizar no existe

--Se elimina una especialidad
EXEC Hospital.EliminarEspecialidad
	@id_especialidad =1
--Respuesta: Se elimino correctamente la especialidad
--Se elimina una especialidad que no existe
EXEC Hospital.EliminarEspecialidad
	@id_especialidad =123
--Respuesta: La especialidad que intenta eliminar no existe

--Se elimnia un medico
EXEC Hospital.EliminarMedico
	@id_medico =1
--Respuesta: Se elimino correctamente el medico

--Se elimnia un medico que no existe
EXEC Hospital.EliminarMedico
	@id_medico =123
--Respuesta: El medico que intenta eliminar no existe 
