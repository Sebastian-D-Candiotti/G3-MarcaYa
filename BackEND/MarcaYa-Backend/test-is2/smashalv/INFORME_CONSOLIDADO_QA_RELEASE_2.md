# Informe consolidado de QA - MarcaYA Release 2

Responsable: Jose Fabrizzio Bustillos Rivera (Busti)

Fecha de consolidacion: 2026-07-13

Zona horaria: America/Lima

Repositorio: [Sebastian-D-Candiotti/G3-MarcaYa](https://github.com/Sebastian-D-Candiotti/G3-MarcaYa)

## 1. Objetivo

Este documento consolida los cambios, pruebas y evidencias generados para las historias asignadas durante el Release 2:

| Semana | Historia | Nombre | Estado de QA |
|---:|---|---|---|
| 1 | US-NUEVA-10 | Verificacion de cuenta por correo | EJECUTADA |
| 2 | US-NUEVA-15 | Modo offline y sincronizacion automatica | EJECUTADA |
| 3 | US-NUEVA-02 / HU3 | Justificacion de tardanzas e inasistencias | NO EJECUTADA: implementacion ausente |
| 4 | US-NUEVA-16 | Historial de informes y descarga PDF | EJECUTADA |

La informacion presentada proviene de ejecuciones reales registradas el 2026-07-12. No se declaran porcentajes de cobertura porque el repositorio no tiene una herramienta de cobertura configurada.

## 2. Ramas y commits publicados

| Historia | Rama | Commit QA | Descripcion |
|---|---|---|---|
| US-NUEVA-10 | `feature/historia-usuario-verificacion-cuenta` | [`4e77828`](https://github.com/Sebastian-D-Candiotti/G3-MarcaYa/commit/4e778284bb95ed2f4eb09212d1f36476777e34be) | Amplia cobertura de verificacion de cuenta |
| US-NUEVA-15 | `feature/historia-usuario-offline-sync` | [`985bba3`](https://github.com/Sebastian-D-Candiotti/G3-MarcaYa/commit/985bba388619293814640a5bc3b27ab895eebabd) | Cubre sincronizacion offline |
| US-NUEVA-02 | `feature/HU3-Justificacion-de-tardanzas` | [`75deff7`](https://github.com/Sebastian-D-Candiotti/G3-MarcaYa/commit/75deff72794987cbe0a3be7271d0775e181d3db8) | Registra brecha de implementacion HU3 |
| US-NUEVA-16 | `feature/US-NUEVA-16-informes-pdf` | [`60d7b73`](https://github.com/Sebastian-D-Candiotti/G3-MarcaYa/commit/60d7b738a65e9f69069ac11e61ec92e3dde5fde4) | Valida informes PDF y corrige regresiones |

Resumen de los cuatro commits: 57 entradas de archivo modificadas o creadas, 1891 inserciones y 46 eliminaciones. Algunas rutas de documentacion se repiten porque cada rama conserva su propia evidencia.

### 2.1 Documentacion agregada en cada rama

Cada rama incorpora una version propia de los siguientes archivos, con los datos y resultados exclusivos de su historia:

| Archivo | Contenido |
|---|---|
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/README.md` | Alcance, entorno, resultado y estado general de QA. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/matriz_trazabilidad.md` | Relacion entre criterios de aceptacion, archivos de prueba y evidencia. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/pruebas_unitarias.md` | Componentes aislados, dependencias simuladas y resultados. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/pruebas_integracion.md` | Flujos entre controladores, casos de uso, repositorios, base de datos y Flutter. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/pruebas_caja_negra.md` | Escenarios positivos, negativos, limites y resultados observados. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/defectos_corregidos.md` | Defectos reales, causa raiz, correccion, regresion y pendientes. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/evidencias/README.md` | Comandos ejecutados, cantidades, tiempos y capturas manuales requeridas. |

## 3. Entorno de pruebas

| Componente | Configuracion utilizada |
|---|---|
| Backend | Ruby 4.0.4, Rails 8.1.3, Minitest 6.0.6 |
| Base de datos | PostgreSQL 17.10, bases aisladas de prueba sin uso de desarrollo o produccion |
| Frontend | Flutter 3.44.0, Dart 3.12.0 y `flutter_test` |
| SQLite | `sqflite`; para US-NUEVA-15 se uso `sqflite_common_ffi` en memoria |
| Correo | Mailer sustituido por fakes; no se enviaron correos reales |
| Red y HTTP | Servicios simulados; no se dependio de desconectar fisicamente el equipo |
| Tiempo | Relojes o fechas inyectadas; no se uso `sleep` |

Bases de datos aisladas registradas: `MarcaYa_test_us10`, `MarcaYa_test_us15` y `MarcaYa_test_us16`.

## 4. Resumen cuantitativo

| Historia | Rails focalizado | Flutter focalizado | Suite Rails completa | Suite Flutter completa |
|---|---|---|---|---|
| US-NUEVA-10 | 33 pruebas, 208 aserciones, 0 fallos, 0 errores | 11 aprobadas | 387 pruebas, 0 fallos, 2 errores ajenos en Solicitudes | 56 aprobadas |
| US-NUEVA-15 | 8 pruebas, 34 aserciones, 0 fallos, 0 errores | 12 aprobadas | 383 pruebas, 0 fallos, 2 errores ajenos en Solicitudes | 58 aprobadas |
| US-NUEVA-02 | No ejecutada | No ejecutada | No aplica | No aplica |
| US-NUEVA-16 | 18 pruebas, 64 aserciones, 0 fallos, 0 errores | 4 aprobadas | 502 pruebas, 11 fallos y 2 errores ajenos a informes | 53 pruebas: 37 aprobadas y 16 fallidas por URL base heredada |

Sumatoria informativa de pruebas focalizadas de las historias implementadas: 59 ejecuciones Rails y 27 Flutter. Esta suma no representa cobertura porcentual ni una unica suite, porque corresponde a ramas y comandos independientes.

## 5. US-NUEVA-10 - Verificacion de cuenta

### 5.1 Cambios agregados

Archivos productivos modificados:

| Archivo | Cambio y motivo |
|---|---|
| `BackEND/MarcaYa-Backend/app/application/use_cases/auth/verificar_cuenta.rb` | Se permitio inyectar un reloj para validar exactamente el limite de expiracion sin esperas reales. El valor por defecto conserva el comportamiento productivo. |
| `BackEND/MarcaYa-Backend/app/infrastructure/services/verification_code_service.rb` | Se permitio inyectar el numero aleatorio para probar formato y conservacion de ceros iniciales. El valor por defecto sigue usando `SecureRandom`. |
| `FrontEND/MarcaYa/lib/providers/verificacion_cuenta_provider.dart` | Se permitio inyectar `ApiService` para probar loading, respuestas, errores y navegacion sin red real. |

Archivos de prueba creados o ampliados:

| Archivo | Proposito |
|---|---|
| `BackEND/MarcaYa-Backend/test/infrastructure/services/verification_code_service_test.rb` | Formato numerico, seis digitos, ceros iniciales, hash, comparacion y TTL de 600 segundos. |
| `BackEND/MarcaYa-Backend/test/application/use_cases/auth/registrar_usuario_test.rb` | Estado inicial pendiente, generacion del codigo, invocacion unica del mailer y fallo controlado de correo. |
| `BackEND/MarcaYa-Backend/test/application/use_cases/auth/verificar_cuenta_test.rb` | Codigo correcto, incorrecto, vencido, usado, usuario inexistente y activacion unica. |
| `BackEND/MarcaYa-Backend/test/application/use_cases/auth/reenviar_codigo_verificacion_test.rb` | Regeneracion e invalidacion del digest anterior. |
| `FrontEND/MarcaYa/test/verificacion_cuenta_provider_test.dart` | Estados loading/success/error e interpretacion de respuestas 200, 404, 409 y 422. |
| `FrontEND/MarcaYa/test/verificacion_registro_page_test.dart` | Validacion del codigo, caracteres no numericos y navegacion solo con estado `ACTIVO`. |

### 5.2 Casos validados

- Cuenta nueva con estado `PENDIENTE_VERIFICACION`.
- Codigo de exactamente seis digitos numericos.
- Conservacion de ceros iniciales, por ejemplo `004281`.
- Codigo almacenado como hash y no como texto plano.
- Expiracion exacta a los 600 segundos.
- Activacion solo con codigo correcto y vigente.
- Rechazo de codigo incorrecto, vencido, usado o de usuario inexistente.
- Reenvio que sustituye el digest anterior.
- Mailer invocado una sola vez y error de correo controlado.
- Flutter no navega ante error y navega solo cuando el backend responde `ACTIVO`.

### 5.3 Evidencia de ejecucion

| Comando o alcance | Resultado real |
|---|---|
| `rails test` sobre los cuatro archivos focalizados de servicio y casos de uso | 23 runs, 145 assertions, 0 failures, 0 errors, 0 skips, 0.50 s |
| `rails test test/controllers/api/v1/auth_controller_test.rb` | 10 runs, 63 assertions, 0 failures, 0 errors, 3.55 s |
| `flutter test` sobre provider y pagina de verificacion | 11 passed, 8.0 s |
| `rails test` completo | 387 runs, 928 assertions, 0 failures, 2 errors, 12.0 s |
| `flutter test` completo | 56 passed |
| `flutter analyze` | 61 observaciones heredadas; ninguna en archivos nuevos |

Estado final: la funcionalidad focalizada aprobo. La suite Rails completa conserva dos errores ajenos en Solicitudes.

## 6. US-NUEVA-15 - Modo offline y sincronizacion

### 6.1 Cambios agregados

Archivos productivos o de soporte modificados:

| Archivo | Cambio y motivo |
|---|---|
| `FrontEND/MarcaYa/lib/repositories/marcacion_pendiente_repository.dart` | Se permitio inyectar `DatabaseFactory` y ruta de base, y se agrego `close()`, para usar SQLite real en memoria durante las pruebas. |
| `FrontEND/MarcaYa/lib/services/connectivity_service.dart` | Se permitio inyectar el stream de conectividad y el checker para simular perdida y recuperacion de red. |
| `FrontEND/MarcaYa/pubspec.yaml` | Se agrego `sqflite_common_ffi` solo como dependencia de desarrollo. |
| `FrontEND/MarcaYa/pubspec.lock` | Se actualizaron las resoluciones asociadas a la dependencia de prueba. |

Archivos de prueba creados o ampliados:

| Archivo | Proposito |
|---|---|
| `BackEND/MarcaYa-Backend/test/application/use_cases/asistencias/sincronizar_marcaciones_offline_test.rb` | Lote valido, exito parcial, timestamp original, datos invalidos e idempotencia. |
| `BackEND/MarcaYa-Backend/test/controllers/api/v1/asistencias_controller_test.rb` | Integracion de endpoint, PostgreSQL, respuesta parcial y deteccion de duplicados. |
| `FrontEND/MarcaYa/test/marcacion_pendiente_repository_test.dart` | Persistencia SQLite, estado pendiente, recuperacion y limpieza selectiva. |
| `FrontEND/MarcaYa/test/connectivity_service_test.dart` | Estado inicial, transiciones y eventos repetidos sin red fisica. |
| `FrontEND/MarcaYa/test/asistencia_offline_provider_test.dart` | Guardado offline, contador, lote, error 500, exito parcial y bloqueo concurrente. |

### 6.2 Casos validados

- Deteccion simulada de perdida y recuperacion de conexion.
- Marcacion local con estado `PENDIENTE_SINCRONIZACION`.
- Conservacion de la hora fisica original y de los datos geograficos.
- Envio de marcaciones acumuladas en lote.
- Limpieza local solo de registros sincronizados o reconocidos como duplicados.
- Conservacion de registros fallidos ante exito parcial o HTTP 500.
- Ausencia de llamada al backend si no existen pendientes.
- Idempotencia mediante `cliente_marcacion_id`.
- Segundo envio identificado como duplicado sin insertar otra fila.
- Bloqueo de sincronizaciones concurrentes y una sola solicitud HTTP.

### 6.3 Evidencia de ejecucion

| Comando o alcance | Resultado real |
|---|---|
| `rails test` del caso de uso y controlador offline | 8 runs, 34 assertions, 0 failures, 0 errors, 0.59 s |
| `flutter test` de SQLite, conectividad y provider | 12 passed, 1.0 s |
| `rails test` completo | 383 runs, 839 assertions, 0 failures, 2 errors, 4.20 s |
| `flutter test` completo | 58 passed, 21 s |
| `flutter analyze` | 62 observaciones heredadas; ninguna en las pruebas nuevas |

Estado final: la funcionalidad focalizada aprobo. Los registros no confirmados permanecen localmente y los reintentos no duplican asistencias.

## 7. US-NUEVA-02 / HU3 - Justificaciones

### 7.1 Resultado de auditoria

La rama no contiene la implementacion descrita por `docs/HU3-Jose-Bustillos.txt`. El commit funcional `2143536` y el merge `89c5c97` incorporan solamente el TXT. No existen en el arbol de esa rama:

- Entidad o modelo `Justificacion`.
- Migracion o configuracion de adjuntos correspondiente.
- Casos de uso de registro, aprobacion o rechazo.
- Endpoints de justificaciones.
- Provider, servicio o pantalla Flutter de la historia.
- Pruebas automatizadas de HU3.

### 7.2 Documentacion agregada

| Archivo | Proposito |
|---|---|
| `docs/HU3-Jose-Bustillos.txt` | Se agrego la advertencia de QA sobre el codigo fuente ausente. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/README.md` | Diagnostico y estado `NO EJECUTADA`. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/matriz_trazabilidad.md` | Criterios bloqueados por falta de implementacion. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/pruebas_unitarias.md` | Casos previstos y motivo concreto de no ejecucion. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/pruebas_integracion.md` | Flujos previstos y componentes ausentes. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/pruebas_caja_negra.md` | Casos manuales pendientes. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/defectos_corregidos.md` | Registro `DEF-02-01`, pendiente por codigo no versionado. |
| `docs/pruebas/jose_fabrizzio_bustillos_rivera/evidencias/README.md` | Comandos y hallazgos de auditoria. |

### 7.3 Evidencia de auditoria

| Comando | Resultado real |
|---|---|
| `git show --stat 2143536` | Un archivo: `docs/HU3-Jose-Bustillos.txt`, 91 lineas |
| `git diff --stat 89c5c97^1 89c5c97` | El merge incorpora solo el mismo TXT |
| Busqueda de `justificacion`, `tardanza` e `inasistencia` | Sin implementacion HU3; solo referencias de dashboard o documentacion |

Estado final: `NO EJECUTADA`. No se inventaron clases, endpoints, resultados ni defectos funcionales. La accion necesaria es recuperar el commit que contenga la implementacion o desarrollar la historia antes de crear sus pruebas.

## 8. US-NUEVA-16 - Historial de informes y PDF

### 8.1 Cambios agregados

Archivos productivos modificados:

| Archivo | Cambio y motivo |
|---|---|
| `BackEND/MarcaYa-Backend/app/application/use_cases/informes_asistencia/base.rb` | Se reemplazo `Date.parse` por `Date.iso8601` para rechazar fechas ambiguas. |
| `BackEND/MarcaYa-Backend/app/infrastructure/orm/informe_asistencia_record.rb` | Se consulta el estado persistido con `attribute_in_database` para impedir actualizar o eliminar informes cerrados. |
| `BackEND/MarcaYa-Backend/db/schema.rb` | Se sincronizo el esquema con migraciones existentes para recuperar columnas y tablas omitidas. |
| `FrontEND/MarcaYa/lib/providers/informes_asistencia_provider.dart` | Se permitio inyectar `ApiService` para validar historial, preview, cierre y PDF sin red real. |

Archivos de prueba creados o ampliados:

| Archivo | Proposito |
|---|---|
| `BackEND/MarcaYa-Backend/test/application/use_cases/informes_asistencia/base_test.rb` | Tipos, fechas ISO, rangos y limites diario, semanal y mensual. |
| `BackEND/MarcaYa-Backend/test/infrastructure/orm/informe_asistencia_record_test.rb` | Validaciones e inmutabilidad de informes cerrados. |
| `BackEND/MarcaYa-Backend/test/infrastructure/services/asistencia_pdf_service_test.rb` | PDF valido, tildes, periodo vacio y salida multipagina. |
| `BackEND/MarcaYa-Backend/test/controllers/api/v1/informes_asistencia_controller_test.rb` | Preview, cierre, historial, descarga, autorizacion, periodo vacio y doble cierre. |
| `BackEND/MarcaYa-Backend/test/application/use_cases/asistencias/sincronizar_marcaciones_offline_test.rb` | Ajuste de regresion compartida para el esquema actualizado. |
| `FrontEND/MarcaYa/test/informes_asistencia_provider_test.dart` | Loading, historial, error, descarga PDF y refresco tras cierre. |

### 8.2 Casos validados

- Agrupacion diaria, semanal y mensual.
- Rechazo de semana de ocho dias, mes incompleto, rango invertido y fecha no ISO.
- Periodos sin asistencias con totales en cero.
- Creacion de snapshot mensual en estado `CERRADO`.
- Bloqueo de doble cierre con HTTP 409.
- Inmutabilidad ante update y destroy.
- Historial y descarga `application/pdf`.
- PDF con tildes, varias filas y multiples paginas.
- HTTP 404 para informe inexistente.
- HTTP 403 para rol sin permisos.
- Provider Flutter con historial, error, cierre y descarga.

### 8.3 Evidencia de ejecucion

| Comando o alcance | Resultado real |
|---|---|
| `rails test` de Base, ORM, PDF y controlador | 18 runs, 64 assertions, 0 failures, 0 errors, 2.01 s |
| `rails test` focalizado mas regresion de sincronizacion compartida | 21 runs, 77 assertions, 0 failures, 0 errors, 2.0 s |
| `flutter test test/informes_asistencia_provider_test.dart` | 4 passed |
| `rails test` completo | 502 runs, 1106 assertions, 11 failures, 2 errors, 11.43 s |
| `flutter test` completo | 53 tests: 37 passed y 16 failed por URL base heredada |
| `flutter analyze` | 96 observaciones heredadas; ninguna en archivos nuevos |

Estado final: las 18 pruebas focalizadas de US-NUEVA-16 aprobaron. Las incidencias de las suites completas son transversales y quedaron documentadas, no ocultadas.

## 9. Defectos reales y estado

| ID | Historia | Severidad | Hallazgo | Accion | Estado |
|---|---|---|---|---|---|
| DEF-15-01 | US-NUEVA-15 | Baja | Los repositorios fake evaluaban entidades fuera del cierre y causaban `NameError` | Capturar las entidades antes de definir los metodos singleton | CORREGIDO |
| DEF-02-01 | US-NUEVA-02 | Alta | La documentacion declara una implementacion no versionada | Advertencia QA; falta recuperar o implementar el codigo | PENDIENTE |
| DEF-16-01 | US-NUEVA-16 | Alta | Un informe cerrado podia modificarse | Validar el estado persistido con `attribute_in_database` | CORREGIDO |
| DEF-16-02 | US-NUEVA-16 | Media | `Date.parse` aceptaba fechas ambiguas | Usar `Date.iso8601` | CORREGIDO |
| DEF-16-03 | Transversal | Alta | `schema.rb` omitia objetos ya migrados | Regenerar y sincronizar el esquema de prueba | CORREGIDO para carga por esquema |
| DEF-QA-01 | Transversal | Media | `db:prepare` cargaba seeds incompatibles con fixtures | Usar base aislada y carga de esquema sin seeds | PENDIENTE en configuracion |
| DEF-QA-02 | Solicitudes | Media | Dos errores en la suite Rails completa | Corregir fake y regla de pertenencia en la rama propietaria | PENDIENTE |
| DEF-QA-03 | Transversal | Alta | La cadena historica de migraciones usa `solicitudes` antes de crearla | Reordenar o agregar migracion base | PENDIENTE |
| DEF-QA-04 | Flutter transversal | Media | Tests heredados esperan localhost y `ApiService` usa Render | Inyectar `baseUrl` de forma uniforme | PENDIENTE |

No se reprodujo un defecto funcional propio de US-NUEVA-10. Sus cambios productivos fueron puntos de inyeccion para pruebas con valores por defecto equivalentes a produccion.

## 10. Trazabilidad resumida

| Historia | Criterio | Evidencia principal | Estado |
|---|---|---|---|
| US-NUEVA-10 | Cuenta nueva pendiente | `registrar_usuario_test.rb` | APROBADA |
| US-NUEVA-10 | Codigo numerico de seis digitos y TTL de diez minutos | `verification_code_service_test.rb` | APROBADA |
| US-NUEVA-10 | Solo codigo correcto y vigente activa | `verificar_cuenta_test.rb` | APROBADA |
| US-NUEVA-10 | Pantalla y navegacion condicionada a `ACTIVO` | `verificacion_registro_page_test.dart` | APROBADA |
| US-NUEVA-15 | Detectar perdida y recuperacion | `connectivity_service_test.dart` | APROBADA |
| US-NUEVA-15 | Guardar pendiente con hora original | `marcacion_pendiente_repository_test.dart` | APROBADA |
| US-NUEVA-15 | Sincronizar lote y limpiar selectivamente | `asistencia_offline_provider_test.dart` | APROBADA |
| US-NUEVA-15 | Preservar timestamp e impedir duplicados | `asistencias_controller_test.rb` | APROBADA |
| US-NUEVA-02 | Registrar y revisar justificaciones | Componentes no existentes | NO EJECUTADA |
| US-NUEVA-16 | Periodos y limites | `base_test.rb` y controller test | APROBADA |
| US-NUEVA-16 | Snapshot cerrado e inmutable | `informe_asistencia_record_test.rb` | APROBADA |
| US-NUEVA-16 | PDF e historial | PDF service, controller y provider tests | APROBADA |

Las matrices completas, casos unitarios, integraciones y caja negra se encuentran en `docs/pruebas/jose_fabrizzio_bustillos_rivera/` dentro de cada rama.

## 11. Comandos para reproducir la evidencia

Ejecutar siempre con el checkout de la rama correspondiente.

### Backend

Desde `BackEND/MarcaYa-Backend` y con `RAILS_ENV=test`:

```powershell
rails test test/infrastructure/services/verification_code_service_test.rb test/application/use_cases/auth/registrar_usuario_test.rb test/application/use_cases/auth/verificar_cuenta_test.rb test/application/use_cases/auth/reenviar_codigo_verificacion_test.rb
rails test test/controllers/api/v1/auth_controller_test.rb

rails test test/application/use_cases/asistencias/sincronizar_marcaciones_offline_test.rb test/controllers/api/v1/asistencias_controller_test.rb

rails test test/application/use_cases/informes_asistencia/base_test.rb test/infrastructure/orm/informe_asistencia_record_test.rb test/infrastructure/services/asistencia_pdf_service_test.rb test/controllers/api/v1/informes_asistencia_controller_test.rb

rails test
```

La base debe ser una base de test aislada. No se deben cargar seeds incompatibles ni apuntar a desarrollo o produccion.

### Frontend

Desde `FrontEND/MarcaYa`:

```powershell
flutter pub get
flutter test test/verificacion_cuenta_provider_test.dart test/verificacion_registro_page_test.dart
flutter test test/marcacion_pendiente_repository_test.dart test/connectivity_service_test.dart test/asistencia_offline_provider_test.dart
flutter test test/informes_asistencia_provider_test.dart
flutter test
flutter analyze
```

## 12. Evidencias recomendadas para el grupo

Capturas que deben anexarse al informe o presentacion:

1. GitHub mostrando las cuatro ramas y sus commits QA.
2. Consola de US-NUEVA-10 con 23 pruebas Rails y 11 Flutter aprobadas.
3. Usuario registrado en estado `PENDIENTE_VERIFICACION`.
4. Pantalla de codigo correcto y navegacion posterior; mensajes de codigo incorrecto y vencido.
5. Consola de US-NUEVA-15 con 8 pruebas Rails y 12 Flutter aprobadas.
6. Marcacion sin internet, mensaje pendiente y contador local.
7. Recuperacion de red, sincronizacion y consulta backend con la hora original.
8. Reintento del mismo `cliente_marcacion_id` identificado como duplicado sin una segunda fila.
9. Auditoria Git de HU3 mostrando que el commit incorpora solo documentacion.
10. Consola de US-NUEVA-16 con 18 pruebas Rails y 4 Flutter aprobadas.
11. Vista previa diaria, semanal y mensual; periodo vacio con totales en cero.
12. Cierre mensual, intento de doble cierre, historial y descarga del PDF multipagina.
13. Intento de acceso a informes con rol empleado y respuesta HTTP 403.

Al capturar la consola se debe mostrar la rama activa, el comando completo y el resumen final. No se deben exponer contrasenas, tokens, codigos de verificacion reales ni credenciales de base de datos.

## 13. Limitaciones y pendientes

- US-NUEVA-02 no puede probarse hasta que su implementacion este versionada.
- La suite Rails conserva errores heredados en Solicitudes en algunas ramas.
- La cadena de migraciones historicas no reconstruye una base vacia por el orden de `solicitudes`.
- La suite Flutter de US-NUEVA-16 conserva 16 fallos heredados por una URL base inconsistente.
- Las observaciones de `flutter analyze` son heredadas; no se detectaron observaciones en los archivos nuevos indicados por los reportes.
- No se calculo cobertura porcentual porque no hay una herramienta de cobertura configurada.
- Las capturas visuales de dispositivo o emulador deben obtenerse manualmente; la evidencia automatizada disponible es textual y reproducible mediante los comandos anteriores.

## 14. Conclusion

US-NUEVA-10, US-NUEVA-15 y US-NUEVA-16 cuentan con pruebas focalizadas aprobadas de backend y Flutter, trazabilidad, caja negra y registro de defectos. HU3 fue auditada y marcada correctamente como `NO EJECUTADA` porque su codigo no existe en la rama revisada. Los problemas transversales encontrados se conservaron como pendientes visibles para evitar presentar como aprobada una suite que aun contiene fallos ajenos a las historias focalizadas.
