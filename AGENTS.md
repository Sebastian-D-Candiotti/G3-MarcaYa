# MarcaYA - Instrucciones para Codex

## Contexto del proyecto
MarcaYA es una aplicación de marcación de asistencia con backend en Ruby on Rails bajo arquitectura hexagonal y frontend en Flutter usando Provider y GoRouter.

## Reglas generales
- Antes de modificar código, inspecciona la estructura real del repositorio.
- No cambies funcionalidades de otros programadores salvo que sea necesario para integrar mi historia de usuario.
- Mantén separación clara entre dominio, casos de uso, infraestructura, controladores/API y UI.
- Todo cambio debe incluir pruebas o una explicación clara de cómo probarlo manualmente.
- Si falta información del proyecto, deja supuestos explícitos antes de implementar.
- No hardcodees credenciales, tokens, correos SMTP ni URLs sensibles.
- Usa variables de entorno para servicios externos.
- Al finalizar, entrega:
  1. Archivos creados/modificados.
  2. Endpoints o pantallas agregadas.
  3. Cambios en base de datos.
  4. Pruebas realizadas.
  5. Resumen técnico para Sebastián.

## Arquitectura esperada
Backend:
- Rails
- Arquitectura hexagonal
- Controladores API
- Casos de uso
- Entidades/modelos
- Repositorios/adaptadores
- Servicios externos

Frontend:
- Flutter
- Provider para estado
- GoRouter para navegación
- Separación entre pages, widgets, providers, services y models

## Comandos esperados
Backend:
- bundle install
- rails db:migrate
- rails test o rspec

Frontend:
- flutter pub get
- flutter analyze
- flutter test
