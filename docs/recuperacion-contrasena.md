# Recuperación de Contraseña

**Autor:** Mario (mario7w78)  
**Commits:** `4fb65f0` (backend + frontend), `e05d57a` (email + UI)  
**Fecha:** 7-11 Junio 2026

---

## Resumen

Implementación del flujo completo de recuperación de contraseña: el usuario solicita un código por correo, lo verifica, y establece una nueva contraseña. Sin autenticación requerida.

---

## Backend

### Rutas

| Método | Endpoint | Controlador | Descripción |
|---|---|---|---|
| `POST` | `/api/v1/auth/solicitar-codigo` | `auth#solicitar_codigo` | Envía código de 6 dígitos al correo |
| `POST` | `/api/v1/auth/verificar-codigo` | `auth#verificar_codigo` | Valida el código y devuelve un JWT |
| `PUT` | `/api/v1/auth/restablecer-contrasena` | `auth#restablecer_contrasena` | Cambia la contraseña con el JWT de verificación |

Los 3 endpoints son públicos (no requieren token JWT).

### Arquitectura (Hexagonal)

#### Puerto Driven

- **`INotificadorEmail`** (`app/domain/ports/inotificador_email.rb`): interfaz para el envío de emails de recuperación.
- Implementado con Action Mailer vía Gmail SMTP (configurado con variables de entorno).

#### Use Cases

1. **`SolicitarCodigoRecuperacion`** (`app/application/use_cases/auth/solicitar_codigo_recuperacion.rb`)
   - Busca el usuario por correo
   - Si existe: genera código de 6 dígitos con `SecureRandom`, establece expiry de 15 minutos en `codigo_expira`
   - Si no existe: igual devuelve 200 (protección anti-enumeration)
   - Envía el código por mail

2. **`VerificarCodigoRecuperacion`** (`app/application/use_cases/auth/verificar_codigo_recuperacion.rb`)
   - Busca el usuario por correo
   - Valida que el código coincida (sino → `CodigoInvalidoError`)
   - Valida que no haya expirado (sino → `CodigoExpiradoError`)
   - Devuelve un JWT con `purpose: "password_reset"` y 5 minutos de validez

3. **`RestablecerContrasena`** (`app/application/use_cases/auth/restablecer_contrasena.rb`)
   - Valida el JWT de verificación (sino → `TokenRecuperacionInvalidoError`)
   - Valida que la nueva contraseña tenga al menos 8 caracteres
   - Hashea la contraseña con bcrypt
   - Actualiza `clave_hash` y limpia `codigo_recuperacion` / `codigo_expira`
   - No auto-autentica (el usuario debe loguearse con su nueva contraseña)

#### Errores de Dominio

| Error | Condición |
|---|---|
| `CodigoInvalidoError` | El código ingresado no coincide |
| `CodigoExpiradoError` | El código ya expiró (15 min) |
| `TokenRecuperacionInvalidoError` | El JWT de verificación es inválido o expiró |

#### Facade

`AuthFacade` expone 3 nuevos métodos que delegan a los use cases correspondientes:
- `solicitar_codigo(correo:)`
- `verificar_codigo(correo:, codigo:)`
- `restablecer_contrasena(verification_token:, nueva_clave:)`

#### Mailer

- **`PasswordRecoveryMailer`** (`app/mailers/password_recovery_mailer.rb`)
- Templates: `codigo_recuperacion.html.erb` y `codigo_recuperacion.text.erb`
- Envío configurado con variables de entorno (ver `SMTP_*` en `.env`)

### Seguridad

| Regla | Detalle |
|---|---|
| Anti-enumeration | `solicitar-codigo` responde igual exista o no el correo |
| Código | 6 dígitos numéricos, generado con `SecureRandom` |
| Expiry | 15 minutos, verificado server-side |
| Token de verificación | JWT con `purpose: "password_reset"`, 5 min de validez |
| Contraseña | Mínimo 8 caracteres, hasheada con bcrypt |
| Limpieza | Al cambiar la contraseña se eliminan `codigo_recuperacion` y `codigo_expira` |

