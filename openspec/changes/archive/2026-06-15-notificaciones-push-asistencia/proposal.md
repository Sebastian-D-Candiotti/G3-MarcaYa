# Proposal: Notificaciones Push de Asistencia

## Intent

Enviar una notificación push al empleado inmediatamente después de que se registre una marcación de entrada o salida exitosa (HTTP 201). La notificación debe mostrar tipo de marcado, hora, y si la ubicación fue geográficamente válida. Al hacer tap en la notificación, debe abrir directamente la sección de historial del empleado.

## Scope

### In Scope

- Registro de dispositivos: endpoint para que el frontend registre/actualice el FCM token del empleado
- Envío automático de push desde el backend al completar una marcación (`POST /asistencia/marcar-entrada` y `POST /asistencia/marcar-salida`)
- Payload de notificación con: tipo (Entrada/Salida), hora, validez geográfica
- Deep link: tap en notificación → navega a historial del empleado
- Arquitectura hexagonal: puerto `IPushSender`, adaptador `FcmSender`, job asincrónico con Solid Queue
- Integración Flutter con `firebase_messaging` + `flutter_local_notifications`

### Out of Scope

- Notificaciones programadas (recordatorios de marcación)
- Notificaciones a empresa/admin sobre marcaciones de empleados
- Notificaciones push para otros dominios (solicitudes, valoraciones)
- Panel de administración de dispositivos
- Soporte offline de notificaciones
- Traducción idioma del dispositivo (el texto se define fijo del lado servidor)

## Capabilities

### New Capabilities

- `push-notifications`: Envío de notificaciones push transaccionales vía Firebase Cloud Messaging, con registro de dispositivos y deep linking

### Modified Capabilities

- `attendance-marking`: El caso de uso `MarcarEntrada` / `MarcarSalida` ahora encola un job de notificación push después de guardar exitosamente

## Approach

### Flujo completo

```
Empleado marca entrada/salida
  → POST /api/v1/asistencia/marcar-entrada
  → Backend valida, guarda, responde 201
  → Backend encola SendPushNotificationJob con datos de la marcación
  → Job consulta FCM tokens activos del empleado
  → Job envía POST a FCM HTTP API
  → Flutter recibe notificación en background/foreground
  → Tap → deep link a /empleado/historial
```

### Backend

1. **Nueva migración**: `devices` (user_id, fcm_token, platform, created_at, updated_at)
2. **Nuevo dominio**: Puerto `IPushSender` en `app/ports/driven/`, entidad `NotificacionPush` (value object para el mensaje)
3. **Nuevo adaptador**: `FcmSender` en `app/infrastructure/services/` que envía a `https://fcm.googleapis.com/fcm/send`
4. **Nuevo job**: `SendPushNotificationJob` en `app/jobs/` (Solid Queue)
5. **Nuevo endpoint**: `POST /api/v1/dispositivos/registrar` para registrar/actualizar FCM token
6. **Modificación**: `AsistenciaFacade` encola el push job después de `marcar_entrada` y `marcar_salida`

### Frontend (Flutter)

1. **Dependencias nuevas**: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
2. **Inicialización**: Configurar Firebase en `main.dart`
3. **Registro de token**: En `AuthProvider` o nuevo `PushProvider`, al login solicitar permiso y registrar FCM token en backend
4. **Manejo de notificaciones**: Listener global que captura la notificación y navega a historial según el `data` payload
5. **Deep link**: Agregar ruta `/empleado/historial` en GoRouter (si no existe) y navegar con `pushReplacement` o `go`

### Formato de notificación

Título: `Asistencia marcada`

Cuerpo (varía según tipo y validez GPS):
- Entrada válida: `Entrada — 08:32 hs | Ubicación válida`
- Entrada fuera de zona: `Entrada — 08:32 hs | Fuera del área permitida`
- Salida válida: `Salida — 17:05 hs | Ubicación válida`
- Salida fuera de zona: `Salida — 17:05 hs | Fuera del área permitida`

### Payload FCM

