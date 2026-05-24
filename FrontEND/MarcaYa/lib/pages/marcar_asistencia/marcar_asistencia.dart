import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';

class MarcarAsistenciaPage extends StatelessWidget {
  const MarcarAsistenciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marcar Asistencia')),
      body: const Center(child: Text('Marcar Asistencia', style: TextStyle(fontSize: 18))),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empleado',
        currentIndex: 1,
      ),
    );
  }
}
