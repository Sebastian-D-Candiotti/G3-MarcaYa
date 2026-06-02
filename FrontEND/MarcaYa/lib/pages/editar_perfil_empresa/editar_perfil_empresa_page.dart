import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';

class EditarPerfilEmpresaPage extends StatefulWidget {
  const EditarPerfilEmpresaPage({super.key});

  @override
  State<EditarPerfilEmpresaPage> createState() => _EditarPerfilEmpresaPageState();
}

class _EditarPerfilEmpresaPageState extends State<EditarPerfilEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final perfil = auth.currentUserProfile;
    if (perfil != null) {
      _nombreCtrl.text = perfil.nombreEmpresa ?? perfil.nombre;
      _descripcionCtrl.text = perfil.descripcion ?? '';
      _telefonoCtrl.text = perfil.telefono ?? '';
      _direccionCtrl.text = perfil.direccion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    try {
      await ApiService.instance.actualizarMiPerfil(
        nombreEmpresa: _nombreCtrl.text,
        descripcion: _descripcionCtrl.text.isEmpty ? null : _descripcionCtrl.text,
        telefono: _telefonoCtrl.text.isEmpty ? null : _telefonoCtrl.text,
        direccion: _direccionCtrl.text.isEmpty ? null : _direccionCtrl.text,
      );

      // Recargar perfil actualizado
      await context.read<AuthProvider>().fetchProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil Empresa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la empresa',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _enviando ? null : _guardar,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
