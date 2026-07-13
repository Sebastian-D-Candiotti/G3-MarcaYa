# Matriz de trazabilidad - US-NUEVA-15

| ID | Semana | Historia | Criterio de aceptacion | Tipo de prueba | Archivo de prueba | Caso ejecutado | Estado | Evidencia |
|---|---:|---|---|---|---|---|---|---|
| TR-15-01 | 2 | US-NUEVA-15 | Detectar perdida y recuperacion | Unitaria Flutter | `test/connectivity_service_test.dart` | Offline inicial y transicion online | APROBADA | 2/2 |
| TR-15-02 | 2 | US-NUEVA-15 | Guardar localmente | Integracion SQLite | `test/marcacion_pendiente_repository_test.dart` | Insertar y consultar pendiente | APROBADA | 5/5 |
| TR-15-03 | 2 | US-NUEVA-15 | Conservar hora real | Unitaria e integracion | Repositorio local y caso de uso Rails | Timestamp original | APROBADA | Rails y Flutter |
| TR-15-04 | 2 | US-NUEVA-15 | Estado pendiente | Integracion SQLite | `test/marcacion_pendiente_repository_test.dart` | Estado persistido | APROBADA | SQLite de memoria |
| TR-15-05 | 2 | US-NUEVA-15 | Envio en lote al reconectar | Provider | `test/asistencia_offline_provider_test.dart` | Sincronizar pendientes | APROBADA | 5/5 provider |
| TR-15-06 | 2 | US-NUEVA-15 | Limpiar solo confirmadas | Provider/SQLite | Exito parcial | APROBADA | Rechazada permanece |
| TR-15-07 | 2 | US-NUEVA-15 | Backend conserva timestamp | Integracion API | `test/controllers/api/v1/asistencias_controller_test.rb` | Persistencia original | APROBADA | PostgreSQL test |
| TR-15-08 | 2 | US-NUEVA-15 | Reintento no duplica | Integracion API | Mismo cliente_marcacion_id dos veces | APROBADA | Segundo resultado DUPLICADO |
| TR-15-09 | 2 | US-NUEVA-15 | Evitar concurrencia | Unitaria Provider | Dos sync simultaneas | APROBADA | Una solicitud HTTP |
