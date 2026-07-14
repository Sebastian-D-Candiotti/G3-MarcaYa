// lib/pages/nomina_empresa/nomina_empresa_page.dart
//
// Panel de administración de nómina para la empresa.
// Permite:
//   1. Generar planilla grupal para un período
//   2. Ver la planilla con detalle por empleado
//   3. Procesar justificaciones (marcar como aprobado)
//   4. Disparar sincronización contable simulada (/api/v1/cronograma/sincronizar)

import 'package:flutter/material.dart';

import '../../components/bottom_navbar.dart';
import '../../components/empty_state_placeholder.dart';
import '../../src/api_service.dart';

class NominaEmpresaPage extends StatefulWidget {
  const NominaEmpresaPage({super.key});

  @override
  State<NominaEmpresaPage> createState() => _NominaEmpresaPageState();
}

class _NominaEmpresaPageState extends State<NominaEmpresaPage> {
  // ── Colores ─────────────────────────────────────────────────
  static const Color _azul = Color(0xFF0B4F7A);
  static const Color _verde = Color(0xFF38A3A5);
  static const Color _naranja = Color(0xFFF59E0B);
  static const Color _azulClaro = Color(0xFF1E9FB2);

  // ── Estado ──────────────────────────────────────────────────
  List<dynamic> _cronogramas = [];
  bool _cargando = true;
  bool _generando = false;
  bool _sincronizando = false;
  String? _error;

  // ── Formulario de generación ────────────────────────────────
  DateTime? _periodoInicio;
  DateTime? _periodoFin;
  final _tarifaCtrl = TextEditingController(text: '15.00');

  @override
  void initState() {
    super.initState();
    _cargarCronograma();
  }

