--Tests SP ObraSocial

--INSERCIONES

--Inserto un nuevo Prestador
EXEC ObraSocial.InsertarPrestador
    @nombrePrestador = 'OSDE',
    @planPrestador = 'Plan 1'
--Respuesta: Se insert� correctamente el paciente
GO

--Inserto un nuevo Prestador
EXEC ObraSocial.InsertarPrestador
    @nombrePrestador = 'Galeno',
    @planPrestador = 'Plan Azul 220'
--Respuesta: Se insert� correctamente el paciente
GO

--Inserto un Prestador ya existente
EXEC ObraSocial.InsertarPrestador
    @nombrePrestador = 'OSDE',
    @planPrestador = 'Plan 1'
--Respuesta: Prestador ya existente. No se realiza accion
GO

--Inserto un tipo de cobertura
EXEC ObraSocial.insertarTipoCobertura
    @nombreTipoCobertura = 'Plan Basico'
--Respuesta: Tipo de cobertura creado exitosamente
GO
--Inserto un tipo de cobertura
EXEC ObraSocial.insertarTipoCobertura
    @nombreTipoCobertura = 'Plan Ampliado'
--Respuesta: Tipo de cobertura creado exitosamente
GO
--Inserto un tipo de cobertura
EXEC ObraSocial.insertarTipoCobertura
    @nombreTipoCobertura = 'Plan Ampliado'
--Respuesta: Tipo de cobertura ya existente.
GO
--Inserto una cobertura
EXEC ObraSocial.insertarCobertura
    @idPrestador = 1, -- OSDE, creada previamente
    @idHistoriaClinica = 1,
    @idTipoCobertura = 1,
    @imagenCredencial = '',
    @nroSocio = 12345678
--Respuesta: Cobertura creada exitosamente.
GO
--Inserto una cobertura
EXEC ObraSocial.insertarCobertura
    @idPrestador = 2, -- Galeno, creada previamente
    @idHistoriaClinica = 2,
    @idTipoCobertura = 2,
    @imagenCredencial = '',
    @nroSocio = 12345679
--Respuesta: Cobertura creada exitosamente.
GO

--Inserto una cobertura repetida
EXEC ObraSocial.insertarCobertura
    @idPrestador = 2, -- Galeno, creada previamente
    @idHistoriaClinica = 2,
    @idTipoCobertura = 2,
    @imagenCredencial = '',
    @nroSocio = 12345679
--Respuesta: Error al crear la reserva de turno.'
GO

-- ACTUALIZACION
EXEC ObraSocial.actualizarPrestador
    @idPrestador = 2, -- Galeno, creada previamente
    @nombrePrestador = NULL,
    @planPrestador = 'Plan Verde 420'
--Respuesta: Prestador actualizado exitosamente.
GO

EXEC ObraSocial.actualizarTipoCobertura
    @idTipoCobertura = 1,
    @nombreTipoCobertura = 'Plan Extra Basico'
--Respuesta: Prestador actualizado exitosamente.
GO

EXEC ObraSocial.actualizarCobertura
    @idCobertura = 1,
    @idPrestador = 1, -- OSDE
    @idHistoriaClinica = 2,
    @idTipoCobertura = 1,
    @imagenDeLaCredencial = 'pepe.png',
    @nroDeSocio = 12345876
--Respuesta: Prestador actualizado exitosamente.
GO

--BORRADO

EXEC ObraSocial.eliminarPrestador
    @idPrestador = 1 -- OSDE
--Respuesta: Prestador eliminado exitosamente.
GO

EXEC ObraSocial.eliminarTipoCobertura
    @idTipoCobertura = 1
--Respuesta: Tipo de cobertura eliminado exitosamente.
GO

EXEC ObraSocial.eliminarCobertura
    @idCobertura = 1
--Respuesta: Cobertura eliminada exitosamente.
GO
