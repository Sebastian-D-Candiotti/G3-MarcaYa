import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../src/api_service.dart';

class EditarParadaPage extends StatefulWidget {
  final Map<String, dynamic> paradaData;

  const EditarParadaPage({super.key, required this.paradaData});

  @override
  State<EditarParadaPage> createState() => _EditarParadaPageState();
}

class _EditarParadaPageState extends State<EditarParadaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  final MapController mapController = MapController();

  late LatLng centroMapa;
  double? latitud;
  double? longitud;
  double radioMetros = 100;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final data = widget.paradaData;
    _nombreCtrl = TextEditingController(text: data['nombre']?.toString() ?? '');

    final lat = double.tryParse(data['latitud']?.toString() ?? '');
    final lng = double.tryParse(data['longitud']?.toString() ?? '');
    if (lat != null && lng != null) {
      centroMapa = LatLng(lat, lng);
      latitud = lat;
      longitud = lng;
    } else {
      centroMapa = const LatLng(-12.046374, -77.042793);
    }

    radioMetros = double.tryParse(
          data['radioMetros']?.toString() ??
              data['radio_metros']?.toString() ??
              '',
        ) ??
        100;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (latitud == null || longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una ubicación en el mapa')),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await ApiService.instance.actualizarParada(
        widget.paradaData['id'] as int,
        nombre: _nombreCtrl.text,
        latitud: latitud!,
        longitud: longitud!,
        radioMetros: radioMetros.round(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parada actualizada')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Parada')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ubicación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: centroMapa,
                      initialZoom: 16,
                      onPositionChanged: (position, hasGesture) {
                        final center = position.center;
                        if (center != null) {
                          setState(() {
                            centroMapa = center;
                            latitud = center.latitude;
                            longitud = center.longitude;
                          });
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.marcapp',
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: centroMapa,
                            radius: radioMetros,
                            useRadiusInMeter: true,
                            color: Colors.blue.withOpacity(0.15),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const IgnorePointer(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Radio de tolerancia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: radioMetros,
              min: 50,
              max: 500,
              divisions: 9,
              label: '${radioMetros.round()} m',
              onChanged: (value) {
                setState(() {
                  radioMetros = value;
                });
              },
            ),
            Center(
              child: Text(
                '${radioMetros.round()} metros',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _enviando ? null : _guardar,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
