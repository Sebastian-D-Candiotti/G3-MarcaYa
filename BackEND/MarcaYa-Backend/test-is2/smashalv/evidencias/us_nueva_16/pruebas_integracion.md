# Pruebas de integracion - US-NUEVA-16

| ID | Historia | Componentes integrados | Precondicion | Datos | Flujo ejecutado | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|---|---|---|---|
| IT-16-01 | US-NUEVA-16 | Controller, snapshot, ORM y DB | Empresa autenticada | Asistencias mayo | Generar preview | Resumen sin persistir | Coincide | APROBADA |
| IT-16-02 | US-NUEVA-16 | Controller, cierre y DB | Mes abierto | Mayo 2026 | Cerrar mes | Snapshot CERRADO | Coincide | APROBADA |
| IT-16-03 | US-NUEVA-16 | Historial y PDF | Informe cerrado | ID valido | Listar/descargar | Item y application/pdf | Coincide | APROBADA |
| IT-16-04 | US-NUEVA-16 | Snapshot y asistencias | Informe cerrado | Nueva asistencia posterior | Consultar informe | Snapshot no cambia | Coincide | APROBADA |
| IT-16-05 | US-NUEVA-16 | Autorizacion | Usuario empleado | GET informes | Acceso negado | HTTP 403 | APROBADA |
| IT-16-06 | US-NUEVA-16 | Endpoint PDF | Empresa autenticada | ID inexistente | Descargar | HTTP 404 | HTTP 404 | APROBADA |
| IT-16-07 | US-NUEVA-16 | Rails completo | Esquema corregido | Todos los modulos | Suite completa | Sin regresion US-16 | 13 problemas ajenos | APROBADA CON OBSERVACIONES |
