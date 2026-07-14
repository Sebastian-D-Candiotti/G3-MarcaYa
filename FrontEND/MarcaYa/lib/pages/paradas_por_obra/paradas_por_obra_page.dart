import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';

class ParadasPorObraPage extends StatefulWidget {
  final int obraId;
  final String? obraNombre;

  const ParadasPorObraPage({
    super.key,
    required this.obraId,
    this.obraNombre,
  });

  @override
  State<ParadasPorObraPage> createState() => _ParadasPorObraPageState();
}

class _ParadasPorObraPageState extends State<ParadasPorObraPage> {
  List<dynamic> _paradas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarParadas();
  }

  Future<void> _cargarParadas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.obtenerParadas(widget.obraId);
      setState(() {
        _paradas = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar paradas';
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarParada(int paradaId) async {
    try {
      await ApiService.instance.eliminarParada(paradaId);
      await _cargarParadas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parada eliminada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  void _confirmarEliminar(Map<String, dynamic> parada) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar parada'),
        content: Text('¿Eliminar "${parada['nombre']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _eliminarParada(parada['id'] as int);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.obraNombre != null
        ? 'Paradas de ${widget.obraNombre}'
        : 'Paradas';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/empresa/paradas/agregar',
          extra: widget.obraId,
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 3,
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarParadas,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_paradas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off_rounded,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin paradas registradas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta obra no cuenta con paradas asociadas. Agrega paradas con geocercas para permitir que tus empleados marquen su asistencia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/empresa/paradas/agregar', extra: widget.obraId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Agregar Parada'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paradas.length,
      itemBuilder: (context, index) {
        final parada = _paradas[index] as Map<String, dynamic>;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        parada['nombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => context.push(
                        '/empresa/paradas/editar',
                        extra: parada,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _confirmarEliminar(parada),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Estado: ${parada['estado'] ?? '—'}'),
                const SizedBox(height: 2),
                Text(
                  '${parada['latitud'] ?? '—'}, ${parada['longitud'] ?? '—'}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push(
                    '/empresa/asistencia',
                    extra: {'paradaId': parada['id'] as int},
                  ),
                  child: const Text('Ver asistencia'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
