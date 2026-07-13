# QA - US-NUEVA-10 Verificacion de cuenta

Responsable funcional: Jose Fabrizzio Bustillos Rivera.
Rama: `feature/historia-usuario-verificacion-cuenta`.
Fecha de ejecucion: 2026-07-12 (America/Lima).

## Alcance

Se validaron el codigo numerico de seis digitos, ceros iniciales, hash, vigencia de 10 minutos, activacion unica, reenvio, manejo del mailer, provider Flutter y navegacion condicionada al estado `ACTIVO`.

## Entorno

- Backend: Ruby 4.0.4, Rails 8.1.3, Minitest 6.0.6.
- Base: PostgreSQL 17.10, base aislada `MarcaYa_test_us10`.
- Frontend: Flutter 3.44.0, Dart 3.12.0, `flutter_test`.
- Servicios externos: HTTP y correo reemplazados por fakes; no se enviaron correos reales.
- Tiempo y aleatoriedad: reloj y numero inyectados; no se uso `sleep`.

## Resultado

- Backend focalizado: 23 pruebas, 145 aserciones, 23 aprobadas.
- Controlador Auth: 10 pruebas, 63 aserciones, 10 aprobadas.
- Flutter focalizado: 11 pruebas, 11 aprobadas.
- Regresion backend: 387 pruebas, 0 fallos, 2 errores ajenos en Solicitudes.
- Regresion Flutter: 56 pruebas aprobadas.
- Analisis Flutter: 61 observaciones heredadas; ninguna en los archivos nuevos.
- Cobertura porcentual: no calculada; el repositorio no configura una herramienta de cobertura.

Los detalles estan en los documentos de esta carpeta y en `evidencias/README.md`.
