# Evidencias de ejecucion - US-NUEVA-10

Entorno Docker, 2026-07-12 America/Lima.

| Comando | Resultado real |
|---|---|
| `rails test` sobre cuatro archivos focalizados | 23 runs, 145 assertions, 0 failures, 0 errors, 0 skips, 0.50 s |
| `rails test test/controllers/api/v1/auth_controller_test.rb` | 10 runs, 63 assertions, 0 failures, 0 errors, 3.55 s |
| `flutter test` sobre provider y page | 11 passed, 8.0 s |
| `rails test` completo | 387 runs, 928 assertions, 0 failures, 2 errors, 12.0 s |
| `flutter test` completo | 56 passed |
| `flutter analyze` | 61 issues heredados; 0 en archivos nuevos |

Capturas manuales requeridas para el informe:

1. Consola con las 23 pruebas Rails aprobadas.
2. Consola con las 11 pruebas Flutter aprobadas.
3. Registro que muestre estado PENDIENTE_VERIFICACION.
4. Correo de sandbox o log de entrega sin revelar el codigo en una respuesta API.
5. Pantalla de codigo correcto y navegacion al login.
6. Mensajes de codigo incorrecto y vencido.
