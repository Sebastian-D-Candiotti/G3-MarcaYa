# Tasks: Notificaciones Push de Asistencia

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 650–800 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1: Foundation → PR 2: Backend Wiring → PR 3: Frontend |
| Delivery strategy | ask-on-risk |
| Chain strategy | feature-branch-chain |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Backend domain + ports + infrastructure | PR 1 | Base = feature/tracker branch; migration, VO, ports, DeviceRecord, ArDispositivoRepo, FcmSender, serializer, DI |
| 2 | Backend wiring: job, controller, facade, routes | PR 2 | Base = PR 1 branch; SendPushJob, DispositivosController, Facade enqueue, routes |
| 3 | Frontend: Flutter push integration | PR 3 | Base = PR 2 branch; PushProvider, main.dart init, router deep link, api_service, Firebase configs, .env |

## Phase 1: Foundation (Domain → Ports → Infrastructure)

- [x] 1.1 RED: Write failing test for `NotificacionPush` VO validation and format
- [x] 1.2 GREEN: Create `app/domain/value_objects/notificacion_push.rb`
- [x] 1.3 RED: Write failing tests for port contracts (`IPushSender`, `IDispositivoRepository`)
- [x] 1.4 GREEN: Create both ports in `app/ports/driven/`
- [x] 1.5 Create migration `db/migrate/XXX_create_devices.rb` (user_id, fcm_token, platform)
- [x] 1.6 Create `app/infrastructure/orm/device_record.rb`
- [x] 1.7 RED: Write failing test for `ArDispositivoRepository` CRUD
- [x] 1.8 GREEN: Implement `app/infrastructure/repositories/ar_dispositivo_repository.rb`
- [x] 1.9 RED: Write failing test for `FcmSender` HTTP calls
- [x] 1.10 GREEN: Implement `app/infrastructure/services/fcm_sender.rb`
- [x] 1.11 Create `app/serializers/notificacion_push_serializer.rb`
- [x] 1.12 Update `config/initializers/dependency_injection.rb` — register device_repo + fcm_sender

## Phase 2: Backend Wiring (Application + Controllers)

- [x] 2.1 RED: Write failing test for `SendPushNotificationJob` with mock repos
- [x] 2.2 GREEN: Implement `app/jobs/send_push_notification_job.rb`
- [x] 2.3 RED: Write failing test for `DispositivosController` (register, update, 401)
- [x] 2.4 GREEN: Create `app/controllers/api/v1/dispositivos_controller.rb`
- [x] 2.5 Modify `config/routes.rb` — add `POST dispositivo/registrar`
- [x] 2.6 Modify `AsistenciaFacade` — enqueue `SendPushNotificationJob` post-marcación
- [x] 2.7 RED: Write integration test for facade triggering push enqueue

## Phase 3: Frontend (Flutter)

- [x] 3.1 Add Firebase packages to `FrontEND/MarcaYa/pubspec.yaml`
- [x] 3.2 Add `registrarDispositivo(token, platform)` to `lib/src/api_service.dart`
- [x] 3.3 RED: Write failing test for `PushProvider` init and token registration
- [x] 3.4 GREEN: Create `lib/providers/push_provider.dart`
- [x] 3.5 Modify `lib/main.dart` — Firebase init, add PushProvider
- [x] 3.6 Modify `lib/router/app_router.dart` — add `/empleado/historial` route + deep link handling
- [x] 3.7 Run `flutterfire configure` — setup android/ios Firebase configs
- [x] 3.8 Add `FCM_SERVER_KEY` to `.env`
