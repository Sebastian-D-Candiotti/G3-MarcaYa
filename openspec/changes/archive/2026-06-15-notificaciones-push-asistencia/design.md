# Design: Notificaciones Push de Asistencia

## Technical Approach

Encolar un job asincrónico (Solid Queue) desde `AsistenciaFacade` después de cada marcación exitosa. El job consulta los FCM tokens del empleado usando un nuevo repositorio `IDispositivoRepository` y envía la notificación vía HTTP a Firebase Cloud Messaging. El frontend Flutter registra el token al login y maneja deep linking al historial.

Se siguen los patrones existentes del proyecto: puertos driven con class methods, value objects en `Domain::ValueObjects`, ORM records en `Infrastructure::Orm`, y test con mocks via `define_singleton_method`.

## Architecture Decisions

### Decision: Dónde encolar el push

| Option | Tradeoff | Decision |
|--------|----------|----------|
| En el use case (`MarcarEntrada`) | Acopla notificación al dominio | ❌ |
| En la facade (`AsistenciaFacade`) | Facade ya orquesta; separa responsabilidades | ✅ |
| En el controller | Controller engorda; difícil de testear | ❌ |

**Rationale**: La facade es el orquestador natural — el use case se mantiene puro (solo validación + persistencia), y la facade agrega el cross-cutting concern del push post-marcación.

### Decision: Puerto driven vs domain port

| Option | Rationale | Decision |
|--------|-----------|----------|
| `app/ports/driven/` | Sigue el patrón de `IAsistenciaRepository` | ✅ |
| `app/domain/ports/` | Patrón de `InotificadorEmail` pero usa `include` | ❌ |

**Rationale**: El proposal define `IPushSender` en driven, y el resto de repositorios siguen el patrón de class methods con `NotImplementedError`.

### Decision: Value object `NotificacionPush` en dominio

Sigue el patrón de `CoordenadaGps` y `TipoMarcacion` — validación en constructor, representación inmutable del mensaje.

### Decision: Job único por notificación

Un `SendPushNotificationJob` por marcación. Solid Queue reintenta automáticamente si FCM falla, sin bloquear el HTTP 201.

## Data Flow

```
POST /api/v1/asistencia/marcar-entrada
  → AsistenciasController#marcar_entrada
    → AsistenciaFacade#marcar_entrada
      → MarcarEntrada#ejecutar (valida, guarda, retorna registro)
      → SendPushNotificationJob.perform_later(empleado_id, marcacion_id)
        → ArDispositivoRepository#activos_por_empleado(empleado_id)
          → [DeviceRecord, ...]
        → FcmSender#enviar(notificacion, token)
          → POST https://fcm.googleapis.com/fcm/send
  ← HTTP 201 (el push va async)
```

