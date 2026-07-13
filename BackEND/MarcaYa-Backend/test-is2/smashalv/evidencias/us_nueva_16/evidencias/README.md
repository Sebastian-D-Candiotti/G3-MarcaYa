# Evidencias de ejecucion - US-NUEVA-16

Entorno Docker, 2026-07-12 America/Lima.

| Comando | Resultado real |
|---|---|
| `rails test` de Base, ORM, PDF y controller | 18 runs, 64 assertions, 0 failures, 0 errors, 2.01 s |
| `rails test` focalizado mas sync compartida | 21 runs, 77 assertions, 0 failures, 0 errors, 2.0 s |
| `flutter test test/informes_asistencia_provider_test.dart` | 4 passed |
| `rails test` completo | 502 runs, 1106 assertions, 11 failures, 2 errors, 11.43 s |
| `flutter test` completo | 53 tests: 37 passed, 16 failed por URL base heredada |
| `flutter analyze` | 96 issues heredados; 0 en archivos nuevos |

Evidencias antes/despues reproducidas:

1. Antes del schema fix: 18 errores, 0 aserciones por columnas ausentes.
2. Antes de fixes de negocio: 4 fallos (inmutabilidad, fecha y 2 expectativas de test).
3. Despues: 18 pruebas US-16 y 64 aserciones aprobadas.

Capturas manuales requeridas:

1. Consola focalizada Rails y Flutter aprobada.
2. Vista previa diaria, semanal y mensual.
3. Periodo sin registros.
4. Cierre mensual e intento de doble cierre.
5. Historial mostrando informe cerrado.
6. Descarga y apertura del PDF con tildes y multiples filas.
7. Intento de acceso con rol empleado.
