# Pruebas unitarias - US-NUEVA-15

| ID | Historia | Componente aislado | Escenario | Dependencias simuladas | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|---|---|---|
| UT-15-01 | US-NUEVA-15 | ConnectivityService | Inicio offline | Checker fake | `false` sin red real | `false` | APROBADA |
| UT-15-02 | US-NUEVA-15 | ConnectivityService | Offline a online y duplicados | Stream controlado | Solo cambios distintos | Coincide | APROBADA |
| UT-15-03 | US-NUEVA-15 | AsistenciaOfflineProvider | Marcar offline | Repo en memoria, HTTP fake | Guarda hora original y aumenta contador | Coincide | APROBADA |
| UT-15-04 | US-NUEVA-15 | AsistenciaOfflineProvider | Respuesta parcial | Repo y HTTP fake | Elimina sincronizados/duplicados | Coincide | APROBADA |
| UT-15-05 | US-NUEVA-15 | AsistenciaOfflineProvider | HTTP 500 | HTTP fake | Conserva todos | Coincide | APROBADA |
| UT-15-06 | US-NUEVA-15 | AsistenciaOfflineProvider | Dos sync concurrentes | HTTP bloqueable | Una solicitud | Coincide | APROBADA |
| UT-15-07 | US-NUEVA-15 | SincronizarMarcacionesOffline | Lote valido/parcial | Repositorios fake | Procesa validos y detalla fallidos | Coincide | APROBADA |
| UT-15-08 | US-NUEVA-15 | SincronizarMarcacionesOffline | Timestamp no ISO | Repositorios fake | Registro fallido | Coincide | APROBADA |
