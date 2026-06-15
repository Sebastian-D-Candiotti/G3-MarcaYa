import 'package:flutter/material.dart';
import '../../src/api_service.dart';

/// Pantalla que muestra el historial de asistencias del empleado autenticado.
///
/// Se accede desde `/empleado/historial` y desde notificaciones push
/// con `data.screen == "historial"`.
class HistorialAsistenciaPage extends StatefulWidget {
  const HistorialAsistenciaPage({super.key});

  @override
  State<HistorialAsistenciaPage> createState() =>
      _HistorialAsistenciaPageState();
}

class _HistorialAsistenciaPageState extends State<HistorialAsistenciaPage> {
  List<dynamic> _asistencias = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final data = await ApiService.instance.obtenerHistorial();
      setState(() {
        _asistencias = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  String _tipoIcono(String tipo) {
    if (tipo.toLowerCase().contains('entrada')) return '⬆';
    return '⬇';
  }

  Color _tipoColor(String tipo) {
    if (tipo.toLowerCase().contains('entrada')) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarHistorial,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarHistorial,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_asistencias.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay registros de asistencia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarHistorial,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _asistencias.length,
        itemBuilder: (context, index) {
          final item = _asistencias[index];
          final tipo = item['tipo_marcacion']?.toString() ?? 'desconocido';
          final hora = item['hora']?.toString() ?? item['created_at']?.toString() ?? '';
          final ubicacionValida = item['ubicacion_valida'] == true ||
              item['ubicacion_valida'] == 'true';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _tipoColor(tipo).withAlpha(30),
                child: Text(
                  _tipoIcono(tipo),
                  style: TextStyle(fontSize: 20, color: _tipoColor(tipo)),
                ),
              ),
              title: Text(
                tipo.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _tipoColor(tipo),
                ),
              ),
              subtitle: Text(hora),
              trailing: Icon(
                ubicacionValida ? Icons.check_circle : Icons.warning,
                color: ubicacionValida ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
