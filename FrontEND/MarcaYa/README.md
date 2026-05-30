# MarcaYA

Prototipo Flutter MVP para digitalizar el registro de asistencia laboral con validacion GPS en tiempo real.

## Arquitectura

El proyecto sigue Clean Architecture con tres capas en `lib/`:

```
lib/
  core/           → infraestructura compartida
    constants/    → constantes de la app
    network/      → ApiClient (HTTP, JWT)
    router/       → AppRouter (GoRouter)
    theme/        → AppColors, estilos globales
  domain/         → reglas de negocio (sin dependencias externas)
    entities/     → AppUser
    repositories/ → AuthRepository (interfaz)
    usecases/     → lógica de negocio reutilizable (creciente)
  data/           → implementación de repositorios
    datasources/  → AuthRemoteDataSource (HTTP real)
    models/       → DTOs para parseo JSON
    repositories/ → AuthRepositoryImpl
  pages/          → pantallas, cada una con su carpeta
    */components/ → widgets propios de esa pantalla
  providers/      → ChangeNotifiers (Estado global)
  components/     → widgets compartidos (BottomNavbar, etc.)
  src/            → legado por migrar (app_state.dart monolitico)
```

### Principios

- **Dependencias hacia adentro**: `domain/` no importa `data/`, `core/`, ni Flutter.
- **Repositorios como interfaz**: `domain/repositories/` define el contrato; `data/repositories/` lo implementa.
- **Inversión de dependencias**: `providers/` programa contra la interfaz, no contra la implementación concreta.
- **Migración progresiva**: `src/app_state.dart` (monolito ~775 líneas) se extrae de a poco hacia `domain/` y `data/`.

## Credenciales demo

- Empleado: `empleado@marcapp.pe` / `123456`
- Empresa/Admin: `admin@marcapp.pe` / `123456`

## Flujos incluidos

- Inicio de sesion por rol.
- Marcacion de entrada y salida con GPS simulado: dentro de zona, fuera de zona y sin GPS.
- Historial personal del empleado con fecha, hora, parada y estado GPS.
- Perfil de empresa y solicitud de ingreso a obra.
- Panel administrativo con indicadores y marcaciones recientes.
- Gestion de paradas de obra: crear, editar radio y eliminar con validacion de uso.
- Solicitudes de empleados: aceptar o rechazar.
- Reportes de asistencia y cronograma de pagos simulado.

## Comandos

```bash
flutter analyze
flutter test
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5174
```

## Nota de entorno

Para compilar APK Android en esta maquina falta instalar Android Studio/Android SDK y configurar `flutter config --android-sdk`.
