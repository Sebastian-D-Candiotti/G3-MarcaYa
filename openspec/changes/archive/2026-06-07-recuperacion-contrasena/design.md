# Design: Recuperación de Contraseña

## Technical Approach

3 new endpoints under existing `AuthController` (skip auth), each backed by a use case in `Application::UseCases::Auth`. `AuthFacade` gets 3 delegation methods. New driven port `INotificadorEmail` → `ResendMailer` (Action Mailer) + `ResendEmailService` adapter. Frontend: wire 3 screens through `ApiService` + `AuthProvider`, email via GoRouter `extra`. 6-digit numeric code, 15-min expiry, JWT verification token (5-min, `purpose: password_reset`).

## Architecture Decisions

| Decision | Options | Choice | Rationale |
|----------|---------|--------|-----------|
| Email provider integration | Direct API vs Action Mailer | **Action Mailer** | Idiomatic Rails; swapping to SendGrid is config change, not code |
| Facade structure | New facade vs extend existing | **Extend AuthFacade** | Same domain (auth), same repos/services; avoids duplicate DI wiring |
| Code format | 8-char alphanumeric vs 6-digit numeric | **6-digit numeric** | 1M combos, mobile-friendly, standard (Google/GitHub pattern), 15-min window |
| Auth for reset step | Pass code again vs issue JWT | **5-min JWT** | Decouples verify from reset, prevents code replay, clean timeout semantics |
| Anti-enumeration | Different vs identical response | **Identical 200** | Prevents email enumeration; always return same response |

## Data Flow

### SolicitarCodigoRecuperacion
`POST /auth/solicitar-codigo {correo}` → Controller → Facade → UseCase: `usuario_repo.find_by_correo` → if found: `SecureRandom.rand(100_000..999_999)`, update entity with `codigo_recuperacion` + `codigo_expira: 15.min`, `usuario_repo.guardar`, `notificador.enviar_codigo(correo, codigo)` → if not found: no-op → `200 {"mensaje": "Código enviado si el correo existe"}`

### VerificarCodigoRecuperacion
`POST /auth/verificar-codigo {correo, codigo}` → Controller → Facade → UseCase: `usuario_repo.find_by_correo` → raise `CodigoInvalidoError` if mismatch, raise `CodigoExpiradoError` if expired → consume code (nullify `codigo_recuperacion`), `usuario_repo.guardar` → `Jwt.encode({user_id:, purpose: "password_reset"}, 5.min)` → `200 {"verification_token": "<jwt>"}`

### RestablecerContrasena
`PUT /auth/restablecer-contrasena {verification_token, nueva_clave}` → Controller → Facade → UseCase: `Jwt.decode(token)`, raise `TokenRecuperacionInvalidoError` if `purpose != "password_reset"` → `usuario_repo.find_by_id!(user_id)` → validate password ≥ 8 chars → `bcrypt_service.hash(nueva_clave)` → update entity with new `clave_hash`, nullify recovery fields → `usuario_repo.guardar` → `200 {"mensaje": "Contraseña actualizada correctamente"}`

## Request/Response Schemas

| Endpoint | Request | Success (200) | Error |
|----------|---------|---------------|-------|
| `POST auth/solicitar-codigo` | `{"correo": "..."}` | `{"mensaje": "..."}` | Always 200 |
| `POST auth/verificar-codigo` | `{"correo": "...", "codigo": "123456"}` | `{"verification_token": "<jwt>"}` | `401 {"error": "..."}` |
| `PUT auth/restablecer-contrasena` | `{"verification_token": "...", "nueva_clave": "..."}` | `{"mensaje": "..."}` | `401/422 {"error": "..."}` |

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `app/domain/ports/i_notificador_email.rb` | Create | Driven port: `enviar_codigo(destino:, codigo:)` |
| `app/domain/errors.rb` | Modify | +`CodigoInvalidoError`, `CodigoExpiradoError`, `TokenRecuperacionInvalidoError` |
| `app/application/use_cases/auth/solicitar_codigo_recuperacion.rb` | Create | Generate code, save, notify |
| `app/application/use_cases/auth/verificar_codigo_recuperacion.rb` | Create | Validate code + expiry, issue JWT |
| `app/application/use_cases/auth/restablecer_contrasena.rb` | Create | Verify JWT, bcrypt password, update DB |
| `app/application/facades/auth_facade.rb` | Modify | +3 delegation methods, inject `notificador` |
| `app/controllers/api/v1/auth_controller.rb` | Modify | +3 actions (skip auth), rescue new errors |
| `app/infrastructure/services/resend_email_service.rb` | Create | Adapter implementing `INotificadorEmail` |
| `app/mailers/password_recovery_mailer.rb` | Create | Action Mailer with `enviar_codigo` action |
| `app/views/password_recovery_mailer/enviar_codigo.{html,text}.erb` | Create | Email templates (code + instructions) |
| `config/routes.rb` | Modify | +3 routes (no auth required) |
| `config/initializers/dependency_injection.rb` | Modify | Register `ResendEmailService`, inject into `AuthFacade` |
| `Gemfile` | Modify | Add `gem "resend"` |
| `FrontEND/api_service.dart` | Modify | +3 methods: `solicitarCodigo`, `verificarCodigo`, `restablecerContrasena` |
| `FrontEND/auth_provider.dart` | Modify | +3 methods, manage `recoveryEmail` + `verificationToken` state |
| `FrontEND/recuperar_contrasena.dart` | Modify | Call `solicitarCodigo`, navigate with email via GoRouter `extra` |
| `FrontEND/codigo_contrasena.dart` | Modify | 6-field OTP → call `verificarCodigo`, save token |
| `FrontEND/nueva_contrasena.dart` | Modify | Call `restablecerContrasena` with token + new password |

## Error Handling

| Domain Error | HTTP | Frontend Display |
|-------------|------|------------------|
| `CodigoInvalidoError` | 401 | "Código inválido. Intente de nuevo." |
| `CodigoExpiradoError` | 401 | "El código ha expirado. Solicite uno nuevo." |
| `TokenRecuperacionInvalidoError` | 401 | "Sesión de recuperación inválida. Comience de nuevo." |
| `ValidacionError` (password < 8) | 422 | "La contraseña debe tener al menos 8 caracteres." |

Frontend displays errors via `SnackBar` (existing pattern). `AuthProvider` gets error-friendly string from `ApiException.mensaje`.

## Email Template

Subject: "Código de recuperación — MarcaYa". Body (plain text + HTML): code, 15-min expiry notice, ignore-if-not-you message. Minimal MVP — no branding.

## Interfaces

```ruby
module Domain::Ports::INotificadorEmail
  def enviar_codigo(destino:, codigo:)
    raise NotImplementedError
  end
end
```

## Testing Strategy

| Layer | Method |
|-------|--------|
| Use cases | Stub repo + notificador, test all branches |
| ResendEmailService | Stub `Resend::Email.send` |
| Mailer | Rails preview + assert body contains code |
| Frontend pages | Widget tests with mocked `ApiService` |
| E2E | Postman collection + manual happy path |

## Migration / Rollout

No migration — `codigo_recuperacion`/`codigo_expira` exist. Add `Resend.api_key` to Rails credentials. Deploy backend first.

## Open Questions

None.