```
Flutter:
  Login → PushProvider registra FCM token
    → POST /api/v1/dispositivos/registrar
  Push recibido en foreground → flutter_local_notifications muestra alerta local
  Push recibido en background → Firebase maneja, tap abre app
  Tap → data.screen = "historial" → GoRouter.go('/empleado/historial')
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `db/migrate/XXX_create_devices.rb` | Create | Tabla devices (user_id, fcm_token, platform) |
| `app/domain/value_objects/notificacion_push.rb` | Create | VO con title, body, data payload |
| `app/ports/driven/i_push_sender.rb` | Create | Puerto `IPushSender#enviar(notificacion, token)` |
| `app/ports/driven/i_dispositivo_repository.rb` | Create | Puerto `IDispositivoRepository` para tokens |
| `app/infrastructure/orm/device_record.rb` | Create | AR record para devices |
| `app/infrastructure/repositories/ar_dispositivo_repository.rb` | Create | Repositorio concreto de dispositivos |
| `app/infrastructure/services/fcm_sender.rb` | Create | Adapter FCM HTTP API |
| `app/jobs/send_push_notification_job.rb` | Create | Job que consulta tokens y envía push |
| `app/controllers/api/v1/dispositivos_controller.rb` | Create | Endpoint `POST /registrar` |
| `app/serializers/notificacion_push_serializer.rb` | Create | Formatea notificación para FCM |
| `app/application/facades/asistencia_facade.rb` | Modify | Encola `SendPushNotificationJob` post-marcación |
| `config/routes.rb` | Modify | Ruta `POST dispositivo/registrar` |
| `config/initializers/dependency_injection.rb` | Modify | DI: device_repo + fcm_sender en container |
| `.env` | Modify | Agregar `FCM_SERVER_KEY` |
| `FrontEND/MarcaYa/pubspec.yaml` | Modify | Dependencias firebase |
| `FrontEND/MarcaYa/lib/main.dart` | Modify | Firebase init + PushProvider |
| `FrontEND/MarcaYa/lib/providers/push_provider.dart` | Create | Provider: init, register token, handle msgs |
| `FrontEND/MarcaYa/lib/router/app_router.dart` | Modify | Ruta `/empleado/historial` + deep link handling |
| `FrontEND/MarcaYa/lib/src/api_service.dart` | Modify | Método `registrarDispositivo(token, platform)` |
| `FrontEND/MarcaYa/android/` | Modify | google-services.json via FlutterFire CLI |
| `FrontEND/MarcaYa/ios/` | Modify | GoogleService-Info.plist via FlutterFire CLI |

## Interfaces / Contracts

```ruby
# app/ports/driven/i_push_sender.rb
module Ports::Driven::IPushSender
  def self.enviar(notificacion, fcm_token)
    raise NotImplementedError
  end
end

# app/domain/value_objects/notificacion_push.rb
class Domain::ValueObjects::NotificacionPush
  attr_reader :title, :body, :data
  # data: { type: "asistencia", screen: "historial", marcacion_id: "123" }
end

# app/ports/driven/i_dispositivo_repository.rb
module Ports::Driven::IDispositivoRepository
  def self.activos_por_empleado(empleado_id)
    raise NotImplementedError
  end
  def self.crear_o_actualizar(user_id:, fcm_token:, platform:)
    raise NotImplementedError
  end
end

# Job contract
class SendPushNotificationJob < ApplicationJob
  queue_as :push_notifications
  def perform(empleado_id, marcacion_id)
    # 1. Obtener tokens activos del empleado via IDispositivoRepository
    # 2. Construir NotificacionPush desde el registro de asistencia
    # 3. IPushSender.enviar(notificacion, token) por cada token
  end
end
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit (VO) | `NotificacionPush` validación y formato | Minitest directo |
| Unit (port mock) | `FcmSender` con HTTP stubs | `Net::HTTP` stubs, fixture responses |
| Unit (job) | `SendPushNotificationJob` con repos mock | Mock repos con `define_singleton_method` |
| Unit (repo) | `ArDispositivoRepository` con DB | Rails test, fixtures `devices` |
| Controller | `DispositivosController` create/update/auth | Rails integration test, JWT header |
| Integration | `AsistenciaFacade` + push job enqueued | Mock job assertions after facade#marcar_entrada |
| Flutter unit | `PushProvider` init and token reg | Mock `FirebaseMessaging`, verify ApiService called |
| Flutter widget | Deep link navigation | `pushReplacement` verification |

## Migration / Rollout

No migration required for existing data — tabla `devices` es nueva. Agregar `FCM_SERVER_KEY` al `.env` y al entorno de producción (Kamal secrets). Ejecutar `flutterfire configure` para regenerar configs de platform.

## Open Questions

- [ ] ¿Usar FCM HTTP v1 (OAuth2) o legacy HTTP API (Server Key)? La legacy es más simple pero deprecated. Decisión: legacy por simplicidad inicial, migrar a v1 post-MVP.
- [ ] ¿El empleado puede tener múltiples dispositivos (tablet + phone)? El diseño soporta múltiples tokens por empleado.
