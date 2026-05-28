# MarcaYA — Backend: Arquitectura Hexagonal (Rails 8)

> **Proyecto:** MarcaYA · Sistema de registro de asistencia laboral con validación GPS  
> **Stack:** Ruby on Rails 8 · PostgreSQL · JWT + bcrypt  
> **Patrón:** Arquitectura Hexagonal (Puertos y Adaptadores)

---

## Tabla de Contenidos

1. [Principios de la Arquitectura](#1-principios-de-la-arquitectura)
2. [Estructura de Carpetas Completa](#2-estructura-de-carpetas-completa)
3. [Capas y Responsabilidades](#3-capas-y-responsabilidades)
   - 3.1 [Driving Adapters (Entrada)](#31-driving-adapters--entrada)
   - 3.2 [Driving Ports (Interfaces de Entrada)](#32-driving-ports--interfaces-de-entrada)
   - 3.3 [Capa de Aplicación](#33-capa-de-aplicación)
   - 3.4 [Capa de Dominio](#34-capa-de-dominio)
   - 3.5 [Driven Ports (Interfaces de Salida)](#35-driven-ports--interfaces-de-salida)
   - 3.6 [Driven Adapters (Infraestructura)](#36-driven-adapters--infraestructura)
4. [Módulos del Sistema](#4-módulos-del-sistema)
5. [Implementación de Referencia — Módulo Asistencia](#5-implementación-de-referencia--módulo-asistencia)
6. [Convenciones y Reglas](#6-convenciones-y-reglas)

---

## 1. Principios de la Arquitectura

El backend de MarcaYA implementa la **Arquitectura Hexagonal (Puertos y Adaptadores)** sobre Rails 8. El objetivo central es aislar completamente el núcleo de negocio (validación GPS, reglas de asistencia) de los detalles de infraestructura (framework, base de datos, HTTP).

```
┌─────────────────────────────────────────────────────────┐
│                   DRIVING SIDE (entrada)                │
│   Routes → Controllers REST → Driving Ports (interfaces)│
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│              CAPA DE APLICACIÓN                         │
│     AsistenciaFacade  ←→  Casos de Uso (Interactors)    │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│               CAPA DE DOMINIO (núcleo puro)             │
│        Entidades · Value Objects · Servicios de dominio  │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                   DRIVEN SIDE (salida)                  │
│  Driven Ports (interfaces) → Driven Adapters (ORM/BD)   │
└─────────────────────────────────────────────────────────┘
```

**Regla fundamental:** las dependencias siempre apuntan hacia adentro. El Dominio no conoce Rails, no conoce ActiveRecord, no conoce HTTP.

---

## 2. Estructura de Carpetas Completa

```
marcaya-backend/
│
├── app/
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # DRIVING ADAPTERS (capa más externa — entrada)
│   ├── # ─────────────────────────────────────────────────
│   ├── controllers/
│   │   └── api/
│   │       └── v1/
│   │           ├── base_controller.rb              # JWT decode, current_user, manejo de errores
│   │           ├── auth_controller.rb              # POST /auth/login, /register, /forgot-password…
│   │           ├── perfil_controller.rb            # GET/PUT /perfil
│   │           ├── empresas_controller.rb          # CRUD empresa + empleados/obras anidados
│   │           ├── obras_controller.rb             # CRUD obras
│   │           ├── paradas_controller.rb           # CRUD paradas + asignación de empleados
│   │           ├── solicitudes_controller.rb       # Solicitudes de ingreso
│   │           ├── asistencia_controller.rb        # Marcar entrada/salida + historial
│   │           ├── reportes_controller.rb          # Reportes y estadísticas
│   │           ├── cronograma_controller.rb        # Cronograma de pagos
│   │           ├── valoraciones_controller.rb      # Valoraciones entre usuarios
│   │           └── empleados_controller.rb         # Gestión admin de empleados
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # DRIVING PORTS (interfaces de entrada al dominio)
│   ├── # ─────────────────────────────────────────────────
│   ├── ports/
│   │   └── driving/
│   │       ├── i_marcar_asistencia.rb              # interface: marcar_entrada / marcar_salida
│   │       ├── i_gestionar_obra.rb                 # interface: crear / editar / desactivar obra
│   │       ├── i_gestionar_parada.rb               # interface: CRUD parada + asignaciones
│   │       ├── i_gestionar_solicitud.rb            # interface: solicitar / aceptar / rechazar
│   │       ├── i_autenticar_usuario.rb             # interface: login / register / reset-password
│   │       ├── i_gestionar_cronograma.rb           # interface: generar / sincronizar cronograma
│   │       ├── i_gestionar_valoracion.rb           # interface: crear / listar valoraciones
│   │       └── i_reportes.rb                       # interface: reporte asistencia / estadísticas
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # CAPA DE APLICACIÓN (orquestación)
│   ├── # ─────────────────────────────────────────────────
│   ├── application/
│   │   │
│   │   ├── facades/
│   │   │   └── asistencia_facade.rb                # Orquesta: validar GPS → buscar parada → persistir
│   │   │
│   │   └── use_cases/                              # Service Objects (Interactors), 1 clase = 1 acción
│   │       │
│   │       ├── auth/
│   │       │   ├── login_usuario.rb                # Valida credenciales → genera JWT
│   │       │   ├── registrar_empleado.rb           # Crea Usuario + Empleado (estado PENDIENTE)
│   │       │   ├── registrar_empresa.rb            # Crea Usuario + Empresa
│   │       │   ├── solicitar_recuperacion.rb       # Genera TokenRecuperacion → envía correo
│   │       │   ├── verificar_codigo.rb             # Valida TokenRecuperacion
│   │       │   └── resetear_password.rb            # Actualiza claveHash
│   │       │
│   │       ├── asistencia/
│   │       │   ├── marcar_entrada.rb               # Valida GPS + crea RegistroAsistencia (ENTRADA)
│   │       │   ├── marcar_salida.rb                # Valida GPS + calcula duracion_jornada + (SALIDA)
│   │       │   ├── obtener_historial.rb            # Historial personal paginado
│   │       │   └── obtener_tiempo_real.rb          # Estado actual de empleados en paradas
│   │       │
│   │       ├── obras/
│   │       │   ├── crear_obra.rb
│   │       │   ├── editar_obra.rb
│   │       │   └── desactivar_obra.rb
│   │       │
│   │       ├── paradas/
│   │       │   ├── crear_parada.rb
│   │       │   ├── editar_parada.rb
│   │       │   ├── eliminar_parada.rb              # Verifica que no esté en uso antes de borrar
│   │       │   ├── asignar_empleado_parada.rb
│   │       │   └── desasignar_empleado_parada.rb
│   │       │
│   │       ├── solicitudes/
│   │       │   ├── solicitar_ingreso_obra.rb       # Crea SolicitudIngreso (estado PENDIENTE)
│   │       │   ├── aceptar_solicitud.rb            # Cambia estado → ACEPTADA + activa empleado
│   │       │   └── rechazar_solicitud.rb           # Cambia estado → RECHAZADA
│   │       │
│   │       ├── cronograma/
│   │       │   ├── generar_cronograma.rb           # Calcula horas + monto para un período
│   │       │   └── sincronizar_cronograma.rb       # Envía datos al sistema de pagos externo
│   │       │
│   │       ├── reportes/
│   │       │   ├── generar_reporte_asistencia.rb   # Agrega RegistroAsistencia con filtros
│   │       │   ├── exportar_reporte.rb             # Genera PDF o Excel
│   │       │   └── calcular_estadisticas.rb        # KPIs: tardanzas, horas, ausencias
│   │       │
│   │       └── valoraciones/
│   │           ├── crear_valoracion.rb
│   │           └── calcular_promedio.rb
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # CAPA DE DOMINIO (núcleo puro — sin Rails)
│   ├── # ─────────────────────────────────────────────────
│   ├── domain/
│   │   │
│   │   ├── entities/                               # POJOs (Plain Old Ruby Objects) — sin ActiveRecord
│   │   │   ├── usuario.rb
│   │   │   ├── empleado.rb
│   │   │   ├── empresa.rb
│   │   │   ├── obra.rb
│   │   │   ├── parada.rb
│   │   │   ├── registro_asistencia.rb
│   │   │   ├── solicitud_ingreso.rb
│   │   │   ├── empleado_parada.rb
│   │   │   ├── cronograma_pago.rb
│   │   │   ├── valoracion.rb
│   │   │   └── token_recuperacion.rb
│   │   │
│   │   ├── value_objects/                          # Objetos de valor inmutables
│   │   │   ├── coordenada_gps.rb                   # latitud + longitud + validación de rango
│   │   │   ├── geocerca.rb                         # centro (CoordenadaGps) + radio en metros
│   │   │   ├── tipo_marcacion.rb                   # Enum: ENTRADA / SALIDA
│   │   │   ├── rol_usuario.rb                      # Enum: EMPLEADO / EMPRESA / ADMIN
│   │   │   └── estado_solicitud.rb                 # Enum: PENDIENTE / ACEPTADA / RECHAZADA
│   │   │
│   │   └── services/                               # Lógica de negocio pura (sin I/O)
│   │       ├── gps_validation_service.rb           # Calcula distancia Haversine → bool dentro/fuera
│   │       ├── jornada_duration_service.rb         # Calcula minutos entre ENTRADA y SALIDA
│   │       └── cronograma_calculator_service.rb    # Horas trabajadas → monto a pagar
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # DRIVEN PORTS (interfaces de salida del dominio)
│   ├── # ─────────────────────────────────────────────────
│   ├── ports/
│   │   └── driven/
│   │       ├── i_usuario_repository.rb
│   │       ├── i_empleado_repository.rb
│   │       ├── i_empresa_repository.rb
│   │       ├── i_obra_repository.rb
│   │       ├── i_parada_repository.rb
│   │       ├── i_registro_asistencia_repository.rb
│   │       ├── i_solicitud_ingreso_repository.rb
│   │       ├── i_empleado_parada_repository.rb
│   │       ├── i_cronograma_pago_repository.rb
│   │       ├── i_valoracion_repository.rb
│   │       ├── i_token_recuperacion_repository.rb
│   │       └── i_notificacion_service.rb           # Puerto para envío de correos
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # DRIVEN ADAPTERS (infraestructura — implementaciones)
│   ├── # ─────────────────────────────────────────────────
│   ├── infrastructure/
│   │   │
│   │   ├── repositories/                           # Implementan los Driven Ports usando ActiveRecord
│   │   │   ├── ar_usuario_repository.rb
│   │   │   ├── ar_empleado_repository.rb
│   │   │   ├── ar_empresa_repository.rb
│   │   │   ├── ar_obra_repository.rb
│   │   │   ├── ar_parada_repository.rb
│   │   │   ├── ar_registro_asistencia_repository.rb
│   │   │   ├── ar_solicitud_ingreso_repository.rb
│   │   │   ├── ar_empleado_parada_repository.rb
│   │   │   ├── ar_cronograma_pago_repository.rb
│   │   │   ├── ar_valoracion_repository.rb
│   │   │   └── ar_token_recuperacion_repository.rb
│   │   │
│   │   ├── orm/                                    # Modelos ActiveRecord (solo mapeo y relaciones)
│   │   │   ├── usuario_record.rb
│   │   │   ├── empleado_record.rb
│   │   │   ├── empresa_record.rb
│   │   │   ├── obra_record.rb
│   │   │   ├── parada_record.rb
│   │   │   ├── registro_asistencia_record.rb
│   │   │   ├── solicitud_ingreso_record.rb
│   │   │   ├── empleado_parada_record.rb
│   │   │   ├── cronograma_pago_record.rb
│   │   │   ├── valoracion_record.rb
│   │   │   └── token_recuperacion_record.rb
│   │   │
│   │   ├── mappers/                                # Traducen ORM Record ↔ Domain Entity
│   │   │   ├── usuario_mapper.rb
│   │   │   ├── empleado_mapper.rb
│   │   │   ├── obra_mapper.rb
│   │   │   ├── parada_mapper.rb
│   │   │   ├── registro_asistencia_mapper.rb
│   │   │   └── solicitud_ingreso_mapper.rb
│   │   │
│   │   └── services/                               # Adaptadores externos
│   │       ├── mailer_notificacion_service.rb      # Implementa INotificacionService → ActionMailer
│   │       ├── jwt_token_service.rb                # Codifica / decodifica JWT
│   │       └── reporte_export_service.rb           # Genera PDF/Excel (Prawn / Axlsx)
│   │
│   ├── # ─────────────────────────────────────────────────
│   ├── # PRESENTERS / SERIALIZERS (respuesta HTTP)
│   ├── # ─────────────────────────────────────────────────
│   └── serializers/
│       ├── usuario_serializer.rb
│       ├── empleado_serializer.rb
│       ├── empresa_serializer.rb
│       ├── obra_serializer.rb
│       ├── parada_serializer.rb
│       ├── registro_asistencia_serializer.rb
│       ├── solicitud_ingreso_serializer.rb
│       ├── cronograma_pago_serializer.rb
│       └── valoracion_serializer.rb
│
├── config/
│   ├── routes.rb                                   # Declaración de rutas /api/v1/*
│   ├── initializers/
│   │   ├── dependency_injection.rb                 # Registro de implementaciones concretas
│   │   └── jwt.rb                                  # Configuración de secreto JWT
│   └── application.rb
│
├── db/
│   ├── migrate/
│   │   ├── 001_create_usuarios.rb
│   │   ├── 002_create_empleados.rb
│   │   ├── 003_create_empresas.rb
│   │   ├── 004_create_obras.rb
│   │   ├── 005_create_paradas.rb
│   │   ├── 006_create_registro_asistencias.rb
│   │   ├── 007_create_solicitud_ingresos.rb
│   │   ├── 008_create_empleado_paradas.rb
│   │   ├── 009_create_cronograma_pagos.rb
│   │   ├── 010_create_valoraciones.rb
│   │   └── 011_create_token_recuperaciones.rb
│   └── schema.rb
│
├── spec/                                           # RSpec — pruebas unitarias e integración
│   ├── domain/
│   │   ├── entities/
│   │   ├── value_objects/
│   │   └── services/
│   │       └── gps_validation_service_spec.rb      # Prueba Haversine sin BD
│   ├── application/
│   │   ├── facades/
│   │   │   └── asistencia_facade_spec.rb
│   │   └── use_cases/
│   │       └── asistencia/
│   │           ├── marcar_entrada_spec.rb
│   │           └── marcar_salida_spec.rb
│   ├── infrastructure/
│   │   └── repositories/
│   └── controllers/
│       └── api/v1/
│
└── Gemfile
```

---

## 3. Capas y Responsabilidades

### 3.1 Driving Adapters — Entrada

**Ubicación:** `app/controllers/api/v1/`

Son la puerta de entrada al sistema. Reciben la petición HTTP, extraen y validan los parámetros, delegan al caso de uso correspondiente a través del Driving Port, y serializan la respuesta.

**Reglas:**
- **No contienen lógica de negocio.** Solo orquestan la llamada.
- Responden únicamente con el resultado del caso de uso.
- Manejan errores de dominio y los traducen a códigos HTTP apropiados.

**Ejemplo — `asistencia_controller.rb`:**
```ruby
module Api
  module V1
    class AsistenciaController < BaseController
      before_action :authenticate_user!

      # POST /api/v1/asistencia/marcar-entrada
      def marcar_entrada
        resultado = @marcar_asistencia_port.marcar_entrada(
          empleado_id: current_user.id,
          parada_id:   params[:parada_id],
          latitud:     params[:latitud].to_f,
          longitud:    params[:longitud].to_f
        )
        render json: RegistroAsistenciaSerializer.new(resultado).as_json, status: :created
      rescue Domain::Errors::FueraDeGeocercaError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/asistencia/marcar-salida
      def marcar_salida
        resultado = @marcar_asistencia_port.marcar_salida(
          empleado_id: current_user.id,
          parada_id:   params[:parada_id],
          latitud:     params[:latitud].to_f,
          longitud:    params[:longitud].to_f
        )
        render json: RegistroAsistenciaSerializer.new(resultado).as_json, status: :created
      end

      # GET /api/v1/asistencia/historial
      def historial
        registros = @obtener_historial_port.ejecutar(empleado_id: current_user.id)
        render json: registros.map { |r| RegistroAsistenciaSerializer.new(r).as_json }
      end
    end
  end
end
```

---

### 3.2 Driving Ports — Interfaces de Entrada

**Ubicación:** `app/ports/driving/`

Son módulos Ruby que definen los contratos (métodos públicos) que los controladores pueden invocar. Permiten sustituir la implementación sin tocar el controlador.

**Ejemplo — `i_marcar_asistencia.rb`:**
```ruby
module Ports
  module Driving
    module IMarcarAsistencia
      # @param empleado_id [String]
      # @param parada_id   [String]
      # @param latitud     [Float]
      # @param longitud    [Float]
      # @return [Domain::Entities::RegistroAsistencia]
      # @raise  [Domain::Errors::FueraDeGeocercaError]
      def marcar_entrada(empleado_id:, parada_id:, latitud:, longitud:)
        raise NotImplementedError
      end

      def marcar_salida(empleado_id:, parada_id:, latitud:, longitud:)
        raise NotImplementedError
      end
    end
  end
end
```

---

### 3.3 Capa de Aplicación

**Ubicación:** `app/application/`

#### Facade — `asistencia_facade.rb`

Orquesta el flujo completo de marcación. Es la única clase que conoce el orden de los pasos: buscar empleado → buscar parada → validar GPS → persistir registro.

```ruby
module Application
  module Facades
    class AsistenciaFacade
      include Ports::Driving::IMarcarAsistencia

      def initialize(
        empleado_repo:   Infrastructure::Repositories::ArEmpleadoRepository.new,
        parada_repo:     Infrastructure::Repositories::ArParadaRepository.new,
        asistencia_repo: Infrastructure::Repositories::ArRegistroAsistenciaRepository.new,
        gps_service:     Domain::Services::GpsValidationService.new
      )
        @empleado_repo   = empleado_repo
        @parada_repo     = parada_repo
        @asistencia_repo = asistencia_repo
        @gps_service     = gps_service
      end

      def marcar_entrada(empleado_id:, parada_id:, latitud:, longitud:)
        Application::UseCases::Asistencia::MarcarEntrada.new(
          empleado_repo:   @empleado_repo,
          parada_repo:     @parada_repo,
          asistencia_repo: @asistencia_repo,
          gps_service:     @gps_service
        ).ejecutar(empleado_id: empleado_id, parada_id: parada_id,
                   latitud: latitud, longitud: longitud)
      end

      def marcar_salida(empleado_id:, parada_id:, latitud:, longitud:)
        Application::UseCases::Asistencia::MarcarSalida.new(
          empleado_repo:   @empleado_repo,
          parada_repo:     @parada_repo,
          asistencia_repo: @asistencia_repo,
          gps_service:     @gps_service
        ).ejecutar(empleado_id: empleado_id, parada_id: parada_id,
                   latitud: latitud, longitud: longitud)
      end
    end
  end
end
```

#### Casos de Uso (Interactors)

Cada caso de uso encapsula **una sola acción de negocio**. Recibe repositorios por inyección de dependencias.

```ruby
# app/application/use_cases/asistencia/marcar_entrada.rb
module Application
  module UseCases
    module Asistencia
      class MarcarEntrada
        def initialize(empleado_repo:, parada_repo:, asistencia_repo:, gps_service:)
          @empleado_repo   = empleado_repo
          @parada_repo     = parada_repo
          @asistencia_repo = asistencia_repo
          @gps_service     = gps_service
        end

        # @return [Domain::Entities::RegistroAsistencia]
        def ejecutar(empleado_id:, parada_id:, latitud:, longitud:)
          empleado = @empleado_repo.find_by_id!(empleado_id)
          parada   = @parada_repo.find_by_id!(parada_id)

          coordenada = Domain::ValueObjects::CoordenadaGps.new(latitud, longitud)
          valida_gps = @gps_service.dentro_de_geocerca?(coordenada, parada.geocerca)

          registro = Domain::Entities::RegistroAsistencia.new(
            empleado_id:         empleado.id,
            parada_id:           parada.id,
            tipo_marcacion:      Domain::ValueObjects::TipoMarcacion::ENTRADA,
            fecha_hora:          Time.current,
            latitud_registrada:  latitud,
            longitud_registrada: longitud,
            valida_gps:          valida_gps
          )

          @asistencia_repo.guardar(registro)
        end
      end
    end
  end
end
```

---

### 3.4 Capa de Dominio

**Ubicación:** `app/domain/`

Es el núcleo del sistema. **No tiene ninguna dependencia de Rails, ActiveRecord, HTTP ni de ningún framework externo.**

#### Entidades

Objetos de identidad con estado. Se inicializan con atributos tipados.

```ruby
# app/domain/entities/parada.rb
module Domain
  module Entities
    class Parada
      attr_reader :id, :nombre, :latitud, :longitud, :radio, :obra_id, :estado, :fecha_creacion

      def initialize(id:, nombre:, latitud:, longitud:, radio:, obra_id:, estado:, fecha_creacion:)
        @id             = id
        @nombre         = nombre
        @latitud        = latitud
        @longitud       = longitud
        @radio          = radio
        @obra_id        = obra_id
        @estado         = estado
        @fecha_creacion = fecha_creacion
      end

      def geocerca
        Domain::ValueObjects::Geocerca.new(
          centro: Domain::ValueObjects::CoordenadaGps.new(@latitud, @longitud),
          radio:  @radio
        )
      end

      def activa?
        @estado == "ACTIVA"
      end
    end
  end
end
```

#### Value Objects

Inmutables, se comparan por valor, encapsulan reglas de formato o rango.

```ruby
# app/domain/value_objects/coordenada_gps.rb
module Domain
  module ValueObjects
    class CoordenadaGps
      attr_reader :latitud, :longitud

      def initialize(latitud, longitud)
        raise ArgumentError, "Latitud inválida"  unless (-90..90).cover?(latitud)
        raise ArgumentError, "Longitud inválida" unless (-180..180).cover?(longitud)
        @latitud  = latitud
        @longitud = longitud
      end

      def ==(other)
        other.is_a?(CoordenadaGps) &&
          other.latitud == @latitud &&
          other.longitud == @longitud
      end
    end
  end
end
```

#### Servicios de Dominio

Lógica de negocio pura que opera sobre entidades y value objects.

```ruby
# app/domain/services/gps_validation_service.rb
module Domain
  module Services
    class GpsValidationService
      RADIO_TIERRA_KM = 6371.0

      # @param coordenada [Domain::ValueObjects::CoordenadaGps]
      # @param geocerca   [Domain::ValueObjects::Geocerca]
      # @return [Boolean]
      def dentro_de_geocerca?(coordenada, geocerca)
        distancia_metros(coordenada, geocerca.centro) <= geocerca.radio
      end

      private

      # Fórmula de Haversine
      def distancia_metros(a, b)
        lat1 = a.latitud  * Math::PI / 180
        lat2 = b.latitud  * Math::PI / 180
        dlat = (b.latitud  - a.latitud)  * Math::PI / 180
        dlon = (b.longitud - a.longitud) * Math::PI / 180

        h = Math.sin(dlat / 2)**2 +
            Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon / 2)**2

        RADIO_TIERRA_KM * 2 * Math.asin(Math.sqrt(h)) * 1000
      end
    end
  end
end
```

---

### 3.5 Driven Ports — Interfaces de Salida

**Ubicación:** `app/ports/driven/`

Contratos que el dominio define para persistir o consultar datos. Las implementaciones concretas (ActiveRecord) están en la infraestructura.

```ruby
# app/ports/driven/i_registro_asistencia_repository.rb
module Ports
  module Driven
    module IRegistroAsistenciaRepository
      # @param registro [Domain::Entities::RegistroAsistencia]
      # @return [Domain::Entities::RegistroAsistencia]
      def guardar(registro) = raise NotImplementedError

      # @return [Array<Domain::Entities::RegistroAsistencia>]
      def find_by_empleado(empleado_id:, pagina: 1) = raise NotImplementedError

      # @return [Domain::Entities::RegistroAsistencia, nil]
      def ultima_entrada(empleado_id:, parada_id:) = raise NotImplementedError

      # @return [Array<Domain::Entities::RegistroAsistencia>]
      def find_by_filtros(fecha_inicio:, fecha_fin:, empleado_id: nil,
                          parada_id: nil, obra_id: nil) = raise NotImplementedError
    end
  end
end
```

---

### 3.6 Driven Adapters — Infraestructura

**Ubicación:** `app/infrastructure/`

#### Modelos ORM (`orm/`)

Solo mapean columnas y relaciones. **Sin lógica de negocio.**

```ruby
# app/infrastructure/orm/parada_record.rb
class ParadaRecord < ApplicationRecord
  self.table_name = "paradas"

  belongs_to :obra_record, foreign_key: :obra_id, class_name: "ObraRecord"
  has_many   :empleado_parada_records, foreign_key: :parada_id
  has_many   :registro_asistencia_records, foreign_key: :parada_id

  enum estado: { ACTIVA: "ACTIVA", INACTIVA: "INACTIVA" }
end
```

#### Repositorios (`repositories/`)

Implementan el Driven Port. Usan el modelo ORM internamente y devuelven entidades de dominio.

```ruby
# app/infrastructure/repositories/ar_parada_repository.rb
module Infrastructure
  module Repositories
    class ArParadaRepository
      include Ports::Driven::IParadaRepository

      def find_by_id!(id)
        record = ParadaRecord.find(id)
        Infrastructure::Mappers::ParadaMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::ParadaNoEncontradaError, "Parada #{id} no existe"
      end

      def guardar(parada)
        record = parada.id ? ParadaRecord.find(parada.id) : ParadaRecord.new
        record.assign_attributes(Infrastructure::Mappers::ParadaMapper.to_record_attrs(parada))
        record.save!
        Infrastructure::Mappers::ParadaMapper.to_domain(record)
      end
    end
  end
end
```

#### Mappers (`mappers/`)

Traducen bidirecccionalmente entre `Record` (ORM) y `Entity` (dominio).

```ruby
# app/infrastructure/mappers/parada_mapper.rb
module Infrastructure
  module Mappers
    class ParadaMapper
      def self.to_domain(record)
        Domain::Entities::Parada.new(
          id:             record.id.to_s,
          nombre:         record.nombre,
          latitud:        record.latitud.to_f,
          longitud:       record.longitud.to_f,
          radio:          record.radio.to_f,
          obra_id:        record.obra_id.to_s,
          estado:         record.estado,
          fecha_creacion: record.created_at
        )
      end

      def self.to_record_attrs(parada)
        {
          nombre:    parada.nombre,
          latitud:   parada.latitud,
          longitud:  parada.longitud,
          radio:     parada.radio,
          obra_id:   parada.obra_id,
          estado:    parada.estado
        }
      end
    end
  end
end
```

---

## 4. Módulos del Sistema

| Módulo | Facade | Casos de uso | Entidades clave | Endpoints |
|--------|--------|-------------|-----------------|-----------|
| Auth | — | `LoginUsuario`, `RegistrarEmpleado`, `RegistrarEmpresa`, `SolicitarRecuperacion`, `VerificarCodigo`, `ResetearPassword` | Usuario, TokenRecuperacion | 7 |
| Asistencia | `AsistenciaFacade` | `MarcarEntrada`, `MarcarSalida`, `ObtenerHistorial`, `ObtenerTiempoReal` | RegistroAsistencia, Parada | 6 |
| Obras | — | `CrearObra`, `EditarObra`, `DesactivarObra` | Obra | 5 |
| Paradas | — | `CrearParada`, `EditarParada`, `EliminarParada`, `AsignarEmpleadoParada`, `DesasignarEmpleadoParada` | Parada, EmpleadoParada | 9 |
| Solicitudes | — | `SolicitarIngresoObra`, `AceptarSolicitud`, `RechazarSolicitud` | SolicitudIngreso | 6 |
| Cronograma | — | `GenerarCronograma`, `SincronizarCronograma` | CronogramaPago | 5 |
| Reportes | — | `GenerarReporteAsistencia`, `ExportarReporte`, `CalcularEstadisticas` | RegistroAsistencia (agregado) | 4 |
| Valoraciones | — | `CrearValoracion`, `CalcularPromedio` | Valoracion | 3 |
| Empleados | — | (usa repos directos vía controlador) | Empleado | 6 |
| Perfil | — | (usa repos directos vía controlador) | Usuario | 3 |

---

## 5. Implementación de Referencia — Módulo Asistencia

Flujo completo de `POST /api/v1/asistencia/marcar-entrada`:

```
HTTP Request (JSON: parada_id, latitud, longitud)
    │
    ▼
AsistenciaController#marcar_entrada
    │  extrae params, verifica JWT (BaseController)
    ▼
AsistenciaFacade#marcar_entrada          ← Driving Port
    │  orquesta los pasos
    ▼
MarcarEntrada#ejecutar                   ← Use Case
    │
    ├─► ArEmpleadoRepository#find_by_id! → EmpleadoRecord → Empleado (dominio)
    ├─► ArParadaRepository#find_by_id!   → ParadaRecord   → Parada   (dominio)
    │
    ├─► CoordenadaGps.new(lat, lon)      ← Value Object (valida rangos)
    ├─► GpsValidationService#dentro_de_geocerca?(coordenada, parada.geocerca)
    │       └─ Haversine puro, sin I/O
    │
    ├─► RegistroAsistencia.new(...)      ← Domain Entity
    │
    └─► ArRegistroAsistenciaRepository#guardar(registro)
            └─ RegistroAsistenciaMapper.to_record_attrs → INSERT PostgreSQL
    │
    ▼
RegistroAsistenciaSerializer#as_json
    │
    ▼
HTTP Response 201 Created (JSON)
```

---

## 6. Convenciones y Reglas

### Nomenclatura

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Driving Port | `I` + nombre en CamelCase | `IMarcarAsistencia` |
| Driven Port | `I` + entidad + `Repository` | `IParadaRepository` |
| Repositorio AR | `Ar` + entidad + `Repository` | `ArParadaRepository` |
| Modelo ORM | entidad + `Record` | `ParadaRecord` |
| Caso de Uso | verbo + sustantivo | `MarcarEntrada`, `CrearObra` |
| Mapper | entidad + `Mapper` | `ParadaMapper` |
| Serializer | entidad + `Serializer` | `ParadaSerializer` |
| Servicio dominio | nombre descriptivo + `Service` | `GpsValidationService` |

### Reglas de dependencias

```
Controllers     → solo conocen Ports::Driving
Facades         → conocen Ports::Driving + UseCases
UseCases        → solo conocen Domain + Ports::Driven
Domain          → no conoce NADA externo (cero dependencias de Rails)
Repositories    → conocen ORM Records + Domain Entities + Mappers
Mappers         → conocen ORM Records + Domain Entities
Serializers     → conocen Domain Entities, producen Hash/JSON
```

### Inyección de dependencias

Las dependencias concretas se registran en `config/initializers/dependency_injection.rb`:

```ruby
# config/initializers/dependency_injection.rb
Rails.application.config.after_initialize do
  empleado_repo    = Infrastructure::Repositories::ArEmpleadoRepository.new
  parada_repo      = Infrastructure::Repositories::ArParadaRepository.new
  asistencia_repo  = Infrastructure::Repositories::ArRegistroAsistenciaRepository.new
  gps_service      = Domain::Services::GpsValidationService.new

  Rails.configuration.asistencia_facade = Application::Facades::AsistenciaFacade.new(
    empleado_repo:   empleado_repo,
    parada_repo:     parada_repo,
    asistencia_repo: asistencia_repo,
    gps_service:     gps_service
  )
end
```

Los controladores acceden al facade mediante `before_action`:

```ruby
# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ActionController::API
  before_action :set_facades

  private

  def set_facades
    @marcar_asistencia_port = Rails.configuration.asistencia_facade
  end
end
```

### Manejo de errores de dominio

```ruby
# app/domain/errors/
module Domain
  module Errors
    class FueraDeGeocercaError    < StandardError; end
    class ParadaNoEncontradaError < StandardError; end
    class EmpleadoInactivoError   < StandardError; end
    class SolicitudYaExisteError  < StandardError; end
    class MarcacionDuplicadaError < StandardError; end
  end
end
```

Los controladores los capturan y los traducen a HTTP:

```ruby
rescue_from Domain::Errors::FueraDeGeocercaError,    with: :unprocessable_entity
rescue_from Domain::Errors::ParadaNoEncontradaError, with: :not_found
rescue_from Domain::Errors::EmpleadoInactivoError,   with: :forbidden
```

### Pruebas

- **Dominio** (`spec/domain/`) — sin Rails, sin BD, velocidad máxima.
- **Casos de uso** (`spec/application/`) — con mocks/doubles de repositorios.
- **Repositorios** (`spec/infrastructure/`) — con BD real en memoria (`:memory:` o fixtures).
- **Controladores** (`spec/controllers/`) — request specs con JWT simulado.

```ruby
# spec/domain/services/gps_validation_service_spec.rb
RSpec.describe Domain::Services::GpsValidationService do
  subject(:service) { described_class.new }

  let(:parada_centro) { Domain::ValueObjects::CoordenadaGps.new(-12.0464, -77.0428) }
  let(:geocerca)      { Domain::ValueObjects::Geocerca.new(centro: parada_centro, radio: 100) }

  it "devuelve true cuando el empleado está dentro del radio" do
    dentro = Domain::ValueObjects::CoordenadaGps.new(-12.0465, -77.0429) # ~15 metros
    expect(service.dentro_de_geocerca?(dentro, geocerca)).to be true
  end

  it "devuelve false cuando el empleado está fuera del radio" do
    fuera = Domain::ValueObjects::CoordenadaGps.new(-12.0600, -77.0600) # ~2 km
    expect(service.dentro_de_geocerca?(fuera, geocerca)).to be false
  end
end
```

---

*Documento técnico — MarcaYA Backend · Arquitectura Hexagonal (Puertos y Adaptadores) sobre Ruby on Rails 8*