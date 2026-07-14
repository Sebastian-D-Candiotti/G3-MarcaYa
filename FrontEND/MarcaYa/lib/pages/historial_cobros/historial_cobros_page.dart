// lib/pages/historial_cobros/historial_cobros_page.dart
//
// Pantalla del empleado para consultar historial de cobros y horas acumuladas.
// Consume GET /api/v1/cronograma (cronograma propio del empleado).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

class HistorialCobrosPage extends StatefulWidget {
  const HistorialCobrosPage({super.key});

  @override
  State<HistorialCobrosPage> createState() => _HistorialCobrosPageState();
}

class _HistorialCobrosPageState extends State<HistorialCobrosPage> {
  // ── Colores ─────────────────────────────────────────────────
  static const Color _verde = Color(0xFF38A3A5);
  static const Color _naranja = Color(0xFFF59E0B);
  static const Color _rojo = Color(0xFFE53935);
  static const Color _azulClaro = Color(0xFF1E9FB2);

  List<dynamic> _cronogramas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCronograma();
  }

  Future<void> _cargarCronograma() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final data = await ApiService.instance.obtenerCronogramaEmpleado();

      data.sort((a, b) {
        final fechaA = a['created_at']?.toString() ?? '';
        final fechaB = b['created_at']?.toString() ?? '';
        return fechaB.compareTo(fechaA);
      });

      if (mounted) {
        setState(() {
          _cronogramas = data;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('HistorialCobrosPage: error — $e');
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el historial de cobros.';
          _cargando = false;
        });
      }
    }
  }

  // ── Cálculos de resumen ─────────────────────────────────────
  double get _totalHoras =>
      _cronogramas.fold(0.0, (sum, c) => sum + (c['horas_trabajadas'] as num? ?? 0).toDouble());

  double get _totalMonto =>
      _cronogramas.fold(0.0, (sum, c) => sum + (c['monto_total'] as num? ?? 0).toDouble());

  // ── Helpers de presentación ─────────────────────────────────

  String _formatPeriodo(String? periodo) {
    if (periodo == null || periodo.isEmpty) return '—';
    // periodo viene como "2026-07-01_2026-07-15"
    final parts = periodo.split('_');
    if (parts.length == 2) {
      return '${_formatFecha(parts[0])} → ${_formatFecha(parts[1])}';
    }
    return periodo;
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Color _colorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pagado':
        return _verde;
      case 'sincronizado':
        return _azulClaro;
      case 'aprobado':
        return const Color(0xFF6366F1);
      case 'pendiente':
      default:
        return _naranja;
    }
  }

  IconData _iconoEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pagado':
        return Icons.check_circle_rounded;
      case 'sincronizado':
        return Icons.sync_rounded;
      case 'aprobado':
        return Icons.thumb_up_rounded;
      case 'pendiente':
      default:
        return Icons.schedule_rounded;
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Historial de Cobros',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _cargarCronograma,
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
            Text('Cargando historial de cobros...'),
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
                onPressed: _cargarCronograma,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (_cronogramas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'No hay cobros registrados',
                style: TextStyle(fontSize: 17, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tus pagos aparecerán aquí cuando la empresa\ngenere la planilla',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/empleado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
      onRefresh: _cargarCronograma,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ── Resumen superior ─────────────────────────────────
          _buildResumenCard(),
          const SizedBox(height: 16),

          // ── Lista de cronogramas ─────────────────────────────
          const Text(
            'Detalle por período',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          ..._cronogramas.map((c) => _buildCronogramaCard(c)),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Acumulado',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horas Trabajadas',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalHoras.toStringAsFixed(1)} hrs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white24,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monto Total',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'S/ ${_totalMonto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_cronogramas.length} período(s) registrado(s)',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCronogramaCard(dynamic cronograma) {
    final estado = cronograma['estado']?.toString() ?? 'pendiente';
    final colorEst = _colorEstado(estado);
    final iconoEst = _iconoEstado(estado);
    final periodo = _formatPeriodo(cronograma['periodo']?.toString());
    final horas = (cronograma['horas_trabajadas'] as num? ?? 0).toDouble();
    final monto = (cronograma['monto_total'] as num? ?? 0).toDouble();
    final tarifa = (cronograma['tarifa_hora'] as num? ?? 0).toDouble();
    final obraNombre = cronograma['obra_nombre']?.toString() ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorEst.withValues(alpha: 0.25),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Período + estado
            Row(
              children: [
                const Icon(Icons.date_range_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    periodo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                _estadoChip(estado, colorEst, iconoEst),
              ],
            ),

            const SizedBox(height: 12),

            // Obra
            Row(
              children: [
                const Icon(Icons.business_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  obraNombre,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Métricas
            Row(
              children: [
                _metricaBox('Horas', '${horas.toStringAsFixed(1)}h', Icons.access_time_rounded),
                const SizedBox(width: 10),
                _metricaBox('Tarifa', 'S/${tarifa.toStringAsFixed(0)}/h', Icons.monetization_on_outlined),
                const SizedBox(width: 10),
                _metricaBox('Total', 'S/${monto.toStringAsFixed(2)}', Icons.payments_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoChip(String estado, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            estado[0].toUpperCase() + estado.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricaBox(String label, String valor, IconData icono) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icono, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
