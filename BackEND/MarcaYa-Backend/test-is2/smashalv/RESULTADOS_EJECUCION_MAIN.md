# Evidencia de ejecucion en main

Responsable: Jose Fabrizzio Bustillos Rivera

Fecha: 2026-07-13

Entorno: Docker, America/Lima

Rama evaluada: `main`

## 1. Entorno aislado

- Backend: Ruby 4.0.4, Rails 8.1.3 y Minitest 6.0.6.
- Base: PostgreSQL 17.10, base exclusiva `MarcaYa_test_main_is2`.
- Carga de base: `db:schema:load`, sin seeds.
- Frontend: Flutter 3.44.0, Dart 3.12.0 y `flutter_test`.
- SQLite: `sqflite_common_ffi` con base en memoria.
- Red, correo y conectividad: fakes o modo test; no se enviaron correos reales.

## 2. Resultado focalizado

| Historia | Comando | Pruebas | Aserciones | Fallos | Errores | Resultado |
|---|---|---:|---:|---:|---:|---|
| US-NUEVA-10 | `bin/rails test test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_10` | 33 | 208 | 0 | 0 | APROBADA |
| US-NUEVA-15 | `bin/rails test test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_15` | 8 | 34 | 0 | 0 | APROBADA |
| US-NUEVA-16 | `bin/rails test test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_16` | 18 | 64 | 0 | 0 | APROBADA |
| US-10/15/16 Flutter | `flutter test test-is2/jose_fabrizzio_bustillos_rivera` | 27 | No reportadas por Flutter | 0 | 0 | APROBADA |
| US-NUEVA-02 | No ejecutable | 0 | 0 | 0 | 0 | NO EJECUTADA: codigo ausente |

Totales focalizados: 59 pruebas Rails, 306 aserciones Rails y 27 pruebas Flutter aprobadas.

## 3. Analisis estatico focalizado

Los siguientes archivos y carpetas fueron analizados individualmente y no presentaron incidencias:

- `lib/providers/verificacion_cuenta_provider.dart`.
- `lib/providers/informes_asistencia_provider.dart`.
- `lib/repositories/marcacion_pendiente_repository.dart`.
- `lib/services/connectivity_service.dart`.
- `test-is2/jose_fabrizzio_bustillos_rivera/`.

Resultado: `No issues found` para cada ruta.

El analisis completo de Flutter reporto 133 incidencias heredadas. Incluye errores ajenos en `resumen_empresa.dart` y `marcar_asistencia.dart`; no se declaro el proyecto completo como aprobado.

## 4. Regresion completa

| Suite | Resultado real | Estado |
|---|---|---|
| Rails completa | 498 runs, 1101 assertions, 12 failures, 5 errors, 0 skips | CON OBSERVACIONES |
| Flutter completa | 80 pruebas: 64 aprobadas y 16 fallidas | CON OBSERVACIONES |

Las 16 fallas Flutter heredadas se concentran en tests que esperan `localhost` o `127.0.0.1`, mientras `ApiService` usa `https://g3-marcaya.onrender.com`. Las pruebas focalizadas inyectan el cliente HTTP y no dependen de una URL real.

Las incidencias Rails completas incluyen modulos ajenos como Obras, Alertas, FCM y Solicitudes, ademas de copias antiguas de pruebas que permanecen en `test/`. Las pruebas actualizadas de las historias entregadas, ubicadas en `test-is2`, aprobaron sin fallos.

## 5. Defectos encontrados durante la integracion

| ID | Defecto | Causa | Correccion | Estado |
|---|---|---|---|---|
| MAIN-QA-01 | Fixtures de verificacion no cargaban | `schema.rb` omitia columnas y tablas de migraciones existentes | Se sincronizaron email verification, OTP, devices, device id, idempotencia y verificaciones RUC | CORREGIDO |
| MAIN-QA-02 | `flutter pub get` no iniciaba | `flutter_local_notifications` estaba duplicado en `pubspec.yaml` | Se conservo una unica declaracion con la misma version | CORREGIDO |
| MAIN-QA-03 | SQLite rechazaba `is_mocked` | El modelo enviaba el campo, pero la tabla local no lo tenia | Base local version 2, columna en `onCreate` y migracion en `onUpgrade` | CORREGIDO |
| MAIN-QA-04 | Tests US-10 no reflejaban RENIEC y device pinning actuales | La rama QA era anterior a esas integraciones de `main` | Se agregaron fakes/datos de prueba y `device_id` sin cambiar las reglas productivas | CORREGIDO |

## 6. Comandos de reproduccion

Backend, desde `BackEND/MarcaYa-Backend`:

```powershell
$env:RAILS_ENV = "test"
bin/rails test test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_10
bin/rails test test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_15
bin/rails test test-is2/jose_fabrizzio_bustillos_rivera/us_nueva_16
bin/rails test
```

Frontend, desde `FrontEND/MarcaYa`:

```powershell
flutter pub get
flutter test test-is2/jose_fabrizzio_bustillos_rivera
flutter test
flutter analyze
```

## 7. Evidencia visual recomendada

1. GitHub en `main` mostrando `BackEND/MarcaYa-Backend/test-is2/jose_fabrizzio_bustillos_rivera`.
2. Consola US-NUEVA-10: `33 runs, 208 assertions, 0 failures, 0 errors`.
3. Consola US-NUEVA-15: `8 runs, 34 assertions, 0 failures, 0 errors`.
4. Consola US-NUEVA-16: `18 runs, 64 assertions, 0 failures, 0 errors`.
5. Consola Flutter: `+27: All tests passed`.
6. Analisis focalizado: `No issues found`.
7. Estado HU3: `NO EJECUTADA` con la evidencia de codigo ausente.

## 8. Cobertura

No se calculo porcentaje de cobertura. El repositorio no tiene una herramienta de cobertura configurada y no se incluyen valores estimados.
