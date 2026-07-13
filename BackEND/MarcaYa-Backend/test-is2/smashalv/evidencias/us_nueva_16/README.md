# QA - US-NUEVA-16 Historial de informes y PDF

Responsable funcional: Jose Fabrizzio Bustillos Rivera.
Rama: `feature/US-NUEVA-16-informes-pdf`.
Fecha de ejecucion: 2026-07-12 (America/Lima).

## Alcance confirmado

La historia esta implementada en esta rama: casos de uso de informes, modelo persistente, endpoints de vista previa/cierre/historial/PDF, servicio PDF, provider y pantalla Flutter.

Se validaron periodos diario/semanal/mensual, limites, periodos vacios, cierre unico, snapshot, inmutabilidad, autorizacion, PDF multipagina y provider Flutter.

## Entorno y resultado

- Ruby 4.0.4, Rails 8.1.3, Minitest 6.0.6.
- PostgreSQL 17.10, base aislada `MarcaYa_test_us16`.
- Flutter 3.44.0, Dart 3.12.0, `flutter_test`.
- Backend focalizado US-16: 18 pruebas, 64 aserciones, todas aprobadas.
- Backend focalizado mas regresion de sync compartida: 21 pruebas, 77 aserciones, todas aprobadas.
- Flutter focalizado: 4 pruebas aprobadas.
- Backend completo: 502 pruebas, 11 fallos y 2 errores ajenos a informes.
- Flutter completo: 53 pruebas, 37 aprobadas y 16 fallidas por URL base incoherente en tests heredados.
- Analisis Flutter: 96 observaciones heredadas; ninguna en archivos nuevos.
- Cobertura porcentual: no calculada; no existe herramienta configurada.

Se corrigieron defectos reales de inmutabilidad, fechas ambiguas y esquema desincronizado. La cadena completa de migraciones historicas no puede reconstruir una base vacia porque usa `solicitudes` antes de crearla; se documenta como pendiente transversal.
