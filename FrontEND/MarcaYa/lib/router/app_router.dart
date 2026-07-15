import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../pages/resumen_empleado/historial_solicitudes_page.dart';
import '../pages/historial_asistencias/historial_asistencias_page.dart';
import '../providers/auth_provider.dart';
import '../pages/sign_in/sign_in_page.dart';
import '../pages/registrar_usuario/registrar_usuario.dart';
import '../pages/registrar_empresa/registrar_empresa.dart';
import '../pages/registrar_empleado/registrar_empleado.dart';
import '../pages/verificacion_registro/verificacion_registro_page.dart';
import '../pages/recuperar_contrasena/recuperar_contrasena.dart';
import '../pages/codigo_contrasena/codigo_contrasena.dart';
import '../pages/nueva_contrasena/nueva_contrasena.dart';
import '../pages/resumen_empleado/resumen_empleado.dart';
import '../pages/resumen_empresa/resumen_empresa.dart';
import '../pages/marcar_asistencia/marcar_asistencia.dart';
import '../pages/perfil_empresa/perfil_empresa.dart';
import '../pages/perfil_empleado/perfil_empleado.dart';
import '../pages/buscar/buscar_page.dart';
import '../pages/lista_obras/lista_obras_page.dart';
import '../pages/administrar_paradas/administrar_paradas.dart';
import '../pages/agregar_parada/agregar_parada.dart';
import '../pages/agregar_parada/agregar_parada_page.dart';
import '../pages/editar_parada/editar_parada.dart';
import '../pages/ver_asistencia/ver_asistencia.dart';
import '../pages/empleados_actuales/empleados_actuales.dart';
import '../pages/paradas_por_obra/paradas_por_obra_page.dart';
import '../pages/ver_solicitudes/ver_solicitudes.dart';
import '../pages/verificar_otp/verificar_otp_page.dart';
import '../pages/locked/locked_page.dart';
import '../pages/confirmacion_registrar_empleado/confirmacion_registrar_empleado.dart';
import '../pages/historial_asistencia/historial_asistencia_page.dart';
import '../pages/informes_asistencia/informes_asistencia_page.dart';
import '../pages/perfil_publico/perfil_publico.dart';
import '../pages/editar_perfil_empleado/editar_perfil_empleado_page.dart';
import '../pages/editar_perfil_empresa/editar_perfil_empresa_page.dart';
import '../pages/detalles_obra/detalles_obra_page.dart';
import '../pages/historial_cobros/historial_cobros_page.dart';
import '../pages/nomina_empresa/nomina_empresa_page.dart';
import '../pages/informe_ia/informe_ia_page.dart';
import '../src/app_state.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  redirect: (context, state) {
    final auth = context.read<AuthProvider>();

    final loggedIn = auth.isLoggedIn;
    final location = state.matchedLocation;

    if (loggedIn) {
      final user = auth.currentUserProfile;
      if (user != null && user.rol == UserRole.empresa) {
        if (user.estado == 'PENDIENTE') {
          if (location != '/locked') return '/locked';
        } else {
          if (location == '/locked') return '/empresa';
        }
      }
    }

    if (loggedIn && location == '/') {
      return auth.userRole == 'empleado'
          ? '/empleado'
          : '/empresa';
    }

    final protected =
        location.startsWith('/empleado') ||
            location.startsWith('/empresa') ||
            location == '/locked';

    if (!loggedIn && protected) {
      return '/';
    }

    return null;
  },

  routes: [

    // LOGIN
    GoRoute(
      path: '/',
      builder: (_, __) => const SignInPage(),
    ),

    // REGISTRO
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegistrarUsuarioPage(),
    ),

    GoRoute(
      path: '/register/empresa',
      builder: (_, __) => const RegistrarEmpresaPage(),
    ),

    GoRoute(
      path: '/register/empleado',
      builder: (_, __) => const RegistrarEmpleadoPage(),
    ),

    GoRoute(
      path: '/register/verify',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final correo = extra?['correo'] as String?;
        final rol = extra?['rol'] as String? ?? 'usuario';

        if (correo == null || correo.isEmpty) {
          return const RegistrarUsuarioPage();
        }

        return VerificacionRegistroPage(correo: correo, rol: rol);
      },
    ),

    // RECUPERAR CONTRASEÑA
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const RecuperarContrasenaPage(),
    ),

    GoRoute(
      path: '/reset-password/code',
      builder: (_, __) => const CodigoContrasenaPage(),
    ),

    GoRoute(
      path: '/reset-password/new',
      builder: (_, __) => const NuevaContrasenaPage(),
    ),

    // EMPLEADO
    GoRoute(
      path: '/empleado',
      builder: (_, __) => const ResumenEmpleadoPage(),
    ),

    GoRoute(
      path: '/empleado/buscar',
      builder: (context, state) =>
      const BuscarPage(
        userRole: 'empleado',
      ),
    ),

    GoRoute(
      path: '/empleado/perfil',
      builder: (_, __) => const PerfilEmpleadoPage(),
    ),
    GoRoute(
      path: '/empleado/perfil/editar',
      builder: (_, __) => const EditarPerfilEmpleadoPage(),
    ),

    // US-NUEVA-09 CA-3: Destino del tap en notificación push
    GoRoute(
      path: '/empleado/historial-asistencias',
      builder: (_, __) => const HistorialAsistenciasPage(),
    ),

    // Integración de Pagos: historial de cobros del empleado
    GoRoute(
      path: '/empleado/historial-cobros',
      builder: (_, __) => const HistorialCobrosPage(),
    ),

    GoRoute(
      path: '/empleado/marcar_asistencia',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return MarcarAsistenciaPage(
          obraId: extra['obraId'],
          obraNombre: extra['obraNombre'],
          latitud: extra['latitud'],
          longitud: extra['longitud'],
          radio: extra['radio'],
          horaInicio: extra['horaInicio'] ?? '08:00',
          horaFin: extra['horaFin'] ?? '18:00',
        );
      },
    ),
    GoRoute(
      path: '/perfil-publico',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final usuarioId = extra['usuarioId'] as int;
        return PerfilPublicoPage(usuarioId: usuarioId);
      },
    ),
    // EMPRESA
    GoRoute(
      path: '/empresa',
      builder: (_, __) => const ResumenEmpresaPage(),
    ),

    GoRoute(
      path: '/empresa/buscar',
      builder: (context, state) =>
      const BuscarPage(
        userRole: 'empresa',
      ),
    ),

    GoRoute(
      path: '/empresa/perfil',
      builder: (_, __) => const PerfilEmpresaPage(),
    ),
    GoRoute(
      path: '/empresa/perfil/editar',
      builder: (_, __) => const EditarPerfilEmpresaPage(),
    ),

    // Integración de Pagos: panel de nómina de la empresa
    GoRoute(
      path: '/empresa/nomina',
      builder: (_, __) => const NominaEmpresaPage(),
    ),

    // US-NUEVA-06: Informe ejecutivo con IA
    GoRoute(
      path: '/empresa/informe-ia',
      builder: (_, __) => const InformeIAPage(),
    ),

    // RUTAS INTERNAS DE EMPRESA
    GoRoute(
      path: '/empresa/paradas',
      builder: (_, __) => const AdministrarParadasPage(),
    ),

    GoRoute(
      path: '/empresa/obras',
      builder: (_, __) => const ListaObrasPage(),
    ),
    GoRoute(
      path: '/empresa/obras/agregar',
      builder: (_, __) => const AgregarObraPage(),
    ),
    GoRoute(
      path: '/empresa/obras/:obraId/paradas',
      builder: (context, state) {
        final obraId = int.parse(state.pathParameters['obraId']!);
        final extra = state.extra as Map<String, dynamic>?;
        return ParadasPorObraPage(
          obraId: obraId,
          obraNombre: extra?['obraNombre'] as String?,
        );
      },
    ),

    GoRoute(
      path: '/empresa/obras/:obraId/detalles',
      builder: (context, state) {
        final obraId = int.parse(state.pathParameters['obraId']!);
        final extra = state.extra as Map<String, dynamic>?;
        return DetallesObraPage(
          obraId: obraId,
          obraNombre: extra?['obraNombre'] as String?,
        );
      },
    ),

    GoRoute(
      path: '/empresa/paradas/agregar',
      builder: (context, state) => AgregarParadaPage(
        obraId: state.extra as int?,
      ),
    ),
    GoRoute(
      path: '/empresa/paradas/editar',
      builder: (context, state) => EditarParadaPage(
        paradaData: state.extra as Map<String, dynamic>,
      ),
    ),

    GoRoute(
      path: '/empresa/asistencia',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return VerAsistenciaPage(paradaId: extra['paradaId'] as int);
      },
    ),

    GoRoute(
      path: '/empresa/empleados',
      builder: (_, __) => const EmpleadosActualesPage(),
    ),

    GoRoute(
      path: '/empresa/solicitudes',
      builder: (_, __) => const VerSolicitudesPage(),
    ),

    GoRoute(
      path: '/empresa/informes',
      builder: (_, __) => const InformesAsistenciaPage(),
    ),

    // VERIFICACIONES Y PANTALLAS DE ESPERA
    GoRoute(
      path: '/verificar-otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return VerificarOtpPage(
          ruc: extra?['ruc'] as String?,
          correo: extra?['correo'] as String?,
        );
      },
    ),

    GoRoute(
      path: '/locked',
      builder: (_, __) => const LockedPage(),
    ),

    GoRoute(
      path: '/confirmacion/empleado',
      builder: (_, __) =>
      const ConfirmacionRegistrarEmpleadoPage(),
    ),
    GoRoute(
      path: '/empleado/solicitudes',
      builder: (context, state) {

        final auth =
        Provider.of<AuthProvider>(
          context,
          listen: false,
        );
        return HistorialSolicitudesPage(
          empleadoId: auth.currentUserProfile!.employeeId ?? auth.currentUserProfile!.id.toString(),
        );
      },
    ),
    GoRoute(
      path: '/empleado/historial',
      builder: (_, __) => const HistorialAsistenciaPage(),
    ),
  ],
);
