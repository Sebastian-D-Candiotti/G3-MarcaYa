# MarcAPP

Prototipo Flutter MVP para digitalizar el registro de asistencia laboral con validacion GPS en tiempo real.

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

Si Flutter no esta en el PATH, usa el SDK instalado en `C:\Users\fabri\flutter-sdk`:

```powershell
C:\Users\fabri\flutter-sdk\bin\flutter.bat doctor
C:\Users\fabri\flutter-sdk\bin\flutter.bat analyze
C:\Users\fabri\flutter-sdk\bin\flutter.bat test
C:\Users\fabri\flutter-sdk\bin\flutter.bat run -d web-server --web-hostname 127.0.0.1 --web-port 5174
```

## Nota de entorno

Para compilar APK Android en esta maquina falta instalar Android Studio/Android SDK y configurar `flutter config --android-sdk`.
