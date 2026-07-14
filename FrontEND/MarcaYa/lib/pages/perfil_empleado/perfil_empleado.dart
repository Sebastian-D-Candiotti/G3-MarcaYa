import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';
import '../../src/app_state.dart';
import '../../theme/app_theme.dart';
import '../../services/auto_marking_service.dart';
import '../../services/auto_marking_prefs.dart';

class PerfilEmpleadoPage extends StatefulWidget {
  const PerfilEmpleadoPage({super.key});

  @override
  State<PerfilEmpleadoPage> createState() => _PerfilEmpleadoPageState();
}

class _PerfilEmpleadoPageState extends State<PerfilEmpleadoPage> {
  bool _autoMarking = false;
  bool _loadingSwitch = true;
  bool _togglingSwitch = false;

  @override
  void initState() {
    super.initState();
    _loadAutoMarkingState();
  }

  Future<void> _loadAutoMarkingState() async {
    final enabled = await AutoMarkingPrefs.isEnabled();
    if (mounted) {
      setState(() {
        _autoMarking = enabled;
        _loadingSwitch = false;
      });
    }
  }

  Future<void> _toggleAutoMarking(bool value) async {
    setState(() => _togglingSwitch = true);

    try {
      if (value) {
        // ── Activar marcación automática ─────────────────────
        // 1. Guardar token JWT en SharedPreferences para el Isolate
        final token = await ApiService.instance.getToken();
        if (token == null) {
          _showError('No se pudo obtener el token. Inicia sesión de nuevo.');
          setState(() => _togglingSwitch = false);
          return;
        }
        await AutoMarkingPrefs.saveToken(token);
        await AutoMarkingPrefs.saveBaseUrl(kBaseUrl);

        // 2. Obtener primera obra/parada del empleado
        final auth = context.read<AuthProvider>();
        final empleadoId = auth.currentUserProfile?.employeeId;
        if (empleadoId == null) {
          _showError('No se encontró el ID de empleado.');
          setState(() => _togglingSwitch = false);
          return;
        }

        final obras = await ApiService.instance.obtenerObrasEmpleado(empleadoId);
        if (obras.isEmpty) {
          _showError(
            'No tienes obras asignadas. Necesitas al menos una obra '
            'para activar la marcación automática.',
          );
          setState(() => _togglingSwitch = false);
          return;
        }

        final primeraObra = obras.first as Map<String, dynamic>;
        final obraId = primeraObra['id'];
        final obraNombre = primeraObra['nombre']?.toString() ?? 'Obra';

        // Obtener paradas del empleado en esta obra
        final empleadoIdInt = int.parse(empleadoId);
        final paradas = await ApiService.instance.obtenerParadasEmpleado(empleadoIdInt);
        final paradasDeObra = paradas
            .where((p) =>
                p['obraId'] == obraId || p['obra_id'] == obraId)
            .toList();

        if (paradasDeObra.isEmpty) {
          _showError(
            'No tienes paradas asignadas en "$obraNombre". '
            'Pide a tu empresa que te asigne una parada.',
          );
          setState(() => _togglingSwitch = false);
          return;
        }

        final primeraParada = paradasDeObra.first as Map<String, dynamic>;

        // 3. Persistir datos de parada
        await AutoMarkingPrefs.saveParadaData(
          paradaId: int.parse(primeraParada['id'].toString()),
          latitud: (primeraParada['latitud'] ?? primeraParada['lat'] ?? 0.0)
              .toDouble(),
          longitud: (primeraParada['longitud'] ?? primeraParada['lng'] ?? 0.0)
              .toDouble(),
          radio: (primeraParada['radio_metros'] ??
                  primeraParada['radio'] ??
                  50.0)
              .toDouble(),
          paradaNombre: primeraParada['nombre']?.toString() ?? 'Parada',
          obraNombre: obraNombre,
          turnoHoraInicio: '08:00', // Hora de inicio por defecto
        );

        // 4. Activar flag y programar alarma
        await AutoMarkingPrefs.setEnabled(true);
        final scheduled = await AutoMarkingService.scheduleAlarm();

        if (!scheduled) {
          _showError('No se pudo programar la alarma. Intenta de nuevo.');
          await AutoMarkingPrefs.setEnabled(false);
          setState(() => _togglingSwitch = false);
          return;
        }

        setState(() {
          _autoMarking = true;
          _togglingSwitch = false;
        });

        _showSuccess(
          'Marcación automática activada. Se marcará entrada '
          'automáticamente 5 min antes del turno en "$obraNombre".',
        );
      } else {
        // ── Desactivar marcación automática ──────────────────
        await AutoMarkingService.cancelAlarm();

        setState(() {
          _autoMarking = false;
          _togglingSwitch = false;
        });

        _showSuccess('Marcación automática desactivada.');
      }
    } catch (e) {
      debugPrint('Error toggling auto-marking: $e');
      _showError('Error al configurar: $e');
      setState(() => _togglingSwitch = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF38A3A5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final empleado = auth.currentUserProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),

      body: empleado == null
          ? const Center(
              child: Text(
                'No se encontró el perfil',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── FOTO ────────────────────────────────────
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: empleado.fotoUrl != null &&
                            empleado.fotoUrl!.isNotEmpty
                        ? NetworkImage(empleado.fotoUrl!)
                        : null,
                    child: empleado.fotoUrl == null || empleado.fotoUrl!.isEmpty
                        ? Text(
                            (empleado.nombre ?? '').isNotEmpty
                                ? empleado.nombre![0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 30),
                          )
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // ── NOMBRE COMPLETO ─────────────────────────
                  Text(
                    '${empleado.nombre ?? ''} ${empleado.apellido ?? ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // ── ROL ─────────────────────────────────────
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (auth.userRole ?? 'empleado').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── DESCRIPCIÓN ─────────────────────────────
                  if (empleado.descripcion != null &&
                      empleado.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        empleado.descripcion!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── INFORMACIÓN ─────────────────────────────
                  _infoCard(
                    icon: Icons.email_outlined,
                    title: 'Correo',
                    subtitle: empleado.correo,
                  ),

                  if (empleado.telefono != null &&
                      empleado.telefono!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.phone_outlined,
                      title: 'Teléfono',
                      subtitle: empleado.telefono!,
                    ),
                  ],

                  if (empleado.dni != null && empleado.dni!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.badge_outlined,
                      title: 'DNI',
                      subtitle: empleado.dni!,
                    ),
                  ],

                  if (empleado.fechaRegistro != null) ...[
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Miembro desde',
                      subtitle:
                          "${empleado.fechaRegistro!.day.toString().padLeft(2, '0')}/${empleado.fechaRegistro!.month.toString().padLeft(2, '0')}/${empleado.fechaRegistro!.year}",
                    ),
                  ],

                  if (empleado.deviceId != null && empleado.deviceId!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.phonelink_setup_outlined,
                      title: 'ID de Dispositivo Vinculado',
                      subtitle: empleado.deviceId!,
                    ),
                  ],

                  // ── MARCACIÓN AUTOMÁTICA ────────────────────
                  if (auth.userRole == 'empleado' &&
                      empleado.rol == UserRole.employee) ...[
                    const SizedBox(height: 20),
                    _buildAutoMarkingCard(),
                  ],

                  const SizedBox(height: 24),

                  // ── BOTONES ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/empleado/perfil/editar'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Perfil'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AutoMarkingService.cancelAndClearAll();
                        await auth.logout();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                    ),
                  ),
                ],
              ),
            ),

      bottomNavigationBar: const BottomNavbar(
        userRole: 'empleado',
        currentIndex: 2,
      ),
    );
  }

  // ── Widget reutilizable para info cards ────────────────────
  static Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════
  // Widget del switch de marcación automática
  // ═══════════════════════════════════════════════════════════

  Widget _buildAutoMarkingCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _autoMarking
              ? const Color(0xFF38A3A5)
              : const Color(0xFFE5E7EB),
          width: _autoMarking ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _autoMarking
                  ? const Color(0xFF38A3A5).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_alarm_rounded,
              color: _autoMarking
                  ? const Color(0xFF38A3A5)
                  : Colors.grey,
              size: 28,
            ),
          ),
          title: const Text(
            'Marcación automática',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            _autoMarking
                ? 'Activa — se marcará entrada 5 min antes del turno'
                : 'Desactivada — actívala para marcar sin abrir la app',
            style: TextStyle(
              fontSize: 12,
              color: _autoMarking
                  ? const Color(0xFF38A3A5)
                  : const Color(0xFF6B7280),
            ),
          ),
          value: _autoMarking,
          activeColor: const Color(0xFF38A3A5),
          onChanged: (_loadingSwitch || _togglingSwitch)
              ? null
              : (value) => _toggleAutoMarking(value),
        ),
      ),
    );
  }
}
