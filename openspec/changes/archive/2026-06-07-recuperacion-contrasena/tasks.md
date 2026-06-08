# Tasks: Recuperación de Contraseña

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~540 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 (Foundation) → PR 2 (Use Cases + Endpoints) → PR 3 (Frontend) |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: pending
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Backend Foundation | PR 1 | Gem, port, errors, mailer, views, adapter, DI — ~200 lines |
| 2 | Backend Use Cases + Endpoints | PR 2 | 3 use cases, routes, facade, controller — ~250 lines |
| 3 | Frontend Wiring | PR 3 | ApiService, AuthProvider, 3 screens, router — ~150 lines |

## Phase 1: Backend Foundation

- [x] 1.1 Add `gem "resend"` to `Gemfile` + configure Resend API key in Rails credentials
- [x] 1.2 Create `app/domain/ports/inotificador_email.rb` — driven port: `enviar_codigo(destino:, codigo:)`
- [x] 1.3 Create 3 domain errors: `CodigoInvalidoError`, `CodigoExpiradoError`, `TokenRecuperacionInvalidoError`
- [x] 1.4 Create `PasswordRecoveryMailer` + `codigo_recuperacion.html.erb` and `.text.erb` views
- [x] 1.5 Create `app/infrastructure/services/resend_email_service.rb` — adapter implementing `INotificadorEmail`
- [x] 1.6 Register `ResendEmailService` + inject `notificador` into `AuthFacade` in DI container

## Phase 2: Backend Use Cases + Endpoints

- [x] 2.1 Create `SolicitarCodigoRecuperacion`: find user → `SecureRandom` 6-digit code + 15-min expiry → save → notify
- [x] 2.2 Create `VerificarCodigoRecuperacion`: validate code + expiry → consume code → issue JWT (5-min, `purpose: password_reset`)
- [x] 2.3 Create `RestablecerContrasena`: verify JWT → bcrypt hash → update `clave_hash` → nullify recovery fields
- [x] 2.4 Add 3 routes to `config/routes.rb`: `POST solicitar-codigo`, `POST verificar-codigo`, `PUT restablecer-contrasena` (no auth)
- [x] 2.5 Add 3 delegation methods to `AuthFacade`: `solicitar_codigo`, `verificar_codigo`, `restablecer_contrasena`
- [x] 2.6 Add 3 actions + error rescues (`CodigoInvalidoError`, `CodigoExpiradoError`, `TokenRecuperacionInvalidoError`) to `AuthController`

## Phase 3: Frontend Wiring

- [x] 3.1 Add `solicitarCodigo`, `verificarCodigo`, `restablecerContrasena` methods to `ApiService`
- [x] 3.2 Add `recoveryEmail` + `verificationToken` state and 3 methods to `AuthProvider`
- [x] 3.3 Wire `RecuperarContrasenaPage` → call API on submit → navigate with email as GoRouter `extra`
- [x] 3.4 Wire `CodigoContrasenaPage` → replace hardcoded "123456" with real API call → save token
- [x] 3.5 Wire `NuevaContrasenaPage` → call reset API → success snackbar → `context.go('/')`
- [x] 3.6 Update `AppRouter` to pass `verificationToken` between `/reset-password/code` and `/reset-password/new`
