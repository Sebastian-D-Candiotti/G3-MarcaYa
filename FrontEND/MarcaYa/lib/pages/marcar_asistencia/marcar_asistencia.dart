import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/asistencia_offline_provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';
import '../../services/notification_service.dart';

class MarcarAsistenciaPage extends StatefulWidget {
  final int obraId;
  final String obraNombre;
  final double latitud;
  final double longitud;
  final double radio;

  const MarcarAsistenciaPage({
    super.key,
    required this.obraId,
    required this.obraNombre,
    required this.latitud,
    required this.longitud,
    required this.radio,
  });
  @override
  State<MarcarAsistenciaPage> createState() => _MarcarAsistenciaPageState();
}

class _MarcarAsistenciaPageState extends State<MarcarAsistenciaPage> {
  static const Color azul = Color(0xFF0B4F7A);
  static const Color celeste = Color(0xFF1E9FB2);
  static const Color verde = Color(0xFFB7F25B);
  static const Color fondo = Colors.white;
  static const Color rojo = Color(0xFFE53935);
  static const Color gris = Color(0xFFBDBDBD);

  // Coordenadas del centro de obra para visualización en mapa
  double get obraLat => widget.latitud;
  double get obraLng => widget.longitud;
  double get radioMetros => widget.radio;

  // Horarios de obra (hardcodeados; idealmente vendrían del backend)
  // EN DESARROLLO: ventana amplia para pruebas (12h de tolerancia)
  static const int horaInicio = 8;
  static const int minutoInicio = 0;
  static const int horaFin = 18;
  static const int minutoFin = 0;
  static const int toleranciaMinutos =
      720; // 12 horas = siempre disponible en desarrollo

  Position? _posicionActual;
  StreamSubscription<Position>? _positionSub;
  Timer? _timer;

  bool _gpsCargando = true;
  String? _errorGps;
  String? _tipoSeleccionado;

  DateTime _horaActual = DateTime.now();

  // API state
  int? _paradaId;
  String _paradaNombre = '';
  List<Map<String, dynamic>> _paradasDisponibles = [];
  bool _cargandoParadas = true;
  bool _enviando = false;

  double? get _distanciaMetros {
    if (_posicionActual == null) return null;

    return Geolocator.distanceBetween(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      obraLat,
      obraLng,
    );
  }

  bool get _dentroDelRango {
    final distancia = _distanciaMetros;
    if (distancia == null) return false;
    return distancia <= radioMetros;
  }

  bool get _entradaDisponible {
    if (!_dentroDelRango) return false;

    final inicio = DateTime(
      _horaActual.year,
      _horaActual.month,
      _horaActual.day,
      horaInicio,
      minutoInicio,
    );

    final desde = inicio.subtract(const Duration(minutes: toleranciaMinutos));

    final hasta = inicio.add(const Duration(minutes: toleranciaMinutos));

    return _horaActual.isAfter(desde) && _horaActual.isBefore(hasta);
  }

  bool get _salidaDisponible {
    if (!_dentroDelRango) return false;

    final fin = DateTime(
      _horaActual.year,
      _horaActual.month,
      _horaActual.day,
      horaFin,
      minutoFin,
    );

    final desde = fin.subtract(const Duration(minutes: toleranciaMinutos));

    final hasta = fin.add(const Duration(minutes: toleranciaMinutos));

    return _horaActual.isAfter(desde) && _horaActual.isBefore(hasta);
  }

  bool get _puedeConfirmar {
    if (_tipoSeleccionado == 'entrada') return _entradaDisponible;
    if (_tipoSeleccionado == 'salida') return _salidaDisponible;
    return false;
  }

