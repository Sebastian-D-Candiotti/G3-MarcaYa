# Defectos - US-NUEVA-15

## DEF-15-01 - Dobles de repositorio no resolvian entidades

- Historia de usuario: US-NUEVA-15.
- Modulo: pruebas del caso de uso de sincronizacion.
- Descripcion: los metodos singleton del fake evaluaban `empleado`, `parada` y `asignacion` sobre el objeto fake y lanzaban `NameError`.
- Severidad: Baja (defecto del arnes, no del producto).
- Causa raiz: cierre sin capturar previamente la entidad del test.
- Accion correctiva: capturar cada entidad en una variable local antes de definir el metodo singleton.
- Prueba de regresion: `sincronizar_marcaciones_offline_test.rb`.
- Responsable: Jose Fabrizzio Bustillos Rivera.
- Estado final: Corregido.
- Evidencia: 8 pruebas Rails, 34 aserciones, cero errores.

| ID | Historia | Defecto | Severidad | Causa raiz | Accion correctiva | Prueba de regresion | Resultado final | Evidencia |
|---|---|---|---|---|---|---|---|---|
| DEF-15-01 | US-NUEVA-15 | NameError en repositorios fake | Baja | Cierre evaluado sobre fake | Captura local | Caso de uso offline | CORREGIDO | 8/8 |
| DEF-QA-02 | Solicitudes | Regresion completa conserva 2 errores | Media | Fake incompleto y regla inconsistente | Resolver en rama propietaria | Suite Rails | PENDIENTE | 383 runs, 2 errors |
