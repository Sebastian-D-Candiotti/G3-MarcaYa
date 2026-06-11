# Informe de Merge — Semana 1

Tres ramas de feature desarrolladas en paralelo se integraron a `main` con conflictos y errores post-merge. Este documento detalla qué se resolvió en cada una y qué bugs quedaron (y se corrigieron).

---

## 1. `feature/Semana1_Angelo` → `main`

**Merge commit:** `08c27a9`

### Conflictos (4 archivos)

| Archivo | Conflicto | Resolución |
|---|---|---|
| `auth_controller.rb` | Ambas ramas modificaban `skip_before_action` y agregaban endpoints distintos | Unificar `skip_before_action` con todos los endpoints de ambas ramas; mantener `login`, `registro`, `solicitar_codigo`, `verificar_codigo`, `restablecer_contrasena`, `verificar_otp` |
| `application_mailer.rb` | `default from` distinto en cada rama | Usar `ENV["SMTP_DEFAULT_FROM"]` como prioritario, con fallback a `ENV["SMTP_USERNAME"]` y luego credenciales |
| `development.rb` | Configuración SMTP vs `:test` | Mantener SMTP condicional (solo si hay vars de entorno), con fallback a `:test` |
| `routes.rb` | Rutas duplicadas/ausentes | Incluir rutas de auth (password recovery) + sunat (verificación OTP) |

### Errores post-merge

- **SyntaxError en `auth_controller.rb`** (`fe16360`): quedó un `end` extra tras resolver conflictos. Se eliminó.
- **`NoMethodError: solicitar_codigo`**: el servidor Rails no recargó la clase `UsuarioMailer` tras el merge. Se reinició el servidor.

---

## 2. `feature/historia-usuario-verificacion-cuenta` → `main`

**Merge commit:** `bb03239`

### Conflictos (8 archivos)

| Archivo | Conflicto | Resolución |
|---|---|---|
| `auth_controller.rb` | Múltiples modificaciones en `skip_before_action` y endpoints | Unificar todos los endpoints de ambas ramas + nuevos de verificación |
| `auth_facade.rb` | Dependencias distintas en `initialize` | Mantener `notificador` (password recovery) + nuevos servicios de verificación (`verification_code_service`, `verification_mailer`) |
| `registrar_usuario.rb` | Flujo de registro divergente | Mantener flujo OTP manual de empresa + agregar `requiere_verificacion` en el resultado |
| `dependency_injection.rb` | Configuración de servicios | Combinar `notificador` + servicios de verificación de cuenta |
| `routes.rb` | Rutas de auth vs sunat vs verificación | Incluir rutas de auth, password recovery, sunat y verificación de cuenta |
| `schema.rb` | Dos migraciones agregadas en paralelo | Actualizar a la versión más reciente fusionando ambas |
| `registrar_empresa.dart` | Flujo de registro frontend | Redirigir a pantalla de verificación de cuenta después del registro |
| `api_service.dart` | Métodos HTTP divergentes | Mantener métodos existentes + agregar nuevos de verificación |

### Errores post-merge

- **Tests fallaban** (`db2e253`): `registrar_usuario_test.rb` y `auth_facade_test.rb` no incluían las nuevas dependencias (`verification_code_service`, `verification_mailer`, `notificador`) en los mocks. Se actualizaron los tests y el `schema.rb` para reflejar el orden correcto de columnas.

---

## 3. `feature/Semana1-Joaquin/Validar-DNI` → `main`

**Merge commit:** `8f013e2`

### Conflictos (6 archivos)

| Archivo | Conflicto | Resolución |
|---|---|---|
| `auth_facade.rb` | Dependencias en `initialize` | Agregar `reniec_service` a la lista de dependencias |
| `registrar_usuario.rb` | Validación de DNI vs flujo existente | Validar DNI con RENIEC para empleados, RUC con OTP para empresas |
| `database.yml` | Config de PostgreSQL distinta | Mantener host `127.0.0.1`, usuario `postgres`, password `mapalo58` |
| `dependency_injection.rb` | Registro de servicios | Agregar `ReniecService` al contenedor de DI |
| `registrar_empleado.dart` | Flujo de registro vs DNI | Enviar DNI al backend y que el backend valide con RENIEC |
| `api_service.dart` | Métodos `verificarOtp` inconsistentes | Mantener `verificarOtp(ruc, codigo)` correcto |

### Errores post-merge

| Commit | Problema | Solución |
|---|---|---|
| `867eb63` | `ReniecService` generaba datos fake pero solo si el DNI tenía 8 dígitos; no hacía llamadas HTTP reales | Generar datos fake para cualquier DNI válido |
| `07bcbf1` | Inputs de nombre/apellido deshabilitados en el formulario de empleado | Habilitarlos para que el usuario pueda editarlos |
| `2ed3a47` | No se consultaba RENIEC al registrar empleado; el DNI se guardaba sin validar | Agregar validación RENIEC en el caso de uso `registrar_usuario.rb` |
| `45dae93` | `ReniecService` no hacía llamadas HTTP reales a GraphPeru; solo datos fake | Implementar `Net::HTTP` a `https://graphperu.daustinn.com/api/query/{dni}` |
| `44ad7ad` | DNI no encontrado en API también caía a datos fake | Separar: DNI no existe → error, solo sin internet → datos fake |
| `7c355a2` | Datos hardcodeados visibles para DNIs no encontrados | Eliminar `datos_fake` del flujo normal; solo en test |
| `9b78e09` | Al cambiar el DNI en el frontend no se reseteaban los campos | Resetear nombres/apellido al editar el DNI |
| `9c18953` | GraphPeru tiene datos limitados (muchos DNIs no existen en su DB) | Integrar Decolecta API como proveedor primario (requiere API key) |

---

## Errores comunes en los 3 merges

1. **`skip_before_action` desincronizado**: cada rama agregaba endpoints públicos pero pisaba la lista de los otros. Hubo que unificarlo manualmente en cada merge.
2. **Dependencias de `RegistrarUsuario` incompletas**: cada feature agregaba un servicio nuevo (sunat, verification, reniec) y los tests quedaban rotos hasta actualizar los mocks.
3. **Servidor Rails no recarga clases nuevas**: tras mergear, aparecían `NoMethodError` que se solucionaban reiniciando el servidor.

---

## Estado final

- Backend: 380 tests, 0 failures, 0 errors
- 3 features mergeadas, ~3400 líneas agregadas
- Todos los errores post-merge corregidos
- Pendiente: registrar API key de Decolecta en `.env` para consultas más completas
