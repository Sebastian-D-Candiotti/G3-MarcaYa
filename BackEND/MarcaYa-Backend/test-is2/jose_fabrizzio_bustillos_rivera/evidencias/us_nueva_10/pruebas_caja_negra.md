# Pruebas de caja negra - US-NUEVA-10

| ID | Historia | Escenario | Precondiciones | Datos de entrada | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| BB-10-01 | US-NUEVA-10 | Codigo correcto | Usuario pendiente | 123456 vigente | Ingresar y confirmar | Activa y navega | Activa y navega | APROBADA | Rails + widget |
| BB-10-02 | US-NUEVA-10 | Codigo incorrecto | Usuario pendiente | 999999 | Confirmar | Mensaje y sin navegar | Coincide | APROBADA | Provider/widget |
| BB-10-03 | US-NUEVA-10 | Codigo vencido | Expiracion cumplida | 123456 | Confirmar | Rechazo y pendiente | Coincide | APROBADA | Reloj fake |
| BB-10-04 | US-NUEVA-10 | Codigo incompleto | Pantalla abierta | 12345 | Confirmar | No solicitar ni navegar | Coincide | APROBADA | Widget |
| BB-10-05 | US-NUEVA-10 | Codigo con letras | Pantalla abierta | 12A456 | Escribir codigo | Letra rechazada | Coincide | APROBADA | Widget |
| BB-10-06 | US-NUEVA-10 | Usuario inexistente | Ninguna cuenta | correo ausente | Verificar | 404/mensaje | Coincide | APROBADA | Provider/caso de uso |
| BB-10-07 | US-NUEVA-10 | Usuario ya activo | Cuenta verificada | 123456 | Verificar otra vez | Conflicto | Coincide | APROBADA | Caso de uso/provider |
| BB-10-08 | US-NUEVA-10 | Correo falla | Mailer fake falla | Registro valido | Registrar | Error controlado | Coincide | APROBADA | Caso de uso |
| BB-10-09 | US-NUEVA-10 | Reintento | Codigo ya usado | mismo codigo | Verificar | No segunda activacion | Coincide | APROBADA | Caso de uso |
