// lib/pages/informe_ia/informe_ia_page.dart
//
// US-NUEVA-06: Pantalla de Informe Ejecutivo con IA.
// Permite a la empresa seleccionar un rango de fechas, enviar datos
// anónimos al backend que consulta la API de Gemini, y visualizar
// el informe generado con análisis de tendencias y sugerencias.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';

class InformeIAPage extends StatefulWidget {
  const InformeIAPage({super.key});

  @override
  State<InformeIAPage> createState() => _InformeIAPageState();
}

class _InformeIAPageState extends State<InformeIAPage>
    with SingleTickerProviderStateMixin {
  // ── Colores de marca ─────────────────────────────────────────
  static const Color _azul = Color(0xFF0B4F7A);
  static const Color _verde = Color(0xFF38A3A5);
  static const Color _naranja = Color(0xFFF59E0B);
  static const Color _morado = Color(0xFF7C3AED);
  static const Color _fondoClaro = Color(0xFFF5F7FA);

  // ── Estado ───────────────────────────────────────────────────
  DateTimeRange? _rangoFechas;
  bool _generando = false;
  String? _informe;
  String? _error;
  Map<String, dynamic>? _datosAnalizados;
  Map<String, dynamic>? _periodo;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Mensajes que rotan mientras la IA genera
  static const List<String> _mensajesCarga = [
    'Recopilando datos de asistencia...',
    'Anonimizando información...',
    'Analizando tendencias de puntualidad...',
    'Generando informe ejecutivo...',
    'Finalizando recomendaciones...',
  ];
  int _mensajeIndex = 0;

  @override
  void initState() {
    super.initState();
    // Rango por defecto: últimos 30 días
    final ahora = DateTime.now();
    _rangoFechas = DateTimeRange(
      start: ahora.subtract(const Duration(days: 30)),
      end: ahora,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Selección de rango de fechas ──────────────────────────────
  Future<void> _seleccionarRango() async {
    final ahora = DateTime.now();
    final rango = await showDateRangePicker(
      context: context,
      firstDate: ahora.subtract(const Duration(days: 365)),
      lastDate: ahora,
      initialDateRange: _rangoFechas,
      locale: const Locale('es', 'PE'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _azul,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (rango != null) {
      setState(() => _rangoFechas = rango);
    }
  }

  // ── Generar informe ────────────────────────────────────────────
  Future<void> _generarInforme() async {
    if (_rangoFechas == null) return;

    setState(() {
      _generando = true;
      _informe = null;
      _error = null;
      _datosAnalizados = null;
      _periodo = null;
      _mensajeIndex = 0;
    });

    // Rotar mensajes de carga cada 3 segundos
    _rotarMensajes();

    try {
      final fechaInicio =
          _rangoFechas!.start.toString().split(' ')[0]; // YYYY-MM-DD
      final fechaFin =
          _rangoFechas!.end.toString().split(' ')[0];

      final resultado = await ApiService.instance.generarInformeIA(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      if (mounted) {
        setState(() {
          _informe = resultado['informe'] as String?;
          _datosAnalizados =
              resultado['datos_analizados'] as Map<String, dynamic>?;
          _periodo = resultado['periodo'] as Map<String, dynamic>?;
          _generando = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.mensaje;
          _generando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error inesperado: $e';
          _generando = false;
        });
      }
    }
  }

  void _rotarMensajes() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_generando && mounted) {
        setState(() {
          _mensajeIndex =
              (_mensajeIndex + 1) % _mensajesCarga.length;
        });
        _rotarMensajes();
      }
    });
  }

  // ── Formatear fecha ────────────────────────────────────────────
  String _formatFecha(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  // ── BUILD ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoClaro,
      appBar: AppBar(
        title: const Text(
          'Informe Ejecutivo IA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _azul,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado con ícono IA ──────────────────────
            _buildEncabezado(),

            const SizedBox(height: 20),

            // ── Selector de rango ───────────────────────────
            _buildSelectorRango(),

            const SizedBox(height: 20),

            // ── Botón generar ───────────────────────────────
            _buildBotonGenerar(),

            const SizedBox(height: 24),

            // ── Contenido ───────────────────────────────────
            if (_generando) _buildEstadoCarga(),
            if (_error != null) _buildError(),
            if (_informe != null) ...[
              _buildResumenDatos(),
              const SizedBox(height: 16),
              _buildInforme(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 0,
      ),
    );
  }

  // ── Encabezado ─────────────────────────────────────────────────

  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B4F7A), Color(0xFF38A3A5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _azul.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente de IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Genera informes ejecutivos con análisis '
                  'inteligente de puntualidad y sugerencias.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Selector de rango de fechas ────────────────────────────────

  Widget _buildSelectorRango() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.date_range_rounded, color: _azul, size: 20),
              SizedBox(width: 8),
              Text(
                'Período del informe',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _generando ? null : _seleccionarRango,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: _azul),
                  const SizedBox(width: 12),
                  Text(
                    _rangoFechas != null
                        ? '${_formatFecha(_rangoFechas!.start)}  →  ${_formatFecha(_rangoFechas!.end)}'
                        : 'Seleccionar fechas',
                    style: TextStyle(
                      fontSize: 14,
                      color: _rangoFechas != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón generar informe ──────────────────────────────────────

  Widget _buildBotonGenerar() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _generando ? null : _generarInforme,
        icon: _generando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white70,
                ),
              )
            : const Icon(Icons.auto_awesome, size: 22),
        label: Text(
          _generando
              ? 'Generando...'
              : 'Generar Informe Ejecutivo con IA',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _morado,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _morado.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: _generando ? 0 : 4,
          shadowColor: _morado.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // ── Estado de carga con animación ──────────────────────────────

  Widget _buildEstadoCarga() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            // Ícono con animación de pulso
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_morado, Color(0xFF38A3A5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _morado.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _mensajesCarga[_mensajeIndex],
                key: ValueKey<int>(_mensajeIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esto puede tomar unos segundos...',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_morado),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudo generar el informe',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB91C1C),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Resumen de datos analizados ────────────────────────────────

  Widget _buildResumenDatos() {
    if (_datosAnalizados == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: _verde, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Datos analizados',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              if (_periodo != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _azul.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_periodo!['inicio']} → ${_periodo!['fin']}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _azul,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _datoBadge(
                Icons.fact_check_rounded,
                '${_datosAnalizados!['total_registros'] ?? 0}',
                'Registros',
                _azul,
              ),
              const SizedBox(width: 10),
              _datoBadge(
                Icons.people_rounded,
                '${_datosAnalizados!['total_empleados'] ?? 0}',
                'Empleados',
                _verde,
              ),
              const SizedBox(width: 10),
              _datoBadge(
                Icons.location_on_rounded,
                '${_datosAnalizados!['total_paradas'] ?? 0}',
                'Paradas',
                _naranja,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datoBadge(
      IconData icono, String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Informe renderizado ────────────────────────────────────────

  Widget _buildInforme() {
    if (_informe == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del informe
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_morado, Color(0xFF38A3A5)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Informe Generado por IA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              // Botón copiar
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                color: const Color(0xFF6B7280),
                tooltip: 'Copiar informe',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _informe!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Informe copiado al portapapeles'),
                      backgroundColor: _verde,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),

          // Contenido del informe (renderizado simple de Markdown)
          _renderizarMarkdown(_informe!),
        ],
      ),
    );
  }

  /// Renderiza Markdown básico como widgets Flutter.
  /// Soporta: headings (##, ###), bold (**), bullet points (- ), y párrafos.
  Widget _renderizarMarkdown(String texto) {
    final lineas = texto.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lineas.length; i++) {
      final linea = lineas[i].trimRight();

      // Líneas vacías → espacio
      if (linea.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Heading ##
      if (linea.startsWith('## ')) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 14));
        }
        widgets.add(
          Text(
            linea.substring(3),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _azul,
            ),
          ),
        );
        widgets.add(Container(
          height: 2,
          width: 40,
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_morado, _verde],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ));
        continue;
      }

      // Heading ###
      if (linea.startsWith('### ')) {
        widgets.add(const SizedBox(height: 10));
        widgets.add(
          Text(
            linea.substring(4),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        );
        continue;
      }

      // Heading #
      if (linea.startsWith('# ')) {
        widgets.add(
          Text(
            linea.substring(2),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _azul,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Bullet points
      if (linea.trimLeft().startsWith('- ') ||
          linea.trimLeft().startsWith('* ')) {
        final indent = linea.length - linea.trimLeft().length;
        final contenido = linea.trimLeft().substring(2);
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: indent > 0 ? 20.0 : 8.0, top: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 7, right: 10),
                  decoration: BoxDecoration(
                    color: indent > 0 ? _verde : _morado,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(child: _richText(contenido)),
              ],
            ),
          ),
        );
        continue;
      }

      // Numbered list
      final numMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(linea.trimLeft());
      if (numMatch != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 10, top: 1),
                  decoration: BoxDecoration(
                    color: _morado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      numMatch.group(1)!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _morado,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _richText(numMatch.group(2)!)),
              ],
            ),
          ),
        );
        continue;
      }

      // Separador ---
      if (RegExp(r'^-{3,}$').hasMatch(linea.trim())) {
        widgets.add(const Divider(
          color: Color(0xFFE5E7EB),
          height: 24,
        ));
        continue;
      }

      // Párrafo normal
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 2),
        child: _richText(linea),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Convierte texto con **bold** en RichText
  Widget _richText(String texto) {
    final partes = texto.split(RegExp(r'\*\*'));
    if (partes.length <= 1) {
      return Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF374151),
        ),
      );
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < partes.length; i++) {
      spans.add(TextSpan(
        text: partes[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.w700 : FontWeight.normal,
          color: i.isOdd ? const Color(0xFF1F2937) : const Color(0xFF374151),
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.6),
        children: spans,
      ),
    );
  }
}
