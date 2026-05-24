import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';

class VerSolicitudesPage extends StatelessWidget {
  const VerSolicitudesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes')),
      body: const Center(child: Text('Ver Solicitudes', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 3,
      ),
    );
  }
}