  @override
  void initState() {
    super.initState();

    _iniciarGps();

    // Cargar paradas después del primer frame para tener contexto disponible
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarParadas());

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _horaActual = DateTime.now();
        });
      }
    });
  }

  Future<void> _cargarParadas() async {
    try {
      final auth = context.read<AuthProvider>();
      final empleadoId = int.tryParse(
        auth.currentUserProfile?.employeeId ?? '',
      );
      if (empleadoId == null) {
        setState(() {
          _cargandoParadas = false;
          _errorGps = 'No se pudo identificar al empleado';
        });
        return;
      }

      final paradas = await ApiService.instance.obtenerParadasEmpleado(
        empleadoId,
      );
      final filtradas = paradas
          .where(
            (p) =>
                p['obraId'] == widget.obraId || p['obra_id'] == widget.obraId,
          )
          .map((p) => p as Map<String, dynamic>)
          .toList();

      setState(() {
        _paradasDisponibles = filtradas;
        _cargandoParadas = false;
        if (filtradas.isNotEmpty) {
          _paradaId = int.parse(filtradas.first['id'].toString());
          _paradaNombre = filtradas.first['nombre'] ?? '';
        }
      });
    } catch (e) {
      debugPrint('Error cargando paradas: $e');
      setState(() {
        _cargandoParadas = false;
        _errorGps ??= 'Error al cargar paradas disponibles';
      });
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _iniciarGps() async {
    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        setState(() {
          _gpsCargando = false;
          _errorGps = 'El GPS está desactivado';
        });
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        setState(() {
          _gpsCargando = false;
          _errorGps = 'Permiso de ubicación denegado';
        });
        return;
      }

      if (permiso == LocationPermission.deniedForever) {
        setState(() {
          _gpsCargando = false;
          _errorGps = 'Permiso de ubicación bloqueado';
        });
        return;
      }

      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _posicionActual = posicion;
        _gpsCargando = false;
      });

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((position) {
            if (mounted) {
              setState(() {
                _posicionActual = position;
              });
            }
          });
    } catch (e) {
      setState(() {
        _gpsCargando = false;
        _errorGps = 'No se pudo obtener la ubicación';
      });
    }
  }

  Future<void> _confirmarMarcacion() async {
    if (!_puedeConfirmar || _paradaId == null || _posicionActual == null)
      return;

    setState(() => _enviando = true);

    final bool esFakeGPS = _posicionActual!.isMocked;

    try {
      final tipo = _tipoSeleccionado == 'entrada' ? 'entrada' : 'salida';

      final resultado = await context
          .read<AsistenciaOfflineProvider>()
          .registrarMarcacion(
            paradaId: _paradaId!,
            tipoMarcacion: tipo,
            latitud: _posicionActual!.latitude,
            longitud: _posicionActual!.longitude,
            marcadaEn: DateTime.now(),
            isMocked: esFakeGPS,
          );

      if (!mounted) return;

      final tipoTexto = tipo == 'entrada' ? 'Entrada' : 'Salida';
      final quedoPendiente =
          resultado == MarcacionRegistroEstado.pendienteSincronizacion;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quedoPendiente
                ? '$tipoTexto guardada pendiente de sincronizacion'
                : '$tipoTexto registrada',
          ),
          backgroundColor: quedoPendiente ? Colors.orange : azul,
        ),
      );

      // US-NUEVA-09: Notificación local de confirmación de marcado
      NotificationService.instance.showMarkingNotification(
        tipo: tipoTexto,
        hora: DateTime.now(),
        validaGps: resultado['valida_gps'] == true,
        obraNombre: widget.obraNombre,
      );

      setState(() {
        _tipoSeleccionado = null;
        _enviando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: rojo,
        ),
      );
    }
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    final segundo = fecha.second.toString().padLeft(2, '0');

    return '$hora:$minuto:$segundo';
  }

  String _textoDistancia() {
    if (_gpsCargando) return 'Obteniendo GPS...';
    if (_errorGps != null) return '—';
    final distancia = _distanciaMetros;
    if (distancia == null) return 'Calculando...';
    return '${distancia.toStringAsFixed(1)} m';
  }

  @override
  Widget build(BuildContext context) {
    final LatLng obraPoint = LatLng(obraLat, obraLng);

    final LatLng? empleadoPoint = _posicionActual == null
        ? null
        : LatLng(_posicionActual!.latitude, _posicionActual!.longitude);

    final LatLng centroMapa = empleadoPoint ?? obraPoint;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: Text(widget.obraNombre), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _obraCard(),

            const SizedBox(height: 18),

            _selectorParada(),

            const SizedBox(height: 18),

            _estadoPrincipal(),

            const SizedBox(height: 18),

            _offlineSyncBanner(),

            const SizedBox(height: 18),

            _mapaCard(
              centroMapa: centroMapa,
              obraPoint: obraPoint,
              empleadoPoint: empleadoPoint,
            ),

            const SizedBox(height: 18),

            _infoUbicacion(),

            const SizedBox(height: 18),

            _infoHorario(),

            const SizedBox(height: 22),

            _botonesMarcacion(),

            const SizedBox(height: 18),

            _botonConfirmar(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _obraCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: azul, width: 1.3),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: azul, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.obraNombre,
                  style: const TextStyle(
                    color: azul,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID de obra: ${widget.obraId}',
                  style: const TextStyle(
                    color: azul,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineSyncBanner() {
    final offline = context.watch<AsistenciaOfflineProvider>();
    final visible = !offline.isOnline ||
        offline.pendingCount > 0 ||
        offline.isSyncing ||
        offline.lastError != null;

    if (!visible) return const SizedBox.shrink();

    final color = offline.isOnline ? Colors.orange : rojo;
    final icon = offline.isOnline ? Icons.sync : Icons.cloud_off;
    final texto = !offline.isOnline
        ? 'Sin conexion. Las marcaciones se guardaran localmente.'
        : offline.isSyncing
            ? 'Sincronizando marcaciones pendientes...'
            : offline.pendingCount > 0
                ? '${offline.pendingCount} marcacion(es) pendiente(s) de sincronizacion'
                : offline.lastError!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoPrincipal() {
    if (_gpsCargando) {
      return _estadoGrande(
        icono: Icons.gps_fixed,
        texto: 'Obteniendo ubicación...',
        color: celeste,
      );
    }

    if (_errorGps != null) {
      return _estadoGrande(
        icono: Icons.location_off,
        texto: _errorGps!,
        color: rojo,
      );
    }

    if (_dentroDelRango) {
      return _estadoGrande(
        icono: Icons.check_circle,
        texto: 'Dentro del rango autorizado',
        color: verde,
        textoColor: azul,
      );
    }

    return _estadoGrande(
      icono: Icons.cancel,
      texto: 'Fuera del rango autorizado',
      color: rojo,
    );
  }

  Widget _estadoGrande({
    required IconData icono,
    required String texto,
    required Color color,
    Color textoColor = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: azul, width: 1.3),
      ),
      child: Row(
        children: [
          Icon(icono, color: textoColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: textoColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapaCard({
    required LatLng centroMapa,
    required LatLng obraPoint,
    required LatLng? empleadoPoint,
  }) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: azul, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(initialCenter: centroMapa, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.marcapp',
          ),
          CircleLayer(
            circles: [
              CircleMarker(
                point: obraPoint,
                radius: radioMetros,
                useRadiusInMeter: true,
                color: celeste.withOpacity(0.20),
                borderColor: azul,
                borderStrokeWidth: 2,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: obraPoint,
                width: 48,
                height: 48,
                child: const Icon(Icons.location_pin, color: azul, size: 44),
              ),
              if (empleadoPoint != null)
                Marker(
                  point: empleadoPoint,
                  width: 48,
                  height: 48,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.orange,
                    size: 44,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoUbicacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu ubicación:',
          style: TextStyle(
            color: azul,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _datoBox(titulo: 'Distancia', valor: _textoDistancia()),
            const SizedBox(width: 10),
            _datoBox(
              titulo: 'Radio permitido',
              valor: '${radioMetros.toStringAsFixed(0)} m',
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoHorario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horario:',
          style: TextStyle(
            color: azul,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: azul, width: 1.3),
          columnWidths: const {
            0: FlexColumnWidth(1.7),
            1: FlexColumnWidth(1.3),
          },
          children: [
            TableRow(
              children: [
                const _CeldaHorario('Hora actual:'),
                _CeldaHorario(_formatearHora(_horaActual)),
              ],
            ),
            const TableRow(
              children: [
                _CeldaHorario('Hora entrada:'),
                _CeldaHorario('08:00'),
              ],
            ),
            const TableRow(
              children: [_CeldaHorario('Hora salida:'), _CeldaHorario('18:00')],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _estadoBox('Entrada', azul, flex: 2),
            _estadoBox(
              _entradaDisponible ? 'Disponible' : 'No disponible',
              _entradaDisponible ? verde : gris,
              flex: 2,
              textoColor: _entradaDisponible ? azul : Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _estadoBox('Salida', azul, flex: 2),
            _estadoBox(
              _salidaDisponible ? 'Disponible' : 'No disponible',
              _salidaDisponible ? verde : gris,
              flex: 2,
              textoColor: _salidaDisponible ? azul : Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _botonesMarcacion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _botonSeleccion(
          texto: 'Entrada',
          disponible: _entradaDisponible,
          seleccionado: _tipoSeleccionado == 'entrada',
          onTap: () {
            setState(() {
              _tipoSeleccionado = 'entrada';
            });
          },
        ),
        _botonSeleccion(
          texto: 'Salida',
          disponible: _salidaDisponible,
          seleccionado: _tipoSeleccionado == 'salida',
          onTap: () {
            setState(() {
              _tipoSeleccionado = 'salida';
            });
          },
        ),
      ],
    );
  }

  Widget _botonSeleccion({
    required String texto,
    required bool disponible,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    final color = !disponible
        ? gris
        : seleccionado
        ? celeste
        : azul;

    return SizedBox(
      width: 145,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: disponible ? onTap : null,
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _selectorParada() {
    if (_cargandoParadas) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Cargando paradas...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_paradasDisponibles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No tenés paradas asignadas en esta obra. '
                'No podés marcar asistencia.',
                style: TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: azul, width: 1.3),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: azul, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: _paradasDisponibles.length > 1
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _paradaId,
                      isExpanded: true,
                      items: _paradasDisponibles.map((p) {
                        final pid = int.parse(p['id'].toString());
                        return DropdownMenuItem(
                          value: pid,
                          child: Text(
                            p['nombre'] ?? 'Parada #$pid',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: azul,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _paradaId = v;
                          _paradaNombre =
                              _paradasDisponibles.firstWhere(
                                (p) => int.parse(p['id'].toString()) == v,
                              )['nombre'] ??
                              '';
                        });
                      },
                    ),
                  )
                : Text(
                    _paradaNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: azul,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _botonConfirmar() {
    final habilitado = _puedeConfirmar && _paradaId != null && !_enviando;

    return Center(
      child: SizedBox(
        width: 160,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: habilitado ? azul : gris,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          onPressed: habilitado
              ? () {
                  _confirmarMarcacion();
                }
              : null,
          child: _enviando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Confirmar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _datoBox({required String titulo, required String valor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: azul, width: 1.3),
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: azul,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: azul,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _estadoBox(
    String texto,
    Color color, {
    required int flex,
    Color textoColor = Colors.white,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: azul, width: 1.3),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textoColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CeldaHorario extends StatelessWidget {
  final String texto;

  const _CeldaHorario(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Center(
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0B4F7A),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