  @override
  void dispose() {
    _tarifaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCronograma() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final data = await ApiService.instance.obtenerCronogramaEmpresa();

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
      debugPrint('NominaEmpresaPage: error — $e');
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar la planilla.';
          _cargando = false;
        });
      }
    }
  }

  // ── Generar planilla ────────────────────────────────────────

  Future<void> _seleccionarFecha(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio
          ? (_periodoInicio ?? DateTime.now().subtract(const Duration(days: 15)))
          : (_periodoFin ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: esInicio ? 'Inicio del período' : 'Fin del período',
    );

    if (fecha != null && mounted) {
      setState(() {
        if (esInicio) {
          _periodoInicio = fecha;
        } else {
          _periodoFin = fecha;
        }
      });
    }
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _toIso(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _generarPlanilla() async {
    if (_periodoInicio == null || _periodoFin == null) {
      _showSnack('Selecciona el período completo', Colors.red.shade700);
      return;
    }

    if (_periodoFin!.isBefore(_periodoInicio!)) {
      _showSnack('La fecha fin debe ser posterior al inicio', Colors.red.shade700);
      return;
    }

    final tarifa = double.tryParse(_tarifaCtrl.text) ?? 15.0;

    setState(() => _generando = true);

    try {
      final resultado = await ApiService.instance.generarCronograma(
        periodoInicio: _toIso(_periodoInicio!),
        periodoFin: _toIso(_periodoFin!),
        tarifaHora: tarifa,
      );

      final total = resultado['total_registros'] ?? 0;
      _showSnack(
        'Planilla generada: $total registro(s)',
        _verde,
      );

      await _cargarCronograma();
    } catch (e) {
      _showSnack('Error al generar: $e', Colors.red.shade700);
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  // ── Sincronización ──────────────────────────────────────────

  Future<void> _sincronizar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sincronizar con sistema contable'),
        content: const Text(
          '¿Deseas enviar todos los registros pendientes/aprobados '
          'al sistema contable?\n\n'
          'Esta acción marcará los registros como "sincronizado".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _azul),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _sincronizando = true);

    try {
      final resultado = await ApiService.instance.sincronizarCronograma();
      final total = resultado['total_sincronizados'] ?? 0;

      _showSnack(
        total > 0
            ? '✅ $total registro(s) sincronizado(s)'
            : 'No hay registros pendientes',
        total > 0 ? _verde : _naranja,
      );

      await _cargarCronograma();
    } catch (e) {
      _showSnack('Error al sincronizar: $e', Colors.red.shade700);
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Helpers de presentación ─────────────────────────────────

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

  // ── Estadísticas resumen ────────────────────────────────────

  int get _totalEmpleados {
    final ids = _cronogramas.map((c) => c['empleado_id']).toSet();
    return ids.length;
  }

  double get _totalHoras =>
      _cronogramas.fold(0.0, (s, c) => s + (c['horas_trabajadas'] as num? ?? 0).toDouble());

  double get _totalMonto =>
      _cronogramas.fold(0.0, (s, c) => s + (c['monto_total'] as num? ?? 0).toDouble());

  int get _pendientes =>
      _cronogramas.where((c) => c['estado'] == 'pendiente' || c['estado'] == 'aprobado').length;

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Gestión de Nómina',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _azul,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _cargarCronograma,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _cargarCronograma,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildResumenCards(),
                      const SizedBox(height: 20),
                      _buildGenerarSection(),
                      const SizedBox(height: 20),
                      _buildPlanillaSection(),
                      const SizedBox(height: 20),
                      _buildSyncSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 0,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 52),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(fontSize: 16, color: Color(0xFFE53935))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cargarCronograma,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ── Resumen KPIs ────────────────────────────────────────────

  Widget _buildResumenCards() {
    return Row(
      children: [
        _kpiCard('Empleados', '$_totalEmpleados', Icons.group_rounded, _azul),
        const SizedBox(width: 8),
        _kpiCard('Horas', '${_totalHoras.toStringAsFixed(0)}h', Icons.access_time_rounded, _verde),
        const SizedBox(width: 8),
        _kpiCard('Monto', 'S/${_totalMonto.toStringAsFixed(0)}', Icons.payments_rounded, _azulClaro),
        const SizedBox(width: 8),
        _kpiCard('Pendientes', '$_pendientes', Icons.pending_actions_rounded, _naranja),
      ],
    );
  }

  Widget _kpiCard(String label, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sección: Generar Planilla ───────────────────────────────

  Widget _buildGenerarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _azul.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calculate_rounded, color: _azul, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Generar Planilla',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fecha inicio
          Row(
            children: [
              Expanded(
                child: _fechaSelector(
                  label: 'Inicio',
                  fecha: _periodoInicio,
                  onTap: () => _seleccionarFecha(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fechaSelector(
                  label: 'Fin',
                  fecha: _periodoFin,
                  onTap: () => _seleccionarFecha(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tarifa por hora
          TextField(
            controller: _tarifaCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Tarifa por hora (S/)',
              prefixIcon: const Icon(Icons.monetization_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          const SizedBox(height: 16),

          // Botón generar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generando ? null : _generarPlanilla,
              icon: _generando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_generando ? 'Calculando...' : 'Calcular Planilla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fechaSelector({
    required String label,
    required DateTime? fecha,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: _azul),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                  ),
                  Text(
                    _formatFecha(fecha),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: fecha != null ? _azul : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sección: Planilla Actual ────────────────────────────────

  Widget _buildPlanillaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.table_chart_rounded, color: _verde, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Planilla Actual',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Text(
                '${_cronogramas.length} registros',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_cronogramas.isEmpty)
            const EmptyStatePlaceholder(
              isCompact: true,
              icon: Icons.payments_outlined,
              title: 'Planilla no calculada',
              description: 'Elige un rango de fechas en la parte superior y presiona "Calcular Planilla" para ver los detalles de pago.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateColor.resolveWith(
                  (_) => _azul.withValues(alpha: 0.08),
                ),
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Empleado', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Obra', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Horas', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _cronogramas.map<DataRow>((c) {
                  final estado = c['estado']?.toString() ?? 'pendiente';
                  final colorEst = _colorEstado(estado);

                  return DataRow(
                    cells: [
                      DataCell(Text(
                        c['empleado_nombre']?.toString() ?? '—',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      )),
                      DataCell(Text(c['obra_nombre']?.toString() ?? '—')),
                      DataCell(Text(
                        '${(c['horas_trabajadas'] as num? ?? 0).toStringAsFixed(1)}h',
                      )),
                      DataCell(Text(
                        'S/${(c['monto_total'] as num? ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorEst.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            estado[0].toUpperCase() + estado.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorEst,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ── Sección: Sincronización ─────────────────────────────────

  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _azulClaro.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _azulClaro.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.sync_rounded, color: _azulClaro, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sincronización Contable',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Enviar registros al sistema contable externo',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_sincronizando || _pendientes == 0) ? null : _sincronizar,
              icon: _sincronizando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_rounded),
              label: Text(
                _sincronizando
                    ? 'Sincronizando...'
                    : _pendientes == 0
                        ? 'No hay registros pendientes'
                        : 'Sincronizar $_pendientes registro(s)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _azulClaro,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
