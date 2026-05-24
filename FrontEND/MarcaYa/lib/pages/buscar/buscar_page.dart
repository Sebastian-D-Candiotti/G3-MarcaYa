import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';

class BuscarPage extends StatelessWidget {
  const BuscarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: const Center(child: Text('Buscar empresas', style: TextStyle(fontSize: 18))),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empleado',
        currentIndex: 2,
      ),
    );
  }
}
