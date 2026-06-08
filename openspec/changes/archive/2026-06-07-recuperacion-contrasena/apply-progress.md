# Apply Progress: Recuperación de Contraseña — PR 3 (Frontend Wiring)

## Summary

Frontend wiring complete. Added 3 recovery methods to `ApiService`, added recovery state + 3 methods to `AuthProvider`, wired all 3 recovery screens (`RecuperarContrasenaPage`, `CodigoContrasenaPage`, `NuevaContrasenaPage`) with real API calls via Provider. Router remains unchanged (AuthProvider manages state). Redirect guards added for direct navigation to code/token screens.

## Artifact Store Mode

`hybrid` — updated `tasks.md` on filesystem AND persisted to Engram.

## Completed Tasks

| # | Task | Status |
|---|------|--------|
| 1.1 | Add `gem "resend"` to Gemfile | ✅ Done (PR 1) |
| 1.2 | Create `Domain::Ports::INotificadorEmail` driven port | ✅ Done (PR 1) |
| 1.3 | Create 3 domain errors | ✅ Done (PR 1) |
| 1.4 | Create `PasswordRecoveryMailer` + HTML/text email views | ✅ Done (PR 1) |
| 1.5 | Create `Infrastructure::Services::ResendEmailService` adapter | ✅ Done (PR 1) |
| 1.6 | Register `ResendEmailService` in DI + inject `notificador` into `AuthFacade` | ✅ Done (PR 1) |
| 2.1 | Create `SolicitarCodigoRecuperacion` use case | ✅ Done |
| 2.2 | Create `VerificarCodigoRecuperacion` use case | ✅ Done |
| 2.3 | Create `RestablecerContrasena` use case | ✅ Done |
| 2.4 | Add 3 recovery routes to `config/routes.rb` | ✅ Done |
| 2.5 | Add 3 delegation methods to `AuthFacade` + store `@usuario_repo`, `@bcrypt_service`, `@jwt_service` | ✅ Done |
| 2.6 | Add 3 actions + error rescues to `AuthController` | ✅ Done |
| 3.1 | Add `solicitarCodigo`, `verificarCodigo`, `restablecerContrasena` methods to `ApiService` | ✅ Done |
| 3.2 | Add `recoveryEmail` + `verificationToken` state and 3 methods to `AuthProvider` | ✅ Done |
| 3.3 | Wire `RecuperarContrasenaPage` → call API on submit → navigate to `/reset-password/code` | ✅ Done |
| 3.4 | Wire `CodigoContrasenaPage` → replace hardcoded "123456" with real API call | ✅ Done |
| 3.5 | Wire `NuevaContrasenaPage` → call reset API → success snackbar → `context.go('/')` | ✅ Done |
| 3.6 | Verify `AppRouter` — no changes needed (AuthProvider holds state; redirect guards handle edge cases) | ✅ Done |

## Files Modified

| File | Description |
|------|-------------|
| `FrontEND/MarcaYa/lib/src/api_service.dart` | Added 3 methods: `solicitarCodigo`, `verificarCodigo`, `restablecerContrasena` — POST/PUT calls to backend endpoints |
| `FrontEND/MarcaYa/lib/providers/auth_provider.dart` | Added `_recoveryEmail`, `_verificationToken` fields + getters; added `solicitarCodigo`, `verificarCodigo`, `restablecerContrasena` methods |
| `FrontEND/MarcaYa/lib/pages/recuperar_contrasena/recuperar_contrasena.dart` | Converted to StatefulWidget; added `_emailController`; wired "Enviar" button → validate → call `AuthProvider.solicitarCodigo()` → navigate |
| `FrontEND/MarcaYa/lib/pages/codigo_contrasena/codigo_contrasena.dart` | Added imports + redirect guard (`recoveryEmail == null`); replaced hardcoded "123456" with real API call via `AuthProvider.verificarCodigo()` |
| `FrontEND/MarcaYa/lib/pages/nueva_contrasena/nueva_contrasena.dart` | Converted to StatefulWidget; added controllers + redirect guard (`verificationToken == null`); wired "Cambiar" button with validation + `AuthProvider.restablecerContrasena()` |

## Deviations from Design

None — implementation matches design.

## Issues Found

None.

## Remaining Tasks

All tasks complete.

## Delivery Info

- **Mode**: stacked-to-main — PR 3 of 3
- **Chain strategy**: stacked-to-main
- **Current work unit**: Frontend Wiring
- **Boundary**: ApiService, AuthProvider, 3 screens, redirect guards
- **Estimated review budget**: ~150 lines
