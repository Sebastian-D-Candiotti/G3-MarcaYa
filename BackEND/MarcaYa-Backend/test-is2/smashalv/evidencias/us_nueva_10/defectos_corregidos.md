# Defectos - US-NUEVA-10

No se reprodujo un defecto funcional propio de US-NUEVA-10. Los cambios productivos agregados (`clock`, numero aleatorio y `ApiService` inyectables) son puntos de prueba con valores por defecto equivalentes a produccion.

| ID | Historia | Defecto | Severidad | Causa raiz | Accion correctiva | Prueba de regresion | Resultado final | Evidencia |
|---|---|---|---|---|---|---|---|---|
| DEF-QA-01 | Transversal | `db:prepare` carga seeds que invalidan fixtures | Media | Una asistencia sembrada conserva empleado_id sin fixture padre | Ejecutar QA con base aislada y `db:schema:load` sin seeds | Suite completa repetida | PENDIENTE en configuracion; medicion QA aislada | 387 pruebas, solo 2 errores de Solicitudes |
| DEF-QA-02 | Solicitudes | Dos pruebas de regresion fallan fuera de US-10 | Media | Fake incompleto y regla de pertenencia inconsistente | Requiere correccion en rama propietaria | Suite completa Rails | PENDIENTE | 2 errores, 0 fallos |
