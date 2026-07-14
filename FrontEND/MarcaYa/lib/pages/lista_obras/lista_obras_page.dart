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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          color: Colors.grey,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay obras registradas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Agrega tu primera obra para comenzar a gestionar a tus empleados y sus ubicaciones de asistencia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.push('/empresa/obras/agregar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Agregar Obra'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _obras.length,
                  itemBuilder: (context, index) {
                    final obra = _obras[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              obra['nombre'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (obra['codigoObra'] != null)
                              Text(
                                'Código: ${obra['codigoObra']}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            if (obra['estado'] != null)
                              Text(
                                'Estado: ${obra['estado']}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => context.push(
                                    '/empresa/obras/${obra['id']}/detalles',
                                    extra: {'obraNombre': obra['nombre']},
                                  ),
                                  child: const Text('Detalles'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () => context.push(
                                    '/empresa/obras/${obra['id']}/paradas',
                                    extra: {'obraNombre': obra['nombre']},
                                  ),
                                  child: const Text('Paradas'),
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
