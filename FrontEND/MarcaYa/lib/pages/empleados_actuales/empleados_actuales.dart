import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';

class EmpleadosActualesPage extends StatelessWidget {
  const EmpleadosActualesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      body: const Center(child: Text('Empleados Actuales', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 2,
      ),
    );
  }
}
