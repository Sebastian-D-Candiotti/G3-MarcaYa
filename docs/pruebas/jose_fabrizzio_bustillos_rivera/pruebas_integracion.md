# Pruebas de integracion - US-NUEVA-10

| ID | Historia | Componentes integrados | Precondicion | Datos | Flujo ejecutado | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|---|---|---|---|
| IT-10-01 | US-NUEVA-10 | Controller, caso de uso, repositorio, PostgreSQL | Base test limpia | Registro valido | POST registro | Usuario pendiente | Respuesta y persistencia validas | APROBADA |
| IT-10-02 | US-NUEVA-10 | Endpoint Auth y base test | Usuario pendiente | Codigo valido | POST verificar | Usuario activo | Estado ACTIVO | APROBADA |
| IT-10-03 | US-NUEVA-10 | Endpoint Auth y base test | Usuario pendiente | Codigo invalido | POST verificar | No activar | Permanece pendiente | APROBADA |
| IT-10-04 | US-NUEVA-10 | Page, provider y ApiService | Router de prueba | Seis digitos | Confirmar registro | Navegar solo con ACTIVO | Comportamiento esperado | APROBADA |
| IT-10-05 | US-NUEVA-10 | Suite backend completa | Esquema sin seeds | Todos los modulos | `rails test` | Sin regresion US-10 | US-10 pasa; 2 errores en Solicitudes | APROBADA CON OBSERVACIONES |
