--Tests SP Paciente

--INSERCIONES
--Inserto un nuevo paciente
EXEC Paciente.InsertarPaciente
    @nombre = 'Juan',
    @apellido = 'Rodriguez',
    @apellido_materno = 'Gonzalez',
    @fecha_de_nacimiento = '1980-01-01',
    @tipo_documento = 'DNI',
    @nro_de_documento = 43211234,
    @sexo_biologico = 'Masculino',
    @genero = 'Masculino',
    @nacionalidad = 'Argentino',
    @foto_de_perfil = 'path/to/foto.jpg',
    @mail = 'juan.perez@example.com',
    @telefono_fijo = '1234567',
    @telefono_de_contacto_alternativo = '7654321',
    @telefono_laboral = '2345678',
    @fecha_de_registro = '2024-06-01',
    @fecha_de_actualizacion = '2024-06-11';
--Respuesta: Se insertó correctamente el paciente

--Actualizo el paciente
EXEC Paciente.InsertarPaciente
    @nombre = 'Juan',
    @apellido = 'Rodriguez',
    @apellido_materno = 'Gonzalez',
    @fecha_de_nacimiento = '1980-01-01',
    @tipo_documento = 'DNI',
    @nro_de_documento = 12345678,
    @sexo_biologico = 'Masculino',
    @genero = 'Masculino',
    @nacionalidad = 'Argentino',
    @foto_de_perfil = 'path/to/foto.jpg',
    @mail = 'juan.perez@outlook.com',
    @telefono_fijo = '12345678',
    @telefono_de_contacto_alternativo = '87654321',
    @telefono_laboral = '2345678',
    @fecha_de_registro = '2024-06-01',
    @fecha_de_actualizacion = '2024-06-11';
--Respuesta: Se actualizo correctamente al paciente

--Inserto un usuario
exec Paciente.InsertarUsuario @id_historia_clinica = 3, @nombre_usuario = 'Boca', @contrasenia = 'Juniors'
--Respuesta: Inserción correcta

--Intento insertar un usuario con el mismo nombre de usuario
exec Paciente.InsertarUsuario @id_historia_clinica = 4, @nombre_usuario = 'Boca', @contrasenia = 'Campeon'
--Respuesta: Error al insertar el usuario: Violation of UNIQUE KEY constraint 'UQ__UsuarioB__D4D22D74295CB686'. Cannot insert duplicate key in object 'Paciente.Usuario'.

--Intento insertar un usuario que con un id_historia_clinica inválido
exec Paciente.InsertarUsuario @id_historia_clinica = 9, @nombre_usuario = 'JuanRoman', @contrasenia = 'Riquelme'
--Respuesta: Error al insertar el usuario: The INSERT statement conflicted with the FOREIGN KEY constraint "fk_usuario_historia_clinica". The conflict occurred in database "com2900g09", table "Paciente.Paciente", column 'id_historia_clinica'.


--Inserto un domicilio
exec Paciente.InsertarDomicilio
	@id_historia_clinica = 4,
    @calle ='La Boca',
    @numero= 321,
    @piso =2,
    @departamento ='B1',
    @codigo_postal= 1234,
    @pais = 'Argentina',
    @provincia ='Capital Federal',
    @localidad = 'La Boca'
--Respuesta: Inserción correcta

select * from DomicilioBDA

--Inserto un domicilio con un id_historia_clinica inválido
exec Paciente.InsertarDomicilio
	@id_historia_clinica = 9,
    @calle ='La Boca',
    @numero= 321,
    @piso =2,
    @departamento ='B1',
    @codigo_postal= 1234,
    @pais = 'Argentina',
    @provincia ='Capital Federal',
    @localidad = 'La Boca'
--Respuesta: Error al insertar el domicilio: The INSERT statement conflicted with the FOREIGN KEY constraint "fk_historia_clinica". The conflict occurred in database "com2900g09", table "Paciente.Paciente", column 'id_historia_clinica'.

--Insertar un pago
exec Paciente.InsertarPago
@fecha = '2024-06-01',
    @monto = 1000.00
--Respuesta: Inserción correcta

--Insertar una factura
exec Paciente.InsertarFactura
    @id_pago = 1,
    @id_estudio = 'A1234',
	@id_historia_clinica = 3,
    @costo_factura = 302,
    @porcentaje_pagado = 0
--Respuesta: Inserción correcta

