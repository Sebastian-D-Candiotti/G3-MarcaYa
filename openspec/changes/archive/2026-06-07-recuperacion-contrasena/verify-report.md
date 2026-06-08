# Verification Report

**Change**: recuperacion-contrasena
**Version**: 1.0 (spec.md initial)
**Mode**: Standard

## Completeness

| Metric | Value |
|--------|-------|
| Tasks total | 18 |
| Tasks complete | 18 |
| Tasks incomplete | 0 |

## Build & Tests Execution

**Build**: ✅ Not executed (no CI pipeline invoked; source inspection only)

**Tests**: ⚠️ No tests found for any recovery-related code

```text
BackEND: No test files found matching recuperacion/solicitar/verificar/restablecer
  - test/application/use_cases/auth/ — contains login, registro, cerrar_sesion only
  - test/controllers/api/v1/auth_controller_test.rb — no recovery tests
  - test/mailers/ — empty (.keep only)

FrontEND: No test files found matching recovery/recuperar/codigo/restablecer
  - test/api_service_test.dart — no recovery method tests
```

**Coverage**: ➖ Not available (no test suite executed)

## Spec Compliance Matrix

| Requirement | Scenario | Test | Result |
|-------------|----------|------|--------|
| REQ-01 | Email exists — code saved, email sent | (none found) | ❌ UNTESTED |
| REQ-01 | Email does NOT exist — same 200, no-op | (none found) | ❌ UNTESTED |
| REQ-02 | Code matches, not expired → JWT | (none found) | ❌ UNTESTED |
| REQ-02 | Code expired → 401 specific error | (none found) | ❌ UNTESTED |
| REQ-02 | Code wrong → 401 specific error | (none found) | ❌ UNTESTED |
| REQ-03 | Valid token + strong password → 200 | (none found) | ❌ UNTESTED |
| REQ-03 | Invalid/expired token → 401 | (none found) | ❌ UNTESTED |
| REQ-03 | Weak password → 422 | (none found) | ❌ UNTESTED |
| REQ-04 | Full happy path — 3 screens → login | (none found) | ❌ UNTESTED |

**Compliance summary**: 0/9 scenarios compliant by runtime evidence

## Correctness (Static Evidence)

All requirements are verified through source code inspection:

| Requirement | Status | Evidence |
|------------|--------|---------|
| REQ-01: Solicitar código | ✅ Implemented | `solicitar_codigo_recuperacion.rb` — SecureRandom 6-digit, 15-min expiry, anti-enumeration same-200 response |
| REQ-02: Verificar código | ✅ Implemented | `verificar_codigo_recuperacion.rb` — validates code+expiry, consumes code, issues 5-min JWT with `purpose: password_reset` |
| REQ-03: Restablecer contraseña | ✅ Implemented | `restablecer_contrasena.rb` — JWT decode + purpose check, password ≥8 validation, bcrypt hash, nullifies recovery fields, no auto-auth |
| REQ-04: Frontend flow | ✅ Implemented | 3 screens wired to real API via `AuthProvider`, no hardcoded "123456", redirect guards, SnackBar errors |
| REQ-04: Routes | ✅ Implemented | 3 routes in `config/routes.rb`: `POST solicitar-codigo`, `POST verificar-codigo`, `PUT restablecer-contrasena` |
| REQ-04: Router | ✅ Implemented | 3 GoRoutes: `/reset-password`, `/reset-password/code`, `/reset-password/new` |

### Requirement-level evidence

#### REQ-01: Solicitar código

| Check | Status | File:Line | Evidence |
|-------|--------|-----------|----------|
| POST /auth/solicitar-codigo accepts {correo} | ✅ | `auth_controller.rb:41-44` | `params[:correo]` |
| Always returns 200 (anti-enumeration) | ✅ | `solicitar_codigo_recuperacion.rb:35` | `{ mensaje: "Código enviado si el correo existe" }` — same regardless |
| Generates 6-digit numeric code | ✅ | `solicitar_codigo_recuperacion.rb:16` | `SecureRandom.rand(100_000..999_999).to_s` |
| Sets 15-min expiry | ✅ | `solicitar_codigo_recuperacion.rb:17` | `15.minutes.from_now` |
| Sends email via INotificadorEmail | ✅ | `solicitar_codigo_recuperacion.rb:32` | `@notificador.enviar_codigo(destino: correo, codigo: codigo)` |
| If email not found: same 200 | ✅ | `solicitar_codigo_recuperacion.rb:13-34` | `if usuario` guard — no-op, same response outside |

#### REQ-02: Verificar código

