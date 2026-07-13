# Pruebas de integracion - US-NUEVA-15

| ID | Historia | Componentes integrados | Precondicion | Datos | Flujo ejecutado | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|---|---|---|---|
| IT-15-01 | US-NUEVA-15 | Modelo local, repositorio, SQLite | DB temporal vacia | Marcacion completa | Guardar/consultar | Pendiente con hora original | Coincide | APROBADA |
| IT-15-02 | US-NUEVA-15 | Provider, repo y ApiService | Tres pendientes | Dos aceptadas, una fallida | Sincronizar lote | Limpieza selectiva | Coincide | APROBADA |
| IT-15-03 | US-NUEVA-15 | Controller, caso de uso y PostgreSQL | Empleado autenticado | Lote valido | POST sincronizar | Persistencia original | Coincide | APROBADA |
| IT-15-04 | US-NUEVA-15 | Endpoint y restriccion unica | Marcacion ya procesada | Mismo ID | Reintentar | Duplicado sin segunda fila | Coincide | APROBADA |
| IT-15-05 | US-NUEVA-15 | Endpoint y lote parcial | Un item valido y uno incompleto | Lote mixto | POST sincronizar | 207 con detalle | Coincide | APROBADA |
| IT-15-06 | US-NUEVA-15 | Suite completa | Esquema test sin seeds | Todos los modulos | Rails/Flutter test | Sin regresion de US-15 | US-15 pasa | APROBADA CON OBSERVACIONES |