---

## Frontend

### Pantallas

1. **RecuperarContrasenaPage** (`/reset-password`)
   - Input de correo electrónico
   - Botón "Enviar código"
   - Valida formato de email antes de enviar
   - Muestra loading y maneja errores de red

2. **CodigoContrasenaPage** (`/reset-password/code`)
   - 6 inputs individuales para cada dígito
   - Auto-avance al siguiente campo al escribir
   - Auto-retroceso al borrar
   - Botón "Verificar código"
   - Protegido: redirige a `/reset-password` si no hay `recoveryEmail`

3. **NuevaContrasenaPage** (`/reset-password/new`)
   - Input de nueva contraseña (con toggle visibilidad)
   - Input de confirmación (con toggle visibilidad)
   - Validación: ambas deben coincidir y tener ≥ 8 caracteres
   - Botón "Restablecer contraseña"
   - Protegido: redirige a `/reset-password` si no hay `verificationToken`

### Provider

- **`AuthProvider`** (`lib/providers/auth_provider.dart`)
  - `recoveryEmail`: se setea al enviar el código, se pasa a la pantalla de código
  - `verificationToken`: se setea al verificar el código, se pasa a la pantalla de nueva contraseña
  - Ambos se limpian al completar o salir del flujo

### ApiService

| Método | HTTP | Endpoint |
|---|---|---|
| `solicitarCodigo(correo)` | POST | `/auth/solicitar-codigo` |
| `verificarCodigo(correo, codigo)` | POST | `/auth/verificar-codigo` |
| `restablecerContrasena(token, clave)` | PUT | `/auth/restablecer-contrasena` |

### Rutas (GoRouter)

| Ruta | Pantalla |
|---|---|
| `/reset-password` | RecuperarContrasenaPage |
| `/reset-password/code` | CodigoContrasenaPage |
| `/reset-password/new` | NuevaContrasenaPage |

### Flujo Completo

```
Login → "/reset-password" → email → "/reset-password/code"
  → código 6 dígitos → "/reset-password/new" → nueva contraseña → Login
```

---

## Configuración de Email

Las variables de entorno necesarias en `.env`:

```env
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=gmail.com
SMTP_USERNAME=tu_correo@gmail.com
SMTP_PASSWORD=tu_password_de_aplicacion
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

Inicialmente se usó Resend como proveedor de email, luego se migró a Gmail SMTP directo.

---

## Archivos Creados

### Backend
- `app/domain/ports/inotificador_email.rb`
- `app/application/use_cases/auth/solicitar_codigo_recuperacion.rb`
- `app/application/use_cases/auth/verificar_codigo_recuperacion.rb`
- `app/application/use_cases/auth/restablecer_contrasena.rb`
- `app/infrastructure/services/resend_email_service.rb`
- `app/mailers/password_recovery_mailer.rb`
- `app/views/password_recovery_mailer/codigo_recuperacion.html.erb`
- `app/views/password_recovery_mailer/codigo_recuperacion.text.erb`

### Frontend
- `lib/pages/recuperar_contrasena/recuperar_contrasena.dart`
- `lib/pages/codigo_contrasena/codigo_contrasena.dart`
- `lib/pages/nueva_contrasena/nueva_contrasena.dart`
- `lib/providers/auth_provider.dart`

### Archivos Modificados
- `app/application/facades/auth_facade.rb` (+3 métodos)
- `app/controllers/api/v1/auth_controller.rb` (+3 acciones)
- `app/domain/errors.rb` (+3 errores de dominio)
- `app/mailers/application_mailer.rb` (config default from)
- `config/routes.rb` (+3 rutas)
- `config/initializers/dependency_injection.rb` (registro de notificador)
- `config/environments/development.rb` (config SMTP)
- `lib/src/api_service.dart` (+3 métodos HTTP)
- `lib/router/app_router.dart` (+3 rutas)
