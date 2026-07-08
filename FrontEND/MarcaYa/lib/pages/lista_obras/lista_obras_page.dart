import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';

class ListaObrasPage extends StatefulWidget {
  const ListaObrasPage({super.key});

  @override
  State<ListaObrasPage> createState() => _ListaObrasPageState();
}

class _ListaObrasPageState extends State<ListaObrasPage> {
  List<dynamic> _obras = [];
  bool _cargando = true;

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
      setState(() => _cargando = false);
      return;
    }
    try {
      final data = await ApiService.instance.obtenerObras(empresaId: empresaId);
      setState(() {
        _obras = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      debugPrint('Error al cargar obras: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Obras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar obra',
            onPressed: () => context.push('/empresa/obras/agregar'),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _obras.isEmpty
              ? const Center(child: Text('No hay obras registradas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _obras.length,
                  itemBuilder: (context, index) {
                    final obra = _obras[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre de la obra
                            Text(
                              obra['nombre'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Información adicional
                            if (obra['codigoObra'] != null)
                              Text(
                                'Código: ${obra['codigoObra']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (obra['estado'] != null)
                              Text(
                                'Estado: ${obra['estado']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            const SizedBox(height: 12),
                            
                            // Botones de acción
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.show_chart),
                                    label: const Text('Detalles'),
                                    onPressed: () => context.push(
                                      '/empresa/obras/${obra['id']}/detalles',
                                      extra: {'obraNombre': obra['nombre']},
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.location_on),
                                    label: const Text('Paradas'),
                                    onPressed: () => context.push(
                                      '/empresa/obras/${obra['id']}/paradas',
                                      extra: {'obraNombre': obra['nombre']},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 3,
      ),
    );
  }
}
