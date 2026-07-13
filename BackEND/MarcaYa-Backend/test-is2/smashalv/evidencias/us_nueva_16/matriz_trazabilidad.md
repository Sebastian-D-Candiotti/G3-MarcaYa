# Matriz de trazabilidad - US-NUEVA-16

| ID | Semana | Historia | Criterio de aceptacion | Tipo de prueba | Archivo de prueba | Caso ejecutado | Estado | Evidencia |
|---|---:|---|---|---|---|---|---|---|
| TR-16-01 | 4 | US-NUEVA-16 | Agrupacion diaria | Unitaria/API | `base_test.rb`, controller test | Un dia exacto | APROBADA | 18/18 Rails |
| TR-16-02 | 4 | US-NUEVA-16 | Agrupacion semanal | Unitaria/API | `base_test.rb`, controller test | 7 dias acepta, 8 rechaza | APROBADA | Limite validado |
| TR-16-03 | 4 | US-NUEVA-16 | Agrupacion mensual | Unitaria/API | `base_test.rb`, controller test | Mes calendario exacto | APROBADA | Limite validado |
| TR-16-04 | 4 | US-NUEVA-16 | Periodo sin registros | Integracion API | controller test | Fecha sin asistencias | APROBADA | Resumen cero |
| TR-16-05 | 4 | US-NUEVA-16 | Snapshot mensual | Integracion API | controller test | Cerrar mayo | APROBADA | Persistencia CERRADO |
| TR-16-06 | 4 | US-NUEVA-16 | Informe cerrado inmutable | Regresion modelo/API | `informe_asistencia_record_test.rb` | Actualizar/eliminar cerrado | APROBADA | DEF-16-01 |
| TR-16-07 | 4 | US-NUEVA-16 | Doble cierre bloqueado | Integracion API | controller test | Cerrar mismo mes dos veces | APROBADA | HTTP 409 |
| TR-16-08 | 4 | US-NUEVA-16 | PDF valido y multipagina | Unitaria/API | PDF service/controller | UTF-16, EOF, varias paginas | APROBADA | 2 tests PDF |
| TR-16-09 | 4 | US-NUEVA-16 | Autorizacion por rol/empresa | Integracion API | controller test | Empleado intenta acceder | APROBADA | HTTP 403 |
| TR-16-10 | 4 | US-NUEVA-16 | Provider maneja historial/error/PDF/cierre | Unitaria Flutter | `informes_asistencia_provider_test.dart` | Cuatro flujos | APROBADA | 4/4 Flutter |
