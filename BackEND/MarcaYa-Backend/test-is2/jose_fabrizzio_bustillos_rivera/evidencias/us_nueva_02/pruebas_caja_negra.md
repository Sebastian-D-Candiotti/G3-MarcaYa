# Pruebas de caja negra - US-NUEVA-02

| ID | Historia | Escenario | Precondiciones | Datos de entrada | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| BB-02-01 | US-NUEVA-02 | Justificacion valida | Feature desplegada | Tardanza + PDF | Registrar | PENDIENTE | No ejecutado | NO EJECUTADA | Implementacion ausente |
| BB-02-02 | US-NUEVA-02 | Motivo vacio | Feature desplegada | Motivo vacio | Registrar | Validacion | No ejecutado | NO EJECUTADA | Implementacion ausente |
| BB-02-03 | US-NUEVA-02 | Archivo invalido/grande | Feature desplegada | EXE o limite excedido | Adjuntar | Rechazo | No ejecutado | NO EJECUTADA | Implementacion ausente |
| BB-02-04 | US-NUEVA-02 | Aprobacion valida | Pendiente y revisor | ID | Aprobar | JUSTIFICADO y recalculo | No ejecutado | NO EJECUTADA | Implementacion ausente |
| BB-02-05 | US-NUEVA-02 | Rechazo valido | Pendiente y revisor | Comentario | Rechazar | RECHAZADA sin recalculo | No ejecutado | NO EJECUTADA | Implementacion ausente |
| BB-02-06 | US-NUEVA-02 | Usuario sin permisos | Usuario empleado | ID ajeno | Aprobar | 403 | No ejecutado | NO EJECUTADA | Implementacion ausente |
