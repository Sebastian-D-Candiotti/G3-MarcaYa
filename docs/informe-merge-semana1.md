# Informe de Merge — Semana 1

Tres branches desarrollados en paralelo se mergearon a `main`. Esto es lo que falló en cada uno y cómo se arregló.

---

## Angelo — Verificación OTP de RUC

**Branch:** `feature/Semana1_Angelo`

Angelo laburó la verificación por OTP para el RUC de empresas. El problema: su branch modificaba archivos que nosotros también habíamos tocado en `main` (auth controller, mailer, rutas), así que al mergear explotó todo.

**Lo que falló:**

- **`auth_controller.rb`**: él agregó endpoints para verificar OTP y tocó `skip_before_action`. Nosotros también habíamos agregado endpoints de recuperación de contraseña. Al mergear, los `skip_before_action` se pisaron y faltaban endpoints.
- **`application_mailer.rb`**: él puso un `default from` con su mail, nosotros teníamos otro. Hubo que unificarlo con variable de entorno.
- **`development.rb`**: la configuración SMTP quedó mezclada con el modo `:test` y no se mandaban mails.
- **`routes.rb`**: sus rutas de SUNAT y las nuestras de recovery de contraseña se superponían.

**Errores post-merge:**

- Quedó un `end` de más en `auth_controller.rb` y Rails directamente no arrancaba. Lo saqué.
- El server no reconocía `UsuarioMailer` (tiraba `NoMethodError`). Había que reiniciar Rails para que levante las clases nuevas.

---

## Verificación de cuenta — Confirmación por correo

**Branch:** `feature/historia-usuario-verificacion-cuenta`

Este branch agregaba el flujo de verificación de cuenta: cuando alguien se registra, queda en `PENDIENTE_VERIFICACION` hasta que confirma con un código que llega por mail.

**Lo que falló:**

- **`auth_controller.rb`**: otra vez `skip_before_action`. Tres branches distintos tocando la misma línea. Un desastre.
- **`auth_facade.rb`** y **`registrar_usuario.rb`**: el branch agregaba dependencias nuevas (`verification_code_service`, `verification_mailer`) pero el `initialize` del facade y del use case no las tenía. Al mergear, Ruby se quejaba de que faltaban argumentos.
- **`dependency_injection.rb`**: el container de DI tenía que levantar los servicios nuevos. El branch los registraba pero pisaba la config de password recovery que ya estaba en `main`.
- **`routes.rb`**: rutas de verificación + sunat + auth todo mezclado.
- **`schema.rb`**: dos migraciones en paralelo (una de ellos, otra nuestra) y el schema quedó inconsistente.
- **Frontend (`registrar_empresa.dart`, `api_service.dart`)**: el flujo de registro no redirigía a verificación, y el `api_service` tenía métodos que se pisaban entre sí.

**Errores post-merge:**

- Los tests unitarios quedaron rotos porque no pasaban las dependencias nuevas a los mocks. `registrar_usuario_test.rb`, `auth_facade_test.rb` — todos fallaban. Hubo que meter `verification_code_service`, `verification_mailer` y `notificador` en cada mock.

---

## Joaquín — Validación de DNI con RENIEC

**Branch:** `feature/Semana1-Joaquin/Validar-DNI`

Joaquín hizo la validación de DNI contra RENIEC al registrar empleados. Su branch venía después de los otros dos, así que heredó todos los conflictos anteriores más los suyos propios.

**Lo que falló:**

- **`auth_facade.rb`** y **`dependency_injection.rb`**: otra vez lo mismo — agregó `reniec_service` como dependencia y había que integrarlo sin romper lo que ya estaba.
- **`registrar_usuario.rb`**: mezcló la validación de DNI para empleados con la validación de RUC para empresas. El código de RENIEC interfería con el flujo de OTP de Angelo.
- **`database.yml`**: él había cambiado la config de PostgreSQL a valores distintos. Al mergear, la base dejó de conectar.
- **`api_service.dart`**: el método `verificarOtp` estaba en dos versiones distintas (una con `ruc` y `codigo`, otra sin).

**Errores post-merge (los peores):**

| Problema | Por qué pasó | Qué se hizo |
|---|---|---|
| `ReniecService` solo generaba datos fake, sin llamar a ninguna API real | Joaquín dejó el servicio con datos hardcodeados, nunca conectó a una API de verdad | Se implementó `Net::HTTP` contra GraphPeru |
| Esos datos fake aparecían para cualquier DNI, incluso los que no existen | La API de GraphPeru no tiene todos los DNIs, entonces cuando fallaba caía a datos generados | Se separó: DNI no encontrado → error, solo fallo de conexión → datos generados |
| Los inputs de nombre y apellido estaban deshabilitados en el formulario | El frontend no dejaba editar los datos que venían de RENIEC | Se habilitaron los campos |
| Si cambiabas el DNI, los nombres no se reseteaban | No había un listener que limpiara los campos al editar el DNI | Se agregó el reset |
| La API de GraphPeru no encuentra muchos DNIs reales | GraphPeru tiene una base limitada, no es RENIEC oficial | Se integró Decolecta API como alternativa principal (requiere API key gratis) |

---

## Lo que se repitió en los 3 branches

1. **`skip_before_action`**: los tres tocaron esa línea y cada uno la pisó. Es un anti-patrón tener que mergear manualmente siempre lo mismo.
2. **Dependencias nuevas sin actualizar tests**: cada branch agregaba un servicio al use case pero los tests unitarios quedaban rotos porque no actualizaban los mocks.
3. **No reiniciar el server después de mergear**: Rails cachea clases; si mergeás y no reiniciás, aparecen errores raros que no son bugs reales.

---

## Estado final

- Backend: 380 tests, 0 failures, 0 errors
- 3 features mergeadas (~3400 líneas nuevas)
- Todos los bugs post-merge corregidos
- Pendiente: conseguir API key de Decolecta (gratis en decolecta.com/profile/) y ponerla en `.env`
