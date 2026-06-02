import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/bottom_navbar.dart';

class PerfilEmpresaPage extends StatelessWidget {
  const PerfilEmpresaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final empresa = auth.currentUserProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Empresa'),
      ),
      body: empresa == null
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
              backgroundImage: empresa.fotoUrl != null &&
                  empresa.fotoUrl!.isNotEmpty
                  ? NetworkImage(empresa.fotoUrl!)
                  : null,
              child: empresa.fotoUrl == null || empresa.fotoUrl!.isEmpty
                  ? Text(
                (empresa.nombreEmpresa ?? '')[0].toUpperCase(),
                style: const TextStyle(fontSize: 30),
              )
                  : null,
            ),
            const SizedBox(height: 20),

            // NOMBRE EMPRESA
            Text(
              empresa.nombreEmpresa ?? empresa.nombre ?? '',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // DESCRIPCIÓN
            if (empresa.descripcion != null &&
                empresa.descripcion!.isNotEmpty)
              Text(
                empresa.descripcion!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            // ESTRELLAS - siempre 5
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (_) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TELÉFONO
            if (empresa.telefono != null && empresa.telefono!.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Teléfono'),
                  subtitle: Text(empresa.telefono!),
                ),
              ),
            const SizedBox(height: 12),

            // RUC
            if (empresa.ruc != null && empresa.ruc!.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('RUC'),
                  subtitle: Text(empresa.ruc!),
                ),
              ),
            const SizedBox(height: 12),

            // DIRECCIÓN
            if (empresa.direccion != null &&
                empresa.direccion!.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Dirección'),
                  subtitle: Text(empresa.direccion!),
                ),
              ),

            // COMENTARIOS - sección final
            if (empresa.comentarios != null &&
                empresa.comentarios!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...empresa.comentarios!.map(
                        (c) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(c['empleado'] ?? 'Anónimo'),
                        subtitle: Text(c['comentario'] ?? ''),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // BOTÓN EDITAR PERFIL
            ElevatedButton.icon(
              onPressed: () => context.push('/empresa/perfil/editar'),
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
        userRole: 'empresa',
        currentIndex: 4,
      ),
    );
  }
}