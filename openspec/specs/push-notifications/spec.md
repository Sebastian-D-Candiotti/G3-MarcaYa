# Push Notifications — Specification

## Purpose

Transactional push notifications via Firebase Cloud Messaging for attendance marking. Covers device registration, push triggering after marking, notification formatting, deep link navigation, and fault tolerance.

## Requirements

### REQ-01: Device Token Registration

The system MUST provide an authenticated endpoint for employees to register or update their FCM device token.

#### Scenario: First-time registration

- GIVEN an authenticated employee with a valid FCM token
- WHEN they POST to `/api/v1/dispositivos/registrar`
- THEN token is stored and responds HTTP 201

#### Scenario: Token update

- GIVEN an employee with a previously registered token
- WHEN they POST a new token
- THEN record is updated and responds HTTP 200

#### Scenario: Unauthenticated

- GIVEN an unauthenticated request
- WHEN POST to `/api/v1/dispositivos/registrar`
- THEN server responds HTTP 401

### REQ-02: Push After Successful Marking

The system MUST enqueue a push notification for the employee after a successful attendance marking.

#### Scenario: Entry triggers push

- GIVEN an employee completed entry marking (HTTP 201)
- WHEN the marking is persisted
- THEN `SendPushNotificationJob` is enqueued with marking details

#### Scenario: Exit triggers push

- GIVEN an employee completed exit marking (HTTP 201)
- WHEN the marking is persisted
- THEN `SendPushNotificationJob` is enqueued with marking details

#### Scenario: Failed marking

- GIVEN a marking was rejected (HTTP 422)
- WHEN no record was persisted
- THEN no push job is enqueued

### REQ-03: Notification Content Format

The push MUST have a fixed title, body with time/type/geo validity, and data for routing.

| Body template | When |
|---------------|------|
| `Entrada — {hora} hs | Ubicación válida` | Entry inside geofence |
| `Entrada — {hora} hs | Fuera del área permitida` | Entry outside geofence |
| `Salida — {hora} hs | Ubicación válida` | Exit inside geofence |
| `Salida — {hora} hs | Fuera del área permitida` | Exit outside geofence |

Data payload MUST include `type: asistencia`, `screen: historial`, and `marcacion_id`.

### REQ-04: Deep Link Navigation

Tapping the notification MUST navigate the employee to their attendance history screen.

#### Scenario: Background → tap

- GIVEN the app is in background
- WHEN user taps the notification
- THEN app navigates to history screen

#### Scenario: Killed (cold start)

- GIVEN the app was terminated
- WHEN user taps the notification on cold launch
- THEN app launches and navigates to history screen

#### Scenario: Foreground

- GIVEN the app is in foreground
- WHEN a push arrives
- THEN `flutter_local_notifications` shows it locally
- AND tapping navigates to history screen

### REQ-05: Fault Tolerance

Push failure MUST NOT roll back a successful marking (HTTP 201 already sent).

#### Scenario: FCM unavailable

- GIVEN FCM is temporarily down
- WHEN `SendPushNotificationJob` fails
- THEN Solid Queue retries the job
- AND the marking remains recorded

#### Scenario: Invalid token

- GIVEN employee's FCM token is expired
- WHEN `SendPushNotificationJob` receives an error
- THEN the job SHOULD mark the token for cleanup
- AND the marking remains recorded

### REQ-06: Foreground Local Notification

The app MUST display a local notification when a push payload arrives while in foreground.

#### Scenario: Foreground push received

- GIVEN the app is in foreground
- WHEN a push payload arrives via Firebase
- THEN `flutter_local_notifications` shows it
- AND tapping navigates to history screen
