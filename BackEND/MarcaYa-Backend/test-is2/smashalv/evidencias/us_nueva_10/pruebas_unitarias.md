# Pruebas unitarias - US-NUEVA-10

| ID | Historia | Componente aislado | Escenario | Dependencias simuladas | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|---|---|---|
| UT-10-01 | US-NUEVA-10 | VerificationCodeService | Genera 6 numeros | SecureRandom controlado en limite | Regex de seis digitos | Coincide | APROBADA |
| UT-10-02 | US-NUEVA-10 | VerificationCodeService | Valor 4281 | Valor aleatorio inyectado | `004281` | `004281` | APROBADA |
| UT-10-03 | US-NUEVA-10 | VerificationCodeService | Expiracion | Fecha fija | Fecha + 600 segundos | Coincide | APROBADA |
| UT-10-04 | US-NUEVA-10 | VerificationCodeService | Hash y comparacion | Sin servicios externos | No guarda texto plano | Hash valido | APROBADA |
| UT-10-05 | US-NUEVA-10 | VerificarCuenta | Codigo correcto | Repositorio y servicio fake | Usuario ACTIVO y codigo limpiado | Coincide | APROBADA |
| UT-10-06 | US-NUEVA-10 | VerificarCuenta | Incorrecto, vencido, usado e inexistente | Repositorio, servicio y reloj fake | Error de dominio sin activar | Coincide | APROBADA |
| UT-10-07 | US-NUEVA-10 | VerificarCuenta | Limite exacto de expiracion | Reloj fijo | Codigo rechazado al cumplirse 10 min | Coincide | APROBADA |
| UT-10-08 | US-NUEVA-10 | RegistrarUsuario | Registro y mail | Repositorios y mailer fake | Pendiente y un envio correcto | Coincide | APROBADA |
| UT-10-09 | US-NUEVA-10 | RegistrarUsuario | Mailer falla | Mailer que lanza error | Error de correo controlado | Coincide | APROBADA |
| UT-10-10 | US-NUEVA-10 | ReenviarCodigo | Reenvio | Repositorio y mailer fake | Nuevo digest e invalida anterior | Coincide | APROBADA |
| UT-10-11 | US-NUEVA-10 | VerificacionCuentaProvider | Respuestas API | Cliente HTTP fake | Loading, success o mensaje concreto | Coincide | APROBADA |
