# Proposal: Recuperación de Contraseña

## Intent

Password recovery is entirely fake. The DB has `codigo_recuperacion` and `codigo_expira` columns — never used. Frontend hardcodes "123456" and the "success" snackbar sends nothing. Users cannot recover their password if forgotten, making the system unusable for real deployments.

## Scope

### In Scope
- Backend: 3 new endpoints (solicitar código, verificar código, restablecer contraseña)
- Full hexagonal stack: driven port (email), driving port, use cases, facade, controller
- Email delivery via Resend (Action Mailer adapter)
- Frontend: wire 3 screens to real API, remove hardcoded "123456"
- 6-digit code, 15-min expiry, single-use, bcrypt-hashed new password

### Out of Scope
- Email template design (plain text for MVP)
- Rate limiting (delegate to Resend)
- Password strength indicator
- SMS recovery
- Post-reset login notification

## Capabilities

### New Capabilities
- `password-recovery`: Email-based recovery flow — request 6-digit code, verify expiry, reset password via bcrypt

### Modified Capabilities
None — no existing specs in openspec/specs/.

## Approach

**Backend — 3 use cases under `Application::UseCases::Auth`:**
1. `SolicitarCodigoRecuperacion`: find user by email → SecureRandom 6-digit code + 15-min expiry → `usuario_repo.guardar` → send via `INotificadorEmail` port
2. `VerificarCodigoRecuperacion`: find user → validate code match + not expired
3. `RestablecerContrasena`: verify code → `BcryptPasswordService.hash` new password → update `usuario.clave_hash` → clear recovery fields

New driven port `INotificadorEmail` → implemented as `ResendEmailService` using Resend HTTP API via Rails Action Mailer. New driving port `IRecuperarContrasena` → `AuthFacade` gets 3 new methods → `AuthController` gets 3 new actions.

Routes: `POST auth/solicitar-codigo`, `POST auth/verificar-codigo`, `PUT auth/restablecer-contrasena` (no auth required).

**Frontend:**
- Add 3 methods to `ApiService`
- Pass email via GoRouter extra from step 1 → step 2 → step 3
- Replace hardcoded "123456" with real API verification
- On success: call reset API, navigate to login

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `app/ports/driven/i_notificador_email.rb` | New | Email driven port |
| `app/ports/driving/i_recuperar_contrasena.rb` | New | Recovery driving port |
| `app/application/use_cases/auth/` | New | 3 use case files |
| `app/application/facades/auth_facade.rb` | Modified | +3 recovery methods |
| `app/controllers/api/v1/auth_controller.rb` | Modified | +3 recovery actions |
| `app/infrastructure/services/resend_email_service.rb` | New | Resend integration |
| `app/mailers/` | Modified | Resend mailer config |
| `config/routes.rb` | Modified | +3 recovery routes |
| `config/initializers/dependency_injection.rb` | Modified | Register email service |
| `app/domain/errors.rb` | Modified | Add `CodigoInvalidoError`, `CodigoExpiradoError` |
| `FrontEND/api_service.dart` | Modified | +3 recovery methods |
| `FrontEND/` 3 pages | Modified | Wire to API calls |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Resend email lands in spam | Low | Log code server-side for debugging |
| 100 email/day Resend limit | Low | Unlikely in dev; document for production |

## Rollback Plan

1. Remove 3 routes, 3 controller actions, 3 use cases, email service
2. Revert DI container and facade
3. Revert 3 frontend pages to UI-only
4. No data loss — recovery columns untouched

## Dependencies

- Resend API key (already available)
- `ArUsuarioRepository.guardar` (already handles `codigo_recuperacion`/`codigo_expira`)
- `BcryptPasswordService` + `JwtTokenService` (existing)

## Success Criteria

- [ ] User with valid email receives a 6-digit code
- [ ] Correct code + expiry = password resets successfully
- [ ] Wrong code or expired code = rejected with clear error
- [ ] Reused consumed code = rejected
- [ ] New password works with login
- [ ] All 3 frontend screens call real endpoints (no hardcoded values)
