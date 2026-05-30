import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
import '../../core/theme/app_theme.dart';
import 'solicitud_model.dart';
import 'ver_solicitudes_styles.dart';
import 'components/solicitud_banner.dart';
import 'components/solicitud_card.dart';
import 'components/solicitud_perfil_sheet.dart';

/// Income requests list screen. Composed from reusable components.
class VerSolicitudesPage extends StatefulWidget {
  const VerSolicitudesPage({super.key});

  @override
  State<VerSolicitudesPage> createState() => _VerSolicitudesPageState();
}

class _VerSolicitudesPageState extends State<VerSolicitudesPage> {
  // TODO: replace with real backend data
  static final List<SolicitudIngreso> _solicitudes = [
    SolicitudIngreso(
      id: '1',
      nombre: 'Mauricio López',
      dni: '98765432',
      fecha: '16 May 2026',
      iniciales: 'ML',
      avatarColor: const Color(0xFF42A5F5),
      valoracionPromedio: 4.5,
    ),
    SolicitudIngreso(
      id: '2',
      nombre: 'Eusebio García',
      dni: '11223355',
      fecha: '15 May 2026',
      iniciales: 'EG',
      avatarColor: const Color(0xFF66BB6A),
      valoracionPromedio: 3.8,
    ),
    SolicitudIngreso(
      id: '3',
      nombre: 'Adriano Pérez',
      dni: '44556677',
      fecha: '15 May 2026',
      iniciales: 'AP',
      avatarColor: const Color(0xFFAB47BC),
      valoracionPromedio: 4.9,
    ),
    SolicitudIngreso(
      id: '4',
      nombre: 'Dominic Ríos',
      dni: '88990011',
      fecha: '14 May 2026',
      iniciales: 'DR',
      avatarColor: const Color(0xFFEF5350),
      valoracionPromedio: 4.2,
    ),
    SolicitudIngreso(
      id: '5',
      nombre: 'Jairo Fuentes',
      dni: '22334455',
      fecha: '13 May 2026',
      iniciales: 'JF',
      avatarColor: const Color(0xFFFF7043),
      valoracionPromedio: 4.0,
    ),
  ];

  int get _pendientes =>
      _solicitudes.where((s) => s.estado == EstadoSolicitud.pendiente).length;

  // ── Actions ─────────────────────────────────────────────────

  void _aceptar(SolicitudIngreso s) {
    setState(() => s.estado = EstadoSolicitud.aceptada);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s.nombre} fue aceptado y está ahora ACTIVO'),
        backgroundColor: VerSolicitudesStyles.acceptColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _rechazar(SolicitudIngreso s) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VerSolicitudesStyles.cardRadius)),
        title: const Text('Rechazar solicitud',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas rechazar a ${s.nombre}?',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Motivo del rechazo (opcional)',
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: VerSolicitudesStyles.rejectColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                s.estado = EstadoSolicitud.rechazada;
                s.motivoRechazo = controller.text.trim().isEmpty
                    ? null
                    : controller.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solicitud de ${s.nombre} rechazada'),
                  backgroundColor: VerSolicitudesStyles.rejectColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VerSolicitudesStyles.rejectColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _verPerfil(SolicitudIngreso s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SolicitudPerfilSheet(solicitud: s),
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Solicitudes de ingreso')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (_pendientes > 0) ...[
            SolicitudBanner(pendientes: _pendientes),
            const SizedBox(height: 12),
          ],
          ..._solicitudes.map((s) => SolicitudCard(
                solicitud: s,
                onVerPerfil: () => _verPerfil(s),
                onAceptar: () => _aceptar(s),
                onRechazar: () => _rechazar(s),
              )),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 3,
      ),
    );
  }
}
