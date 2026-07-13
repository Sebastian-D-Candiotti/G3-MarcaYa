# Matriz de trazabilidad - US-NUEVA-10

| ID | Semana | Historia | Criterio de aceptacion | Tipo de prueba | Archivo de prueba | Caso ejecutado | Estado | Evidencia |
|---|---:|---|---|---|---|---|---|---|
| TR-10-01 | 1 | US-NUEVA-10 | Cuenta nueva pendiente | Unitaria | `test/application/use_cases/auth/registrar_usuario_test.rb` | Registro conserva PENDIENTE_VERIFICACION | APROBADA | 23/23 Rails focalizadas |
| TR-10-02 | 1 | US-NUEVA-10 | Codigo numerico de 6 digitos | Unitaria | `test/infrastructure/services/verification_code_service_test.rb` | Formato y ceros iniciales | APROBADA | 145 aserciones focalizadas |
| TR-10-03 | 1 | US-NUEVA-10 | Codigo con vigencia de 10 minutos | Unitaria | `test/infrastructure/services/verification_code_service_test.rb` | TTL exacto de 600 segundos | APROBADA | Rails focalizado |
| TR-10-04 | 1 | US-NUEVA-10 | Solo codigo correcto y vigente activa | Unitaria | `test/application/use_cases/auth/verificar_cuenta_test.rb` | Correcto, incorrecto, vencido y usado | APROBADA | Rails focalizado |
| TR-10-05 | 1 | US-NUEVA-10 | Codigo enviado al correo registrado | Unitaria | `test/application/use_cases/auth/registrar_usuario_test.rb` | Mailer recibe correo y codigo una vez | APROBADA | Fake de mailer |
| TR-10-06 | 1 | US-NUEVA-10 | Reenvio invalida codigo anterior | Unitaria | `test/application/use_cases/auth/reenviar_codigo_verificacion_test.rb` | Digest anterior reemplazado | APROBADA | Rails focalizado |
| TR-10-07 | 1 | US-NUEVA-10 | Pantalla admite seis digitos | Widget | `test/verificacion_registro_page_test.dart` | Incompleto y letras rechazados | APROBADA | 4/4 widgets |
| TR-10-08 | 1 | US-NUEVA-10 | Mensajes segun respuesta HTTP | Unitaria Flutter | `test/verificacion_cuenta_provider_test.dart` | 200, 404, 409 y 422 | APROBADA | 7/7 provider |
| TR-10-09 | 1 | US-NUEVA-10 | Navega solo si backend confirma ACTIVO | Integracion Flutter | `test/verificacion_registro_page_test.dart` | Exito navega, error permanece | APROBADA | Flutter focalizado |
