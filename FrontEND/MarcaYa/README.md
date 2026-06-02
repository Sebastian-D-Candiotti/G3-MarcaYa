# MarcaYA — Frontend Flutter

Aplicación Flutter para el registro de asistencia laboral con validación GPS.

## Requisitos

- Flutter 3.x
- Backend Rails corriendo en `http://localhost:3000/api/v1`

## Inicio rápido

```bash
flutter pub get
flutter run -d chrome
```

## Tests

```bash
flutter test
```

## Estructura

```
lib/
├── pages/                  → Pantallas de la app
├── providers/              → State management (Provider)
├── src/                    → ApiService, AppState, Models
└── router/                 → GoRouter config
```

Ver el `README.md` raíz del proyecto para instrucciones completas.
