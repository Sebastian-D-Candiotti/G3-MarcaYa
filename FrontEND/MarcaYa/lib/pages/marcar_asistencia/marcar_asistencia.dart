import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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

  // Coordenadas temporales de la obra.
  // Luego estas vendrán desde PostgreSQL/Rails.
  double get obraLat => widget.latitud;
  double get obraLng => widget.longitud;
  double get radioMetros => widget.radio;

  // Horarios temporales de obra.
  static const int horaInicio = 8;
  static const int minutoInicio = 0;
  static const int horaFin = 18;
  static const int minutoFin = 0;
  static const int toleranciaMinutos = 5;

  Position? _posicionActual;
  StreamSubscription<Position>? _positionSub;
  Timer? _timer;

  bool _gpsCargando = true;
  String? _errorGps;
  String? _tipoSeleccionado;

  DateTime _horaActual = DateTime.now();

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

    final desde = inicio.subtract(
      const Duration(minutes: toleranciaMinutos),
    );

    final hasta = inicio.add(
      const Duration(minutes: toleranciaMinutos),
    );

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

    final desde = fin.subtract(
      const Duration(minutes: toleranciaMinutos),
    );

    final hasta = fin.add(
      const Duration(minutes: toleranciaMinutos),
    );

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

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            _horaActual = DateTime.now();
          });
        }
      },
    );
  }


  @override
  void dispose() {
    _positionSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _iniciarGps() async {
    try {
      setState(() {

        _gpsCargando = false;
        _errorGps = null;
        _posicionActual = Position(
          longitude: -77.083000,
          latitude: -12.073000,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 0,
          altitudeAccuracy: 1,
          heading: 0,
          headingAccuracy: 1,
          speed: 0,
          speedAccuracy: 1,
        );

      });

      final servicioActivo =
      await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        setState(() {
          _gpsCargando = false;
          _errorGps = 'El GPS está desactivado';
        });
        return;
      }

      LocationPermission permiso =
      await Geolocator.checkPermission();

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
      );

      setState(() {
        _posicionActual = posicion;
        _gpsCargando = false;
      });

      _positionSub = Geolocator.getPositionStream(
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

  void _confirmarMarcacion() {
    if (!_puedeConfirmar) return;

    final tipo = _tipoSeleccionado == 'entrada'
        ? 'Entrada'
        : 'Salida';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$tipo registrada correctamente para ${widget.obraNombre}',
        ),
        backgroundColor: azul,
      ),
    );

    setState(() {
      _tipoSeleccionado = null;
    });
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    final segundo = fecha.second.toString().padLeft(2, '0');

    return '$hora:$minuto:$segundo';
  }

  String _textoDistancia() {
    final distancia = _distanciaMetros;

    if (distancia == null) return 'Calculando...';

    return '${distancia.toStringAsFixed(1)} m';
  }

  @override
  Widget build(BuildContext context) {
    final LatLng obraPoint = LatLng(
      obraLat,
      obraLng,
    );

    final LatLng? empleadoPoint = _posicionActual == null
        ? null
        : LatLng(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
    );

    final LatLng centroMapa = empleadoPoint ?? obraPoint;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          widget.obraNombre,
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _obraCard(),

            const SizedBox(height: 18),

            _estadoPrincipal(),

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
        border: Border.all(
          color: azul,
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.business,
            color: azul,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: azul,
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: textoColor,
            size: 28,
          ),
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
        border: Border.all(
          color: azul,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: centroMapa,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
            'com.example.marcapp',
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
                child: const Icon(
                  Icons.location_pin,
                  color: azul,
                  size: 44,
                ),
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
            _datoBox(
              titulo: 'Distancia',
              valor: _textoDistancia(),
            ),
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
          border: TableBorder.all(
            color: azul,
            width: 1.3,
          ),
          columnWidths: const {
            0: FlexColumnWidth(1.7),
            1: FlexColumnWidth(1.3),
          },
          children: [
            TableRow(
              children: [
                const _CeldaHorario('Hora actual:'),
                _CeldaHorario(
                  _formatearHora(_horaActual),
                ),
              ],
            ),
            const TableRow(
              children: [
                _CeldaHorario('Hora entrada:'),
                _CeldaHorario('08:00'),
              ],
            ),
            const TableRow(
              children: [
                _CeldaHorario('Hora salida:'),
                _CeldaHorario('18:00'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _estadoBox('Entrada', azul, flex: 2),
            _estadoBox(
              _entradaDisponible
                  ? 'Disponible'
                  : 'No disponible',
              _entradaDisponible ? verde : gris,
              flex: 2,
              textoColor:
              _entradaDisponible ? azul : Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _estadoBox('Salida', azul, flex: 2),
            _estadoBox(
              _salidaDisponible
                  ? 'Disponible'
                  : 'No disponible',
              _salidaDisponible ? verde : gris,
              flex: 2,
              textoColor:
              _salidaDisponible ? azul : Colors.white,
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
        child: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _botonConfirmar() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _puedeConfirmar ? azul : gris,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          onPressed:
          _puedeConfirmar ? _confirmarMarcacion : null,
          child: const Text(
            'Confirmar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _datoBox({
    required String titulo,
    required String valor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: azul,
            width: 1.3,
          ),
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
          border: Border.all(
            color: azul,
            width: 1.3,
          ),
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
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 6,
      ),
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