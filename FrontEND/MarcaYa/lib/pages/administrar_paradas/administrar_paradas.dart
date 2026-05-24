import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/bottom_navbar.dart';

class AdministrarParadasPage extends StatelessWidget {
  const AdministrarParadasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sitios')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/empresa/paradas/agregar'),
              child: const Text('Agregar Parada'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/empresa/paradas/editar'),
              child: const Text('Editar Parada'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/empresa/asistencia'),
              child: const Text('Ver Asistencia'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 1,
      ),
    );
  }
}
