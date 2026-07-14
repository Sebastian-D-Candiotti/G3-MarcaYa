// lib/pages/historial_asistencias/historial_asistencias_page.dart
//
// Historial de marcaciones del empleado autenticado.
// Destino del deep-link al presionar la notificación local (US-NUEVA-09 CA-3).
//
// Muestra cada registro con: tipo (Entrada/Salida), hora, parada y
// validez GPS (ícono verde/naranja).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';

class HistorialAsistenciasPage extends StatefulWidget {
  const HistorialAsistenciasPage({super.key});

  @override
  State<HistorialAsistenciasPage> createState() =>
      _HistorialAsistenciasPageState();
}

class _HistorialAsistenciasPageState extends State<HistorialAsistenciasPage> {
  // ── colores de marca ────────────────────────────────────────
  static const Color _azul = Color(0xFF0B4F7A);
  static const Color _verde = Color(0xFF38A3A5);
  static const Color _naranja = Color(0xFFF59E0B);
  static const Color _rojo = Color(0xFFE53935);

  List<dynamic> _registros = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  // ── Carga de datos ──────────────────────────────────────────

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final empleadoId = auth.currentUserProfile?.employeeId;

      List<dynamic> data;

      if (auth.userRole == 'empleado') {
        data = await ApiService.instance.obtenerHistorial();
      } else if (empleadoId != null) {
        data = await ApiService.instance
            .obtenerAsistenciasEmpleado(int.parse(empleadoId));
      } else {
        data = await ApiService.instance.obtenerHistorial();
      }

      // Ordenar por fecha descendente si el campo existe
      data.sort((a, b) {
        final fechaA = a['hora_entrada'] ?? a['created_at'] ?? '';
        final fechaB = b['hora_entrada'] ?? b['created_at'] ?? '';
        return fechaB.toString().compareTo(fechaA.toString());
      });

      if (mounted) {
        setState(() {
          _registros = data;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('HistorialAsistenciasPage: error — $e');
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el historial. Intenta de nuevo.';
          _cargando = false;
        });
      }
    }
  }

  // ── Helpers de presentación ─────────────────────────────────

  String _formatearFechaHora(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final fecha =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final hora =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$fecha $hora';
    } catch (_) {
      return iso;
    }
  }

  String _tipoTexto(dynamic registro) {
    final tipo = registro['tipo']?.toString().toLowerCase() ?? '';
    if (tipo.contains('entrada') || tipo == 'in') return 'Entrada';
    if (tipo.contains('salida') || tipo == 'out') return 'Salida';
    // Si el registro tiene hora_entrada pero no hora_salida, es entrada
    if (registro['hora_salida'] == null && registro['hora_entrada'] != null) {
      return 'Entrada';
    }
    return tipo.isNotEmpty ? tipo : 'Marcación';
  }

  bool _validaGps(dynamic registro) {
    return registro['valida_gps'] == true ||
        registro['gps_valido'] == true ||
        registro['dentro_geocerca'] == true;
  }

  Color _colorTipo(String tipo) {
    return tipo.toLowerCase().contains('entrada') ? _azul : _verde;
  }

  IconData _iconoTipo(String tipo) {
    return tipo.toLowerCase().contains('entrada')
        ? Icons.login_rounded
        : Icons.logout_rounded;
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Historial de Marcaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _azul,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _cargarHistorial,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empleado',
        currentIndex: 0,
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando historial...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: _rojo, size: 52),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: _rojo),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarHistorial,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(backgroundColor: _azul),
              ),
            ],
          ),
        ),
      );
    }

    if (_registros.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_toggle_off_rounded,
                  size: 64, color: Color(0xFFBDBDBD)),
              const SizedBox(height: 16),
              const Text(
                'No hay marcaciones registradas',
                style: TextStyle(fontSize: 17, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tus marcaciones aparecerán aquí',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/empleado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azul,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ir al Inicio'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarHistorial,
      color: _azul,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _registros.length,
        itemBuilder: (context, index) => _buildRegistroCard(_registros[index]),
      ),
    );
  }

  Widget _buildRegistroCard(dynamic registro) {
    final tipo = _tipoTexto(registro);
    final validoGps = _validaGps(registro);
    final colorTipo = _colorTipo(tipo);
    final iconoTipo = _iconoTipo(tipo);

    // Hora del evento
    final horaEntrada = _formatearFechaHora(
      registro['hora_entrada']?.toString() ?? registro['created_at']?.toString(),
    );
    final horaSalida = _formatearFechaHora(
      registro['hora_salida']?.toString(),
    );

    // Parada/obra
    final paradaNombre =
        registro['parada']?['nombre']?.toString() ??
        registro['parada_nombre']?.toString() ??
        registro['nombre']?.toString() ??
        '—';
    final obraNombre =
        registro['obra']?['nombre']?.toString() ??
        registro['obra_nombre']?.toString() ??
        '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorTipo.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ícono tipo ─────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorTipo.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconoTipo, color: colorTipo, size: 26),
            ),

            const SizedBox(width: 14),

            // ── Datos ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo + validez GPS
                  Row(
                    children: [
                      Text(
                        tipo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorTipo,
                        ),
                      ),
                      const Spacer(),
                      _gpsChip(validoGps),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Parada y obra
                  if (paradaNombre != '—') ...[
                    _infoRow(Icons.location_on_outlined, paradaNombre),
                    if (obraNombre.isNotEmpty)
                      _infoRow(Icons.business_outlined, obraNombre),
                  ],

                  const SizedBox(height: 6),

                  // Hora de entrada
                  _infoRow(Icons.login_rounded, 'Entrada: $horaEntrada',
                      color: _azul),

                  // Hora de salida (si existe)
                  if (registro['hora_salida'] != null)
                    _infoRow(Icons.logout_rounded, 'Salida: $horaSalida',
                        color: _verde),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gpsChip(bool valido) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: valido
            ? const Color(0xFF38A3A5).withValues(alpha: 0.12)
            : _naranja.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: valido ? _verde : _naranja,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            valido ? Icons.gps_fixed : Icons.gps_not_fixed,
            size: 12,
            color: valido ? _verde : _naranja,
          ),
          const SizedBox(width: 4),
          Text(
            valido ? 'GPS ✓' : 'Fuera de zona',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valido ? _verde : _naranja,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String texto, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? const Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                color: color ?? const Color(0xFF6B7280),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
