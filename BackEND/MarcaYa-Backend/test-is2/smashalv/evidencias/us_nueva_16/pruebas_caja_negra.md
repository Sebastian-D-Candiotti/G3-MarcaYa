# Pruebas de caja negra - US-NUEVA-16

| ID | Historia | Escenario | Precondiciones | Datos de entrada | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| BB-16-01 | US-NUEVA-16 | Periodo diario valido | Empresa autenticada | 2026-05-04 | Generar | HTTP 200/resumen | Coincide | APROBADA | Controller |
| BB-16-02 | US-NUEVA-16 | Semana valida | Empresa autenticada | 04 al 10 mayo | Generar | HTTP 200 | Coincide | APROBADA | Controller |
| BB-16-03 | US-NUEVA-16 | Semana de 8 dias | Empresa autenticada | 04 al 11 mayo | Generar | HTTP 422 | Coincide | APROBADA | Controller |
| BB-16-04 | US-NUEVA-16 | Mes incompleto | Empresa autenticada | 02 al 31 mayo | Generar | HTTP 422 | Coincide | APROBADA | Controller |
| BB-16-05 | US-NUEVA-16 | Fecha ambigua | Empresa autenticada | 31/invalid | Generar | Rechazo | Coincide despues de fix | APROBADA | DEF-16-02 |
| BB-16-06 | US-NUEVA-16 | Periodo sin asistencias | Empresa autenticada | 2030-01-01 | Generar | Totales cero | Coincide | APROBADA | Controller |
| BB-16-07 | US-NUEVA-16 | Mes ya cerrado | Informe existente | Mayo 2026 | Cerrar otra vez | HTTP 409 | Coincide | APROBADA | Controller |
| BB-16-08 | US-NUEVA-16 | Descarga valida | Informe cerrado | ID valido | Descargar | PDF valido | Coincide | APROBADA | Controller/PDF |
| BB-16-09 | US-NUEVA-16 | Informe inexistente | Empresa autenticada | ID 999999 | Descargar | HTTP 404 | Coincide | APROBADA | Controller |
| BB-16-10 | US-NUEVA-16 | Usuario sin permiso | Empleado autenticado | GET historial | Consultar | HTTP 403 | Coincide | APROBADA | Controller |