```json
{
  "to": "<fcm_token>",
  "notification": {
    "title": "Asistencia marcada",
    "body": "Entrada — 08:32 hs | Ubicacion valida"
  },
  "data": {
    "type": "asistencia",
    "screen": "historial",
    "marcacion_id": "123"
  }
}
```

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| Backend: `app/ports/driven/` | New | `IPushSender` port |
| Backend: `app/domain/` | New | `NotificacionPush` value object |
| Backend: `app/infrastructure/services/` | New | `FcmSender` adapter |
| Backend: `app/jobs/` | New | `SendPushNotificationJob` |
| Backend: `app/application/facades/` | Modified | `AsistenciaFacade` encola job post-marcacion |
| Backend: `app/controllers/api/v1/` | New | `DispositivosController` for token registration |
| Backend: `app/models/` | New | `DeviceRecord` AR model |
| Backend: `app/infrastructure/repositories/` | New | `ArDeviceRepository` |
| Backend: `config/routes.rb` | Modified | Nueva ruta dispositivos |
| Backend: `config/initializers/` | Modified | DI para device_repo + fcm_sender |
| Backend: `db/migrate/` | New | `CreateDevices` migration |
| Backend: `.env.example` | Modified | Agregar `FCM_SERVER_KEY` |
| Frontend: `pubspec.yaml` | Modified | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| Frontend: `lib/main.dart` | Modified | Firebase initialization |
| Frontend: `lib/providers/` | New | `PushProvider` |
| Frontend: `lib/pages/` | New/Modified | Historial page + deep link handling |
| Frontend: `lib/router/` | Modified | Ruta `/empleado/historial` |
| Frontend: `android/` & `ios/` | Modified | Firebase config files |
| Frontend: `lib/core/` | Modified | `ApiService` — endpoint registrar token |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| FCM token expira (Apple los rota) | Medium | Endpoint de registro siempre sobreescribe; forzar re-registro en cada app launch |
| Notificación no llega en iOS si la app está en background sin content_available | Low | Configurar `content_available: true` en payload; usar `flutter_local_notifications` para foreground |
| El deep link no funciona si la app se abre desde frío (kill) | Medium | Manejar `onMessageOpenedApp` + `getInitialMessage` en FirebaseMessaging |
| Firebase no configurado correctamente en ambos platforms | Medium | Usar FlutterFire CLI para setup automático; documentar pasos |
| Job de push falla por timeout de red | Low | Solid Queue reintenta automáticamente; no bloquea la respuesta 201 |

## Rollback Plan

1. Remover migración `CreateDevices`
2. Remover archivos nuevos: `FcmSender`, `IPushSender`, `SendPushNotificationJob`, `DispositivosController`, `DeviceRecord`, `ArDeviceRepository`, `PushProvider`
3. Revertir cambios en `AsistenciaFacade` (quitar encolado de job)
4. Revertir cambios en `config/routes.rb` y `config/initializers/`
5. Del lado Flutter: revertir `pubspec.yaml`, `main.dart`, router
6. Remover archivos de configuración de Firebase (google-services.json, GoogleService-Info.plist)
7. Ninguna pérdida de datos — tabla devices es nueva

## Dependencies

- Proyecto Firebase creado con FCM habilitado
- Cuenta de servicio Firebase o Server Key para autenticación HTTP
- FlutterFire CLI (`flutterfire configure`) para generar configs de platform
- Solid Queue ya configurado y funcional en el proyecto
- JwtAuthenticatable concern para autenticar endpoint de registro de dispositivo
- Flujo de marcación existente (asistencia facade y use cases)

## Success Criteria

- [ ] Empleado recibe notificación push al marcar entrada exitosamente (HTTP 201)
- [ ] Empleado recibe notificación push al marcar salida exitosamente
- [ ] La notificación muestra tipo (Entrada/Salida), hora, y validez geográfica correctamente
- [ ] Si la marcación fue fuera de geocerca, la notificación lo indica
- [ ] Al hacer tap en la notificación, abre la pantalla de historial del empleado
- [ ] El registro de marcación no se bloquea si el push falla (fault tolerance)
- [ ] El FCM token se registra al login y se actualiza en cada app launch
- [ ] Las notificaciones funcionan en foreground y background
- [ ] Tests del lado backend: FcmSender, SendPushNotificationJob, DispositivosController, modificaciones en AsistenciaFacade
- [ ] Tests del lado frontend: PushProvider, manejo de notificaciones
