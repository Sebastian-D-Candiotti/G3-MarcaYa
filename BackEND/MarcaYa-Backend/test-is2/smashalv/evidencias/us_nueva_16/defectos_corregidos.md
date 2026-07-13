# Defectos - US-NUEVA-16

## DEF-16-01 - Informe cerrado podia modificarse

- Severidad: Alta.
- Causa raiz: el callback consultaba `estado_was`; en Rails 8 no bloqueo el cambio de `CERRADO` a `BORRADOR` en esta ejecucion.
- Accion correctiva: consultar `attribute_in_database("estado")` en update y destroy.
- Prueba de regresion: `informe_asistencia_record_test.rb`.
- Estado final: Corregido; update y destroy son rechazados.

## DEF-16-02 - Fecha ambigua aceptada

- Severidad: Media.
- Causa raiz: `Date.parse` acepta formatos parciales/ambiguos.
- Accion correctiva: usar `Date.iso8601` y conservar error de dominio para formato invalido.
- Prueba de regresion: `base_test.rb`.
- Estado final: Corregido.

## DEF-16-03 - Esquema desincronizado con migraciones

- Severidad: Alta.
- Causa raiz: `schema.rb` marcaba migraciones como aplicadas, pero omitia columnas de verificacion, `otp_verificado`, `device_id` y tabla `devices`.
- Accion correctiva: reaplicar migraciones existentes sobre base test y regenerar el esquema.
- Prueba de regresion: bateria Rails US-16 y suite completa.
- Estado final: Corregido para carga por esquema; los errores de esquema bajaron a cero.

| ID | Historia | Defecto | Severidad | Causa raiz | Accion correctiva | Prueba de regresion | Resultado final | Evidencia |
|---|---|---|---|---|---|---|---|---|
| DEF-16-01 | US-NUEVA-16 | Informe cerrado mutable | Alta | Dirty tracking inadecuado | Estado persistido | ORM test | CORREGIDO | 18/18 focalizadas |
| DEF-16-02 | US-NUEVA-16 | Fecha ambigua aceptada | Media | `Date.parse` flexible | `Date.iso8601` | Base test | CORREGIDO | 64 aserciones |
| DEF-16-03 | Transversal | Schema omitia objetos migrados | Alta | Dump fuera de sincronizacion | Regenerar objetos faltantes | Suite Rails | CORREGIDO | 35 a 13 incidencias, ninguna de schema |
| DEF-QA-03 | Transversal | Migraciones no reconstruyen DB vacia | Alta | Migracion usa `solicitudes` antes de su creacion | Ordenar/agregar migracion base en rama propietaria | Migracion desde cero | PENDIENTE | PG::UndefinedTable reproducido |
| DEF-QA-04 | Flutter transversal | Tests esperan localhost pero ApiService usa Render | Media | URL base no inyectada en suite heredada | Inyectar baseUrl en todos los tests | Suite Flutter | PENDIENTE | 16 fallos |
