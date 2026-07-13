# QA - US-NUEVA-15 Modo offline y sincronizacion

Responsable funcional: Jose Fabrizzio Bustillos Rivera.
Rama: `feature/historia-usuario-offline-sync`.
Fecha de ejecucion: 2026-07-12 (America/Lima).

## Alcance

Se validaron conectividad simulada, persistencia SQLite, estado `PENDIENTE_SINCRONIZACION`, hora original, lote, exito parcial, limpieza selectiva, reintentos idempotentes y bloqueo de sincronizaciones concurrentes.

## Entorno

- Ruby 4.0.4, Rails 8.1.3, Minitest 6.0.6.
- PostgreSQL 17.10, base aislada `MarcaYa_test_us15`, sin seeds.
- Flutter 3.44.0, Dart 3.12.0, `flutter_test`.
- SQLite de memoria mediante `sqflite_common_ffi` 2.4.0+3.
- HTTP, almacenamiento seguro y conectividad simulados; no se uso red real.

## Resultado

- Backend focalizado: 8 pruebas, 34 aserciones, todas aprobadas.
- Flutter focalizado: 12 pruebas, todas aprobadas.
- Backend completo: 383 pruebas, 0 fallos y 2 errores ajenos en Solicitudes.
- Flutter completo: 58 pruebas aprobadas.
- Analisis Flutter: 62 observaciones heredadas; ninguna en los archivos nuevos.
- Cobertura porcentual: no calculada porque el proyecto no configura cobertura.

`sqflite_common_ffi` se agrego solo como dependencia de desarrollo para ejecutar SQLite real en la VM de pruebas sin dispositivo fisico.
