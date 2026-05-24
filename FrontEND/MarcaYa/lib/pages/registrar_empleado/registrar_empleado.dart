import 'package:flutter/material.dart';

class RegistrarEmpleadoPage extends StatefulWidget {
  const RegistrarEmpleadoPage({super.key});

  @override
  State<RegistrarEmpleadoPage> createState() => _RegistrarEmpleadoPageState();
}

class _RegistrarEmpleadoPageState extends State<RegistrarEmpleadoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Empleado')),
      body: const Center(child: Text('Registrar Empleado - en construcción')),
    );
  }
}
