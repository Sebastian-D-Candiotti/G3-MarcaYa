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
      return const Center(child: Text('No hay paradas para esta obra'));
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
