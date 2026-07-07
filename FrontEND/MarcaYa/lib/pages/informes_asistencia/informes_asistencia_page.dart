import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/informe_asistencia.dart';
import '../../providers/informes_asistencia_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/pdf_download.dart';

class InformesAsistenciaPage extends StatefulWidget {
  const InformesAsistenciaPage({super.key});

  @override
  State<InformesAsistenciaPage> createState() => _InformesAsistenciaPageState();
}

class _InformesAsistenciaPageState extends State<InformesAsistenciaPage> {
  String _tipoPeriodo = 'DIARIO';
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InformesAsistenciaProvider>().cargarHistorial(
            tipoPeriodo: 'MENSUAL',
            anio: _fechaInicio.year,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informes de asistencia'),
      ),
      body: Consumer<InformesAsistenciaProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.cargarHistorial(
              tipoPeriodo: 'MENSUAL',
              anio: _fechaInicio.year,
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.cargando) const LinearProgressIndicator(),
                if (provider.error != null) _ErrorBanner(message: provider.error!),
                _buildControls(provider),
                const SizedBox(height: 16),
                _buildPreview(provider.vistaPrevia),
                const SizedBox(height: 20),
                _buildHistorial(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(InformesAsistenciaProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'DIARIO',
                    icon: Icon(Icons.today),
                    label: Text('Diario'),
                  ),
                  ButtonSegment(
                    value: 'SEMANAL',
                    icon: Icon(Icons.view_week),
                    label: Text('Semanal'),
                  ),
                  ButtonSegment(
                    value: 'MENSUAL',
                    icon: Icon(Icons.calendar_month),
                    label: Text('Mensual'),
                  ),
                ],
                selected: {_tipoPeriodo},
                onSelectionChanged: provider.cargando
                    ? null
                    : (value) {
                        setState(() {
                          _tipoPeriodo = value.first;
                          _normalizarFechas();
                        });
                      },
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(_formatDate(_fechaInicio)),
                  onPressed: provider.cargando ? null : () => _pickDate(inicio: true),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event_available),
                  label: Text(_formatDate(_fechaFin)),
                  onPressed: provider.cargando || _tipoPeriodo == 'DIARIO' || _tipoPeriodo == 'MENSUAL'
                      ? null
                      : () => _pickDate(inicio: false),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Generar'),
                  onPressed: provider.cargando ? null : () => _generarVistaPrevia(provider),
                ),
                if (_tipoPeriodo == 'MENSUAL')
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.lock_clock),
                    label: const Text('Cerrar mes'),
                    onPressed: provider.cargando ? null : () => _cerrarMes(provider),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(Map<String, dynamic>? snapshot) {
    if (snapshot == null) return const SizedBox.shrink();
    final resumen = _asMap(snapshot['resumen']);
    final periodo = _asMap(snapshot['periodo']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${periodo['tipo'] ?? _tipoPeriodo}: ${periodo['fecha_inicio'] ?? ''} - ${periodo['fecha_fin'] ?? ''}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _metricGrid(resumen),
      ],
    );
  }

  Widget _buildHistorial(InformesAsistenciaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Historial mensual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh),
              onPressed: provider.cargando
                  ? null
                  : () => provider.cargarHistorial(
                        tipoPeriodo: 'MENSUAL',
                        anio: _fechaInicio.year,
                      ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (provider.historial.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('Sin informes cerrados.'),
          )
        else
          ...provider.historial.map((informe) => _InformeTile(
                informe: informe,
                onDownload: () => _descargarPdf(provider, informe),
              )),
      ],
    );
  }

  Widget _metricGrid(Map<String, dynamic> resumen) {
    final items = [
      _MetricData('Empleados', resumen['empleados_incluidos'] ?? 0, Icons.groups),
      _MetricData('Marcaciones', resumen['total_marcaciones'] ?? 0, Icons.fact_check),
      _MetricData('Horas', resumen['horas_trabajadas'] ?? 0, Icons.timer),
      _MetricData('Tardanzas', resumen['tardanzas'] ?? 0, Icons.schedule),
      _MetricData('Inasistencias', resumen['inasistencias'] ?? 0, Icons.person_off),
      _MetricData('GPS valido', '${resumen['porcentaje_gps_valido'] ?? 0}%', Icons.gps_fixed),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        mainAxisExtent: 92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => _MetricTile(data: items[index]),
    );
  }

  Future<void> _pickDate({required bool inicio}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: inicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (selected == null) return;

    setState(() {
      if (inicio) {
        _fechaInicio = selected;
      } else {
        _fechaFin = selected;
      }
      _normalizarFechas();
    });
  }

  Future<void> _generarVistaPrevia(InformesAsistenciaProvider provider) async {
    await provider.generarVistaPrevia(
      tipoPeriodo: _tipoPeriodo,
      fechaInicio: _formatDate(_fechaInicio),
      fechaFin: _formatDate(_fechaFin),
    );
  }

  Future<void> _cerrarMes(InformesAsistenciaProvider provider) async {
    final informe = await provider.cerrarMes(
      anio: _fechaInicio.year,
      mes: _fechaInicio.month,
    );
    if (!mounted || informe == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mes cerrado correctamente.')),
    );
  }

  Future<void> _descargarPdf(
    InformesAsistenciaProvider provider,
    InformeAsistencia informe,
  ) async {
    final bytes = await provider.descargarPdf(informe);
    if (!mounted || bytes == null) return;

    final filename = provider.ultimoPdfNombre ?? 'informe_asistencia.pdf';
    final downloaded = await downloadPdfBytes(filename: filename, bytes: bytes);
    if (!mounted) return;

    final kb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          downloaded ? 'PDF descargado.' : 'PDF generado: $kb KB.',
        ),
      ),
    );
  }

  void _normalizarFechas() {
    if (_tipoPeriodo == 'DIARIO') {
      _fechaFin = _fechaInicio;
    } else if (_tipoPeriodo == 'MENSUAL') {
      _fechaInicio = DateTime(_fechaInicio.year, _fechaInicio.month);
      _fechaFin = DateTime(_fechaInicio.year, _fechaInicio.month + 1, 0);
    } else if (_tipoPeriodo == 'SEMANAL') {
      if (_fechaFin.isBefore(_fechaInicio) ||
          _fechaFin.difference(_fechaInicio).inDays > 6) {
        _fechaFin = _fechaInicio.add(const Duration(days: 6));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, val) => MapEntry(key.toString(), val));
    return <String, dynamic>{};
  }
}

class _InformeTile extends StatelessWidget {
  const _InformeTile({
    required this.informe,
    required this.onDownload,
  });

  final InformeAsistencia informe;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
        title: Text(
          '${_format(informe.fechaInicio)} - ${_format(informe.fechaFin)}',
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${informe.estado} | v${informe.version} | ${informe.checksum}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Descargar PDF',
          icon: const Icon(Icons.download),
          onPressed: onDownload,
        ),
      ),
    );
  }

  String _format(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(data.icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    data.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon);

  final String label;
  final Object value;
  final IconData icon;
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
