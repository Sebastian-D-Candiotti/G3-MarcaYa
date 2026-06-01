import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/bottom_navbar.dart';

class PerfilEmpleadoPage extends StatelessWidget {
  const PerfilEmpleadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final empleado = auth.currentUserProfile; // usuario logueado

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),

      body: empleado == null
          ? const Center(
        child: Text(
          'No se encontró el perfil',
          style: TextStyle(fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FOTO
            CircleAvatar(
              radius: 50,
              backgroundImage: empleado.fotoUrl != null &&
                  empleado.fotoUrl!.isNotEmpty
                  ? NetworkImage(empleado.fotoUrl!)
                  : null,
              child: empleado.fotoUrl == null ||
                  empleado.fotoUrl!.isEmpty
                  ? Text(
                (empleado.nombre ?? '').isNotEmpty
                    ? empleado.nombre![0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 30),
              )
                  : null,
            ),

            const SizedBox(height: 20),

            // NOMBRE COMPLETO
            Text(
              '${empleado.nombre ?? ''} ${empleado.apellido ?? ''}',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // DESCRIPCIÓN
            if (empleado.descripcion != null &&
                empleado.descripcion!.isNotEmpty)
              Text(
                empleado.descripcion!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            // CORREO
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Correo'),
                subtitle: Text(empleado.correo),
              ),
            ),

            const SizedBox(height: 12),

            // TELÉFONO
            if (empleado.telefono != null &&
                empleado.telefono!.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Teléfono'),
                  subtitle: Text(empleado.telefono!),
                ),
              ),

            const SizedBox(height: 12),

            // ROL
            Card(
              child: ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Rol'),
                subtitle: Text(
                  auth.userRole ?? 'empleado',
                ),
              ),
            ),

            ElevatedButton.icon(
              onPressed: () {
                // TODO: abrir modal o página para editar perfil
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () async {

                await auth.logout();

                if (context.mounted) {
                  context.go('/');
                }

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavbar(
        userRole: 'empleado',
        currentIndex: 2,
      ),
    );
  }
}