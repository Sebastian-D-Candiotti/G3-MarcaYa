import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';

class AgregarParadaPage extends StatefulWidget {
  const AgregarParadaPage({super.key});

  @override
  State<AgregarParadaPage> createState() => _AgregarParadaPageState();
}

class _AgregarParadaPageState extends State<AgregarParadaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final MapController mapController = MapController();

  LatLng centroMapa = const LatLng(-12.046374, -77.042793);

  double? latitud;
  double? longitud;
  double radioMetros = 100;

  List<dynamic> _obras = [];
  int? _obraSeleccionadaId;
  bool _cargandoObras = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    final auth = context.read<AuthProvider>();
    final empresaId = auth.currentUserProfile?.empresaId != null
        ? int.tryParse(auth.currentUserProfile!.empresaId!)
        : null;
    if (empresaId == null) {
      setState(() => _cargandoObras = false);
      return;
    }
    try {
      final data = await ApiService.instance.obtenerObras(empresaId: empresaId);
      setState(() {
        _obras = data;
        _cargandoObras = false;
      });
    } catch (e) {
      setState(() => _cargandoObras = false);
      debugPrint('Error al cargar obras: $e');
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_obraSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una obra')),
      );
      return;
    }
    if (latitud == null || longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una ubicación en el mapa')),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await ApiService.instance.crearParada(
        obraId: _obraSeleccionadaId!,
        nombre: _nombreCtrl.text,
        latitud: latitud!,
        longitud: longitud!,
        radioMetros: radioMetros,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parada creada correctamente')),
      );
      context.pop();
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
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Parada')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selector de obra
            _cargandoObras
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: _obraSeleccionadaId,
                    decoration: const InputDecoration(
                      labelText: 'Obra',
                      border: OutlineInputBorder(),
                    ),
                    items: _obras.map<DropdownMenuItem<int>>((o) {
                      return DropdownMenuItem(
                        value: o['id'] as int,
                        child: Text(o['nombre'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _obraSeleccionadaId = v),
                    validator: (v) => v == null ? 'Seleccioná una obra' : null,
                  ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la parada',
                hintText: 'Ej: Puerta principal',
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
                  : const Text('Guardar Parada'),
            ),
          ],
        ),
      ),
    );
  }
}
