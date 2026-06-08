# Password Recovery — Specification

Email-based recovery flow: 6-digit code, 15-min expiry, bcrypt-hashed new password.
No auth required. Frontend wires 3 existing screens to real API.

## Requirements

### REQ-01: Solicitar código

`POST /auth/solicitar-codigo`. System MUST:
- Accept `correo`, respond identically whether email exists or not (anti-enumeration)
- Generate **6-digit numeric** code via `SecureRandom`, set 15-min `codigo_expira`
- Send via `INotificadorEmail` (Resend), log server-side for debugging

#### Scenario: Email exists

- GIVEN registered user `correo = user@example.com`
- WHEN `POST /auth/solicitar-codigo` with that email
- THEN `{"mensaje": "Código enviado si el correo existe"}` — code saved, email sent

#### Scenario: Email does NOT exist

- GIVEN no user with that email
- WHEN same request
- THEN identical 200 response — no code saved, no email sent

### REQ-02: Verificar código

`POST /auth/verificar-codigo`. System MUST:
- Accept `correo` + `codigo`, reject with specific errors for mismatch vs expiry
- On success: return JWT verification token (5-min, `purpose: "password_reset"`)

| Condition | Response |
|-----------|----------|
| Code matches, not expired | `{"verification_token": "<jwt>"}` (200) |
| Code expired | `{"error": "El código ha expirado. Solicite uno nuevo."}` (401) |
| Code wrong | `{"error": "Código inválido. Intente de nuevo."}` (401) |

### REQ-03: Restablecer contraseña

`PUT /auth/restablecer-contrasena`. System MUST:
- Accept `verification_token` + `nueva_clave`
- Validate JWT (purpose, expiry), password ≥ 8 chars
- Hash via `BcryptPasswordService`, update `clave_hash`, nullify recovery fields
- NOT auto-authenticate (user must log in with new password)

| Scenario | Input | Outcome |
|----------|-------|---------|
| Valid token + strong password | `nueva_clave = "NewPass123"` | 200 — password changed, recovery fields cleared |
| Invalid/expired token | Bad JWT | 401 — `"Sesión de recuperación inválida. Comience de nuevo."` |
| Weak password | `nueva_clave = "abc"` | 422 — `"La contraseña debe tener al menos 8 caracteres."` |

### REQ-04: Frontend flow

Wire 3 screens via `ApiService` + `AuthProvider`, replace hardcoded "123456":

| Screen | Route | API call | On success |
|--------|-------|----------|------------|
| RecuperarContrasenaPage | `/reset-password` | `POST solicitar-codigo` | Navigate to `/reset-password/code` with email |
| CodigoContrasenaPage | `/reset-password/code` | `POST verificar-codigo` | Save token, navigate to `/reset-password/new` |
| NuevaContrasenaPage | `/reset-password/new` | `PUT restablecer-contrasena` | Success snackbar → navigate to `/` (login) |

#### Scenario: Full happy path

- GIVEN a registered user
- WHEN email → correct 6-digit code → valid new password
- THEN all 3 calls succeed, password resets, user lands on login

## Security

| Rule | Detail |
|------|--------|
| Anti-enumeration | `POST solicitar-codigo` returns same response for found/not-found |
| Code format | 6 numeric digits only (mobile-friendly) |
| Code expiry | 15 min, server-side check before reset |
| Verification token | JWT, 5 min, `purpose: "password_reset"`, separate key from auth |
| Cleanup | Reset nullifies `codigo_recuperacion` + `codigo_expira` |
| Logging | Log failed attempts server-side |

## Architecture

| Layer | Change |
|-------|--------|
| Driven port (new) | `INotificadorEmail#enviar_codigo(destino, codigo)` |
| Driving port (new) | `IRecuperarContrasena` — 3 methods |
| Use cases (new) | `SolicitarCodigoRecuperacion` / `VerificarCodigoRecuperacion` / `RestablecerContrasena` |
| Facade | `AuthFacade` +3 methods delegating to use cases |
| Controller | `AuthController` +3 actions (skip auth) |
| Mailer | `ResendMailer` via Action Mailer |
| Errors | Add `CodigoInvalidoError`, `CodigoExpiradoError`, `TokenRecuperacionInvalidoError` |
| Routes | 3 new under `/api/v1/auth/` |
