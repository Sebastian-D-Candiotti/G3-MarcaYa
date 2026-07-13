# Pruebas de caja negra - US-NUEVA-15

| ID | Historia | Escenario | Precondiciones | Datos de entrada | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| BB-15-01 | US-NUEVA-15 | Marcacion sin internet | Conectividad false | Entrada valida | Marcar | Mensaje pendiente y fila local | Coincide | APROBADA | Provider + SQLite |
| BB-15-02 | US-NUEVA-15 | Recuperar internet | Pendientes locales | Lote valido | Emitir online | Sincroniza y limpia | Coincide | APROBADA | Provider |
| BB-15-03 | US-NUEVA-15 | Exito parcial | Tres pendientes | Aceptada, duplicada, fallida | Sincronizar | Conserva fallida | Coincide | APROBADA | Provider |
| BB-15-04 | US-NUEVA-15 | Error HTTP 500 | Pendientes locales | Respuesta 500 | Sincronizar | No elimina | Coincide | APROBADA | Provider |
| BB-15-05 | US-NUEVA-15 | Reintento | ID ya persistido | Mismo lote | Enviar otra vez | Sin duplicar | Coincide | APROBADA | API/PostgreSQL |
| BB-15-06 | US-NUEVA-15 | Hora original | Marcada antes de sync | ISO8601 antiguo | Enviar lote | Guarda hora fisica | Coincide | APROBADA | API/PostgreSQL |
| BB-15-07 | US-NUEVA-15 | Reconexiones repetidas | Sync en curso | Dos eventos | Sincronizar | Una solicitud | Coincide | APROBADA | Provider |
| BB-15-08 | US-NUEVA-15 | Almacenamiento vacio | Sin pendientes | Evento online | Sincronizar | No llama backend | Coincide | APROBADA | Provider |