--Intento insertar una factura con un id_pago inválido
exec Paciente.InsertarFactura
    @id_pago = 10,
    @id_estudio = 'A1234',
	@id_historia_clinica = 3,
    @costo_factura = 302,
    @porcentaje_pagado = 0
--Respuesta: Error al insertar la factura: The UPDATE statement conflicted with the FOREIGN KEY constraint "fk_factura_pago". The conflict occurred in database "com2900g09", table "Paciente.Pago", column 'id_pago'.

--Intento insertar una factura con un @id_estudio inválido
exec Paciente.InsertarFactura
    @id_pago = 1,
    @id_estudio = 'ARE1234',
	@id_historia_clinica = 3,
    @costo_factura = 302,
    @porcentaje_pagado = 0
--Respuesta: Error al insertar la factura: The UPDATE statement conflicted with the FOREIGN KEY constraint "fk_factura_estudio". The conflict occurred in database "com2900g09", table "Paciente.Estudio", column 'id_estudio'.

--Intento insertar una factura con un @id_historia_clinica inválido
exec Paciente.InsertarFactura
    @id_pago = 1,
    @id_estudio = 'A1234',
	@id_historia_clinica = 9,
    @costo_factura = 302,
    @porcentaje_pagado = 0
--Respuesta: Error al insertar la factura: The INSERT statement conflicted with the FOREIGN KEY constraint "fk_factura_historia_clinica". The conflict occurred in database "com2900g09", table "Paciente.Paciente", column 'id_historia_clinica'.

--ACTUALIZACIONES
--Actualizo un paciente
exec Paciente.ActualizarPaciente
	@id_historia_clinica = 3,
	@nombre = 'Richard',
    @apellido = 'Klein',
    @apellido_materno = 'Endrick',
    @fecha_de_nacimiento = '1981-01-01',
    @tipo_documento = 'DNI',
    @nro_de_documento = 12345678,
    @sexo_biologico = 'Masculino',
    @genero = 'Masculino',
    @nacionalidad = 'Argentino',
    @foto_de_perfil = 'path/to/foto.jpg',
    @mail = 'juan.perez@example.com',
    @telefono_fijo = '1234567',
    @telefono_de_contacto_alternativo = '7654321',
    @telefono_laboral = '2345678'
--Respuesta: Actualizacion correcta

--Intento actualizar un paciente que no existe
exec Paciente.ActualizarPaciente
	@id_historia_clinica = 8,
	@nombre = 'Richard',
    @apellido = 'Klein',
    @apellido_materno = 'Endrick',
    @fecha_de_nacimiento = '1981-01-01',
    @tipo_documento = 'DNI',
    @nro_de_documento = 12345678,
    @sexo_biologico = 'Masculino',
    @genero = 'Masculino',
    @nacionalidad = 'Argentino',
    @foto_de_perfil = 'path/to/foto.jpg',
    @mail = 'juan.perez@example.com',
    @telefono_fijo = '1234567',
    @telefono_de_contacto_alternativo = '7654321',
    @telefono_laboral = '2345678'
--Respuesta: El paciente con el id especificado no existe.

--Actualizo un usuario
exec Paciente.ActualizarUsuario
    @id_usuario = 2,
    @nombre_usuario = 'Velez',
    @contrasenia = 'Sarfield'
--Respuesta: Actualizacion correcta

--Intento actualizar un usuario inexistente
exec Paciente.ActualizarUsuario
    @id_usuario = 6,
    @nombre_usuario = 'Velez',
    @contrasenia = 'Sarfield'
--Respuesta: El usuario con el id especificado no existe.

--BORRADO
--Borrado de un paciente (físico)
exec Paciente.EliminarPaciente
   @id_historia_clinica = 3
--Respuesta: Usuario eliminado exitosamente.

--Intento borrar un paciente que no existe
exec Paciente.EliminarPaciente
   @id_historia_clinica = 9
--Respuesta: Error al eliminar el usuario ya que no existe

--Borrar paciente (lógicamente)
exec Paciente.EliminarPacienteLogicamente
    @id_historia_clinica = 4
--Respuesta: Borrado lógico exitoso
--No funciona correctamente este SP

--Intentar borrar paciente que no existe
exec Paciente.EliminarPacienteLogicamente
    @id_historia_clinica = 9
--Respuesta: Error: El paciente a eliminar lógicamente no existe
