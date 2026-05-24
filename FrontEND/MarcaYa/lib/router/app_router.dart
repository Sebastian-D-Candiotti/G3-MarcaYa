import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/sign_in/sign_in_page.dart';
import '../pages/registrar_usuario/registrar_usuario.dart';
import '../pages/registrar_empresa/registrar_empresa.dart';
import '../pages/registrar_empleado/registrar_empleado.dart';
import '../pages/recuperar_contrasena/recuperar_contrasena.dart';
import '../pages/codigo_contrasena/codigo_contrasena.dart';
import '../pages/nueva_contrasena/nueva_contrasena.dart';
import '../pages/resumen_empleado/resumen_empleado.dart';
import '../pages/resumen_empresa/resumen_empresa.dart';
import '../pages/marcar_asistencia/marcar_asistencia.dart';
import '../pages/perfil_empresa/perfil_empresa.dart';
import '../pages/perfil_empleado/perfil_empleado.dart';
import '../pages/buscar/buscar_page.dart';
import '../pages/administrar_paradas/administrar_paradas.dart';
import '../pages/agregar_parada/agregar_parada.dart';
import '../pages/editar_parada/editar_parada.dart';
import '../pages/ver_asistencia/ver_asistencia.dart';
import '../pages/empleados_actuales/empleados_actuales.dart';
import '../pages/ver_solicitudes/ver_solicitudes.dart';
import '../pages/confirmacion_registrar_empresa/confirmacion_registrar_empresa.dart';
import '../pages/confirmacion_registrar_empleado/confirmacion_registrar_empleado.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final loggedIn = auth.isLoggedIn;
    final location = state.matchedLocation;

    if (loggedIn && location == '/') {
      return auth.userRole == 'empleado' ? '/empleado' : '/empresa';
    }

    final protected = location.startsWith('/empleado') || location.startsWith('/empresa');
    if (!loggedIn && protected) return '/';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SignInPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegistrarUsuarioPage()),
    GoRoute(path: '/register/empresa', builder: (_, __) => const RegistrarEmpresaPage()),
    GoRoute(path: '/register/empleado', builder: (_, __) => const RegistrarEmpleadoPage()),
    GoRoute(path: '/reset-password', builder: (_, __) => const RecuperarContrasenaPage()),
    GoRoute(path: '/reset-password/code', builder: (_, __) => const CodigoContrasenaPage()),
    GoRoute(path: '/reset-password/new', builder: (_, __) => const NuevaContrasenaPage()),
    GoRoute(path: '/empleado', builder: (_, __) => const ResumenEmpleadoPage()),
    GoRoute(path: '/empleado/asistencia', builder: (_, __) => const MarcarAsistenciaPage()),
    GoRoute(path: '/empleado/buscar', builder: (_, __) => const BuscarPage()),
    GoRoute(path: '/empleado/perfil', builder: (_, __) => const PerfilEmpleadoPage()),
    GoRoute(path: '/empresa', builder: (_, __) => const ResumenEmpresaPage()),
    GoRoute(path: '/empresa/paradas', builder: (_, __) => const AdministrarParadasPage()),
    GoRoute(path: '/empresa/paradas/agregar', builder: (_, __) => const AgregarParadaPage()),
    GoRoute(path: '/empresa/paradas/editar', builder: (_, __) => const EditarParadaPage()),
    GoRoute(path: '/empresa/asistencia', builder: (_, __) => const VerAsistenciaPage()),
    GoRoute(path: '/empresa/empleados', builder: (_, __) => const EmpleadosActualesPage()),
    GoRoute(path: '/empresa/solicitudes', builder: (_, __) => const VerSolicitudesPage()),
    GoRoute(path: '/empresa/perfil', builder: (_, __) => const PerfilEmpresaPage()),
    GoRoute(path: '/confirmacion/empresa', builder: (_, __) => const ConfirmacionRegistrarEmpresaPage()),
    GoRoute(path: '/confirmacion/empleado', builder: (_, __) => const ConfirmacionRegistrarEmpleadoPage()),
  ],
);