| Check | Status | File:Line | Evidence |
|-------|--------|-----------|----------|
| POST /auth/verificar-codigo accepts {correo, codigo} | ✅ | `auth_controller.rb:48-51` | `params[:correo]`, `params[:codigo]` |
| Returns verification_token JWT on success | ✅ | `verificar_codigo_recuperacion.rb:33-36` | `Jwt.encode({..., "purpose" => "password_reset"}, 5.minutes.from_now)` |
| JWT has 5-min expiry | ✅ | `verificar_codigo_recuperacion.rb:35` | `5.minutes.from_now` |
| JWT has purpose: password_reset | ✅ | `verificar_codigo_recuperacion.rb:34` | `"purpose" => "password_reset"` |
| Wrong code → 401 | ✅ | `auth_controller.rb:53-54` | `rescue CodigoInvalidoError → render json: {error: "Código inválido..."}, status: :unauthorized` |
| Expired code → 401 | ✅ | `auth_controller.rb:55-56` | `rescue CodigoExpiradoError → render json: {error: "El código ha expirado..."}, status: :unauthorized` |
| Code consumed after verification | ✅ | `verificar_codigo_recuperacion.rb:19-31` | `codigo_recuperacion: nil, codigo_expira: nil` |

#### REQ-03: Restablecer contraseña

| Check | Status | File:Line | Evidence |
|-------|--------|-----------|----------|
| PUT /auth/restablecer-contrasena accepts {verification_token, nueva_clave} | ✅ | `auth_controller.rb:60-63` | `params[:verification_token]`, `params[:nueva_clave]` |
| Validates JWT purpose == "password_reset" | ✅ | `restablecer_contrasena.rb:15` | `payload["purpose"] == "password_reset"` |
| Validates password >= 8 chars | ✅ | `restablecer_contrasena.rb:19` | `nueva_clave.length < 8 → raise ValidacionError` |
| Invalid/expired token → 401 | ✅ | `restablecer_contrasena.rb:43-45`, `auth_controller.rb:65-66` | `JWT::DecodeError → TokenRecuperacionInvalidoError → 401` |
| Hashes password with bcrypt | ✅ | `restablecer_contrasena.rb:21` | `@bcrypt_service.hash(nueva_clave)` |
| Updates clave_hash, nullifies recovery fields | ✅ | `restablecer_contrasena.rb:23-33` | `clave_hash: nueva_hash, codigo_recuperacion: nil, codigo_expira: nil` |
| Does NOT auto-authenticate | ✅ | `restablecer_contrasena.rb:37` | Returns `{ mensaje: "Contraseña actualizada correctamente" }` — no token |

#### REQ-04: Frontend flow

| Check | Status | File:Line | Evidence |
|-------|--------|-----------|----------|
| RecuperarContrasenaPage calls solicitarCodigo API | ✅ | `recuperar_contrasena.dart:158` | `AuthProvider.solicitarCodigo(email)` → `ApiService.solicitarCodigo(correo)` |
| CodigoContrasenaPage calls verificarCodigo API | ✅ | `codigo_contrasena.dart:168` | `AuthProvider.verificarCodigo(codigo)` → `ApiService.verificarCodigo(correo, codigo)` |
| No hardcoded "123456" | ✅ | `codigo_contrasena.dart:153-155` | Code read from 6 OTP fields: `controllers.map((c) => c.text).join()` |
| NuevaContrasenaPage calls restablecerContrasena API | ✅ | `nueva_contrasena.dart:155` | `AuthProvider.restablecerContrasena(password)` → `ApiService.restablecerContrasena(token, clave)` |
| Error messages via SnackBar | ✅ | Multiple | `SnackBar(content: Text(...), backgroundColor: Colors.red)` |
| Redirect guard: code page without email | ✅ | `codigo_contrasena.dart:30-33` | `if (auth.recoveryEmail == null) → context.go('/reset-password')` |
| Redirect guard: new password page without token | ✅ | `nueva_contrasena.dart:32-35` | `if (auth.verificationToken == null) → context.go('/reset-password')` |
| Success → navigate to login | ✅ | `nueva_contrasena.dart:163-164` | `Future.delayed(...) → context.go('/')` |

#### Hexagonal Architecture

