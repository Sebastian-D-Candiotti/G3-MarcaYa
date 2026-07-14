import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/bottom_navbar.dart';
import '../../theme/app_theme.dart';

class PerfilEmpresaPage extends StatelessWidget {
  const PerfilEmpresaPage({super.key});

  static Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
      ),
    );
  }

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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'EMPRESA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (empresa.otpVerificado) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'RUC VERIFICADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
              _infoCard(
                icon: Icons.phone,
                title: 'Teléfono',
                subtitle: empresa.telefono!,
              ),
            const SizedBox(height: 12),

            // RUC
            if (empresa.ruc != null && empresa.ruc!.isNotEmpty)
              _infoCard(
                icon: Icons.badge,
                title: 'RUC',
                subtitle: empresa.ruc!,
              ),
            const SizedBox(height: 12),

            // DIRECCIÓN
            if (empresa.direccion != null &&
                empresa.direccion!.isNotEmpty)
              _infoCard(
                icon: Icons.location_on,
                title: 'Dirección',
                subtitle: empresa.direccion!,
              ),
            const SizedBox(height: 12),

            // CORREO
            _infoCard(
              icon: Icons.email_outlined,
              title: 'Correo Corporativo',
              subtitle: empresa.correo,
            ),
            const SizedBox(height: 12),

            // MIEMBRO DESDE
            if (empresa.fechaRegistro != null) ...[
              _infoCard(
                icon: Icons.calendar_today_outlined,
                title: 'Miembro desde',
                subtitle:
                    "${empresa.fechaRegistro!.day.toString().padLeft(2, '0')}/${empresa.fechaRegistro!.month.toString().padLeft(2, '0')}/${empresa.fechaRegistro!.year}",
              ),
              const SizedBox(height: 12),
            ],

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/empresa/perfil/editar'),
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {

                  await auth.logout();

                  if (context.mounted) {
                    context.go('/');
                  }

                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),

                icon: const Icon(Icons.logout),

                label: const Text('Cerrar Sesión'),
              ),
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