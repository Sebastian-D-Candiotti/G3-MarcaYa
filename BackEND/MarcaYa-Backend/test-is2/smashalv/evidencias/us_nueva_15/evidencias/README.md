# Evidencias de ejecucion - US-NUEVA-15

Entorno Docker, 2026-07-12 America/Lima.

| Comando | Resultado real |
|---|---|
| `rails test` del caso de uso y controller offline | 8 runs, 34 assertions, 0 failures, 0 errors, 0.59 s |
| `flutter test` de SQLite, conectividad y provider | 12 passed, 1.0 s |
| `rails test` completo | 383 runs, 839 assertions, 0 failures, 2 errors, 4.20 s |
| `flutter test` completo | 58 passed, 21 s |
| `flutter analyze` | 62 issues heredados; ninguno en tests nuevos |

Capturas manuales requeridas:

1. Consola de las 8 pruebas Rails y 12 Flutter aprobadas.
2. Dispositivo/emulador en modo sin internet.
3. Mensaje de marcacion guardada pendiente.
4. Contador de pendientes.
5. Recuperacion de red y sincronizacion.
6. Consulta backend mostrando la hora original.
7. Reintento del mismo lote mostrando `duplicados` sin filas adicionales.