| Check | Status | File:Line | Evidence |
|-------|--------|-----------|----------|
| Driven port INotificadorEmail exists | ✅ | `inotificador_email.rb:5-8` | `module Domain::Ports::INotificadorEmail` with `enviar_codigo(destino:, codigo:)` |
| Domain error: CodigoInvalidoError | ✅ | `errors.rb:23` | `class CodigoInvalidoError < StandardError; end` |
| Domain error: CodigoExpiradoError | ✅ | `errors.rb:24` | `class CodigoExpiradoError < StandardError; end` |
| Domain error: TokenRecuperacionInvalidoError | ✅ | `errors.rb:25` | `class TokenRecuperacionInvalidoError < StandardError; end` |
| Use cases in Application::UseCases::Auth | ✅ | 3 files | `Application::UseCases::Auth::SolicitarCodigoRecuperacion`, `VerificarCodigoRecuperacion`, `RestablecerContrasena` |
| Adapter: ResendEmailService implements INotificadorEmail | ✅ | `resend_email_service.rb:6-9` | `include Domain::Ports::INotificadorEmail` + `enviar_codigo` |
| DI wires everything | ✅ | `dependency_injection.rb:16` | `notificador: Infrastructure::Services::ResendEmailService.new` |
| AuthFacade +3 methods | ✅ | `auth_facade.rb:40-65` | `solicitar_codigo`, `verificar_codigo`, `restablecer_contrasena` |
| Mailer exists | ✅ | `password_recovery_mailer.rb` | `codigo_recuperacion` action, from: noreply@marcaya.com |
| Email templates (HTML + text) | ✅ | 2 files | `codigo_recuperacion.html.erb`, `codigo_recuperacion.text.erb` |
| Gemfile: resend gem | ✅ | `Gemfile:15` | `gem "resend", "~> 2.0"` |

## Coherence (Design)

| Decision | Followed? | Notes |
|----------|-----------|-------|
| Action Mailer for email | ✅ Yes | `PasswordRecoveryMailer` → `ResendEmailService` adapter |
| Extend AuthFacade | ✅ Yes | +3 methods: `solicitar_codigo`, `verificar_codigo`, `restablecer_contrasena` |
| 6-digit numeric code | ✅ Yes | `SecureRandom.rand(100_000..999_999)` |
| 5-min JWT verification token | ✅ Yes | `Jwt.encode(..., 5.minutes.from_now)` with `purpose: "password_reset"` |
| Identical 200 for anti-enumeration | ✅ Yes | Same `{mensaje: "..."}` regardless of email existence |
| Rescue errors in controller | ✅ Yes | `CodigoInvalidoError`, `CodigoExpiradoError`, `TokenRecuperacionInvalidoError`, `ValidacionError` |
| Use injected service (jwt) | ⚠️ Partial | `VerificarCodigoRecuperacion` stores `@jwt_service` but calls `Jwt.encode()` directly. `RestablecerContrasena` has no `jwt_service` at all — calls `Jwt.decode()` directly. |
| Email passed via GoRouter `extra` | ⚠️ Partial | Email is passed via `AuthProvider._recoveryEmail` state instead of GoRouter `extra`. Better approach, but diverges from design doc. |

## Issues Found

**CRITICAL**:
1. **No tests exist for any recovery functionality** — 0 of 9 spec scenarios have covering tests. No use case unit tests (`test/application/use_cases/auth/`), no controller integration tests, no mailer tests, no frontend widget tests. This is a gap that undermines regression safety.

**WARNING**:
1. **Jwt service injection bypassed** — `VerificarCodigoRecuperacion` stores `@jwt_service` (line 9) but calls `Jwt.encode()` directly (line 33) instead of `@jwt_service.encode()`. `RestablecerContrasena` has no `jwt_service` injected at all and calls `Jwt.decode()` directly (line 43). This breaks the hexagonal DI pattern used by all other auth use cases (`LoginUsuario`, `RegistrarUsuario` use `@jwt_service.encode()`). Note: the direct call was likely chosen because `JwtTokenService.encode` does not support custom expiry, but the convention should be to extend the service, not bypass it.

**SUGGESTION**:
1. **Email state via Provider vs GoRouter `extra`** — The design specified passing email via GoRouter `extra`, but the implementation uses `AuthProvider._recoveryEmail`. The Provider approach is more robust (survives refreshes within the SPA), but the design doc should be updated to reflect this.
2. **VerificarCodigoRecuperacion dead parameter** — `jwt_service` is accepted in the constructor but never used by the `ejecutar` method (which calls `Jwt.encode` directly). Either remove the parameter or refactor to use `@jwt_service`.
3. **RestablecerContrasena missing jwt_service injection** — Consider adding `jwt_service` to the constructor and using it for `Jwt.decode()` to maintain consistent DI patterns.

## Verdict

**PASS WITH WARNINGS**

All 4 requirements are functionally implemented and match the spec exactly through source inspection. The 3 use cases, 3 controller actions, 3 frontend screens, hexagonal ports, adapter, DI wiring, mailer, and email templates are all present and correctly wired. However, **zero tests exist** (0/9 spec scenarios have covering tests), and there are minor DI deviations where `Jwt` module is called directly instead of the injected `jwt_service`. The implementation is correct for production behavior, but lacks the test safety net expected by the SDD process.
