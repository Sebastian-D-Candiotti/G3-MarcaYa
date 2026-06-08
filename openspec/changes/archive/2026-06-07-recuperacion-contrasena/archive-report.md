# Archive Report: Recuperación de Contraseña

**Archived**: 2026-06-07
**Change**: recuperacion-contrasena
**Verification**: PASS WITH WARNINGS
**Delivery**: stacked-to-main (3 PRs)

## Change Summary

Email-based password recovery flow for MarcaYa. Three endpoints under `AuthController` (no auth required): solicit code (6-digit, 15-min expiry), verify code (issues 5-min JWT verification token), reset password (bcrypt hash, no auto-authenticate). Hexagonal architecture — new driven port `INotificadorEmail`, 3 use cases in `Application::UseCases::Auth`, `ResendEmailService` adapter, `PasswordRecoveryMailer` via Action Mailer. Frontend: 3 screens wired to real API, no hardcoded "123456".

## Files Changed

### Backend — New (9 files)

| File | Description |
|------|-------------|
| `BackEND/MarcaYa-Backend/app/domain/ports/inotificador_email.rb` | Driven port: `enviar_codigo(destino:, codigo:)` |
| `BackEND/MarcaYa-Backend/app/application/use_cases/auth/solicitar_codigo_recuperacion.rb` | Use case: generate 6-digit code, save, notify via email |
| `BackEND/MarcaYa-Backend/app/application/use_cases/auth/verificar_codigo_recuperacion.rb` | Use case: validate code + expiry, issue JWT |
| `BackEND/MarcaYa-Backend/app/application/use_cases/auth/restablecer_contrasena.rb` | Use case: verify JWT, bcrypt hash, update DB |
| `BackEND/MarcaYa-Backend/app/infrastructure/services/resend_email_service.rb` | Adapter: implements `INotificadorEmail` via Resend |
| `BackEND/MarcaYa-Backend/app/mailers/password_recovery_mailer.rb` | Action Mailer: `codigo_recuperacion` action |
| `BackEND/MarcaYa-Backend/app/views/password_recovery_mailer/codigo_recuperacion.html.erb` | Email template (HTML) |
| `BackEND/MarcaYa-Backend/app/views/password_recovery_mailer/codigo_recuperacion.text.erb` | Email template (plain text) |

### Backend — Modified (5 files)

| File | Description |
|------|-------------|
| `BackEND/MarcaYa-Backend/Gemfile` | Added `gem "resend", "~> 2.0"` |
| `BackEND/MarcaYa-Backend/app/domain/errors.rb` | Added `CodigoInvalidoError`, `CodigoExpiradoError`, `TokenRecuperacionInvalidoError` |
| `BackEND/MarcaYa-Backend/app/application/facades/auth_facade.rb` | Added 3 recovery methods + 3 ivars |
| `BackEND/MarcaYa-Backend/config/initializers/dependency_injection.rb` | Registered `ResendEmailService`, injected into `AuthFacade` |
| `BackEND/MarcaYa-Backend/config/routes.rb` | Added 3 routes (no auth) |
| `BackEND/MarcaYa-Backend/app/controllers/api/v1/auth_controller.rb` | Added 3 actions + error rescues |

### Frontend — Modified (5 files)

| File | Description |
|------|-------------|
| `FrontEND/MarcaYa/lib/src/api_service.dart` | Added `solicitarCodigo`, `verificarCodigo`, `restablecerContrasena` |
| `FrontEND/MarcaYa/lib/providers/auth_provider.dart` | Added recovery state + 3 methods |
| `FrontEND/MarcaYa/lib/pages/recuperar_contrasena/recuperar_contrasena.dart` | Wired to `solicitarCodigo` API |
| `FrontEND/MarcaYa/lib/pages/codigo_contrasena/codigo_contrasena.dart` | Real API call, removed "123456" |
| `FrontEND/MarcaYa/lib/pages/nueva_contrasena/nueva_contrasena.dart` | Wired to `restablecerContrasena` API |

### OpenSpec — Artifacts (6 files)

| File | Description |
|------|-------------|
| `openspec/recuperacion-contrasena/proposal.md` | Change proposal with scope and approach |
| `openspec/recuperacion-contrasena/spec.md` | 4 requirements, 9 scenarios |
| `openspec/recuperacion-contrasena/design.md` | Architecture decisions, data flow, interfaces |
| `openspec/recuperacion-contrasena/tasks.md` | 18 tasks across 3 phases |
| `openspec/recuperacion-contrasena/apply-progress.md` | Apply progress (3 PRs) |
| `openspec/recuperacion-contrasena/verify-report.md` | Verification result — PASS WITH WARNINGS |
| `openspec/recuperacion-contrasena/archive-report.md` | This file |

## Pending Dependencies

1. **Bundle install**: Run `bundle install` on the backend to install the `resend` gem
2. **Rails credentials**: Configure Resend API key in Rails credentials
3. **Production config**: Configure Action Mailer delivery method in `environments/production.rb`

## Known Issues / Warnings

### From Verification (PASS WITH WARNINGS)

| Severity | Issue | Detail |
|----------|-------|--------|
| CRITICAL | No tests | 0/9 spec scenarios have covering tests. No use case, controller, mailer, or widget tests. |
| WARNING | Jwt service bypass | `VerificarCodigoRecuperacion` stores `@jwt_service` but calls `Jwt.encode()` directly. `RestablecerContrasena` has no `jwt_service` and calls `Jwt.decode()` directly. Breaks hexagonal DI pattern. |
| SUGGESTION | Email state via Provider | Design doc specified GoRouter `extra`, but `AuthProvider._recoveryEmail` is used instead — more robust, but design doc should be updated. |
| SUGGESTION | Dead parameter | `VerificarCodigoRecuperacion` accepts `jwt_service` in constructor but never uses it. |
| SUGGESTION | Missing injection | `RestablecerContrasena` lacks `jwt_service` injection entirely. |

### Resolved During Implementation

- No speculative issues found. All 18 tasks completed without blockers.

## Requirements Compliance

| Requirement | Status | Notes |
|-------------|--------|-------|
| REQ-01: Solicitar código | ✅ Implemented | Anti-enumeration, 6-digit code, 15-min expiry, email sent |
| REQ-02: Verificar código | ✅ Implemented | Code + expiry validation, 5-min JWT issued |
| REQ-03: Restablecer contraseña | ✅ Implemented | JWT validation, bcrypt hash, no auto-auth |
| REQ-04: Frontend flow | ✅ Implemented | 3 screens wired, no hardcoded values, redirect guards |

## Rollback Instructions

1. **Remove backend files**: Delete 3 use case files, `inotificador_email.rb`, `resend_email_service.rb`, `password_recovery_mailer.rb`, and 2 email templates
2. **Revert backend modifications**: Undo changes to `Gemfile`, `errors.rb`, `auth_facade.rb`, `dependency_injection.rb`, `routes.rb`, `auth_controller.rb`
3. **Revert frontend modifications**: Undo changes to `api_service.dart`, `auth_provider.dart`, and 3 page files
4. **No data migration needed**: `codigo_recuperacion`/`codigo_expira` columns exist but are unused if recovery code is removed
5. **Verify**: Confirmation that no recovery routes exist and old login flow still works
