import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../src/api_service.dart';

class AgregarObraPage extends StatefulWidget {
  const AgregarObraPage({super.key});

  @override
  State<AgregarObraPage> createState() => _AgregarObraPageState();
}

class _AgregarObraPageState extends State<AgregarObraPage> {
  final _formKey = GlobalKey<FormState>();

  final codigoController = TextEditingController();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  final capacidadController = TextEditingController();
  final MapController mapController = MapController();

  LatLng centroMapa = const LatLng(
    -12.046374,
    -77.042793,
  );

  double? latitud;
  double? longitud;
  double radioMetros = 100;

  String? direccionSeleccionada;

  DateTime? fechaInicio;
  DateTime? fechaFin;

  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;

  Future<void> seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        fechaInicio = fecha;
      });
    }
  }

  Future<void> seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        fechaFin = fecha;
      });
    }
  }

  Future<void> seleccionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        horaInicio = hora;
      });
    }
  }

  Future<void> seleccionarHoraFin() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        horaFin = hora;
      });
    }
  }

  Future<void> guardarObra() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (fechaInicio == null ||
        fechaFin == null ||
        horaInicio == null ||
        horaFin == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe completar fechas y horarios',
          ),
        ),
      );

      return;
    }

    if (latitud == null || longitud == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe seleccionar una ubicación en el mapa',
          ),
        ),
      );

      return;
    }

    try {

      await crearObra();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Obra registrada correctamente',
          ),
        ),
      );

      context.go('/empresa');

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al registrar obra: $e',
          ),
        ),
      );
    }
  }

  Future<void> crearObra() async {
    await ApiService.instance.crearObra(
      codigoObra: codigoController.text,
      nombre: nombreController.text,
      descripcionUbicacion: descripcionController.text,
      latitud: latitud!,
      longitud: longitud!,
      radioMetros: radioMetros.round(),
      horaInicio: '${horaInicio!.hour}:${horaInicio!.minute}',
      horaFin: '${horaFin!.hour}:${horaFin!.minute}',
      fechaInicio: fechaInicio.toString().split(' ')[0],
      fechaFin: fechaFin.toString().split(' ')[0],
      capacidadEmpleados: int.parse(capacidadController.text),
    );
  }

  Widget campo(
      String label,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obligatorio';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva Obra',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              campo(
                'Código de Obra',
                codigoController,
              ),

              campo(
                'Nombre de la Obra',
                nombreController,
              ),

              campo(
                'Descripción',
                descripcionController,
              ),

              const SizedBox(height: 20),

              const Text(
                'Ubicación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: centroMapa,
                        initialZoom: 16,

                        onPositionChanged: (
                            position,
                            hasGesture,
                            ) {

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
                          userAgentPackageName:
                          'com.example.marcapp',
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

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ubicación seleccionada correctamente',
                        ),
                      ),
                    );

                  },
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Confirmar ubicación',
                  ),
                ),
              ),


              const SizedBox(height: 20),

              const Text(
                'Radio de tolerancia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Horario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: seleccionarHoraInicio,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    horaInicio == null
                        ? 'Hora Entrada'
                        : horaInicio!.format(context),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: seleccionarHoraFin,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    horaFin == null
                        ? 'Hora Salida'
                        : horaFin!.format(context),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              campo(
                'Capacidad de Empleados',
                capacidadController,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: seleccionarFechaInicio,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    fechaInicio == null
                        ? 'Fecha Inicio'
                        : fechaInicio.toString().split(' ')[0],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: seleccionarFechaFin,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    fechaFin == null
                        ? 'Fecha Fin'
                        : fechaFin.toString().split(' ')[0],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: guardarObra,
                  child: const Text(
                    'Guardar Obra',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}