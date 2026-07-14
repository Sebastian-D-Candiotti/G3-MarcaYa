import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

class PerfilPublicoPage extends StatefulWidget {
  final int usuarioId;
  const PerfilPublicoPage({super.key, required this.usuarioId});

  @override
  State<PerfilPublicoPage> createState() => _PerfilPublicoPageState();
}

class _PerfilPublicoPageState extends State<PerfilPublicoPage> {
  Map<String, dynamic>? usuario;
  List<dynamic> _misSolicitudes = [];
  List<dynamic> _misObras = [];
  List<dynamic> _valoraciones = [];
  double _promedio = 0.0;
  int _totalValoraciones = 0;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    try {
      final data =
      await ApiService.instance.obtenerPerfilUsuario(widget.usuarioId);

      // Cargar solicitudes del empleado autenticado para saber si ya solicitó
      List<dynamic> solicitudes = [];
      try {
        solicitudes = await ApiService.instance.obtenerMisSolicitudes();
      } catch (_) {}

      // Cargar obras del empleado autenticado para saber si ya está asignado
      List<dynamic> obras = [];
      try {
        final auth = context.read<AuthProvider>();
        final empId = auth.currentUserProfile?.employeeId;
        if (empId != null) {
          obras = await ApiService.instance.obtenerObrasEmpleado(empId);
        }
      } catch (_) {}

      // Cargar valoraciones de la empresa
      List<dynamic> valoraciones = [];
      double promedio = 0.0;
      int totalVal = 0;
      if (data != null && data['rol'] == 'empresa') {
        try {
          valoraciones = await ApiService.instance.obtenerValoraciones(widget.usuarioId);
          final promData = await ApiService.instance.obtenerPromedioValoracion(widget.usuarioId);
          promedio = double.tryParse(promData['promedio']?.toString() ?? '0.0') ?? 0.0;
          totalVal = int.tryParse(promData['total']?.toString() ?? '0') ?? 0;
        } catch (_) {}
      }

      setState(() {
        usuario = data;
        _misSolicitudes = solicitudes;
        _misObras = obras;
        _valoraciones = valoraciones;
        _promedio = promedio;
        _totalValoraciones = totalVal;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      debugPrint(e.toString());
    }
  }

  /// Retorna el estado de solicitud para una empresa: null si no hay, 'pendiente', 'aceptada'
  String? _estadoSolicitud(int? empresaId) {
    if (empresaId == null) return null;
    for (final s in _misSolicitudes) {
      final empresa = s['empresa'] as Map<String, dynamic>?;
      if (empresa?['id'] == empresaId) {
        final estado = s['estado'] as String?;
        if (estado == 'pendiente' || estado == 'aceptada') return estado;
      }
    }
    return null;
  }

  /// Verifica si el empleado autenticado ya está asignado a alguna obra de esta empresa
  bool _estaAsignadoAEmpresa(int? empresaId) {
    if (empresaId == null) return false;
    for (final obra in _misObras) {
      if (obra['empresa_id'] == empresaId) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {

    final nombreMostrar =
    usuario != null
        ? (usuario!['rol'] == 'empresa'
        ? (usuario!['nombre_empresa'] ?? '')
        : (usuario!['nombre'] ?? ''))
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreMostrar.isNotEmpty ? nombreMostrar : 'Perfil'),
      ),

      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : usuario == null
          ? const Center(
        child: Text(
          'No se encontró el usuario',
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // FOTO
            CircleAvatar(
              radius: 50,

              backgroundImage:
              usuario!['foto_url'] != null &&
                  usuario!['foto_url']
                      .toString()
                      .isNotEmpty
                  ? NetworkImage(
                usuario!['foto_url'],
              )
                  : null,

              child:
              usuario!['foto_url'] == null ||
                  usuario!['foto_url']
                      .toString()
                      .isEmpty
                  ? Text(
                nombreMostrar.isNotEmpty
                    ? nombreMostrar[0]
                    .toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 30,
                ),
              )
                  : null,
            ),

            const SizedBox(height: 15),

            // NOMBRE
            Text(
              usuario!['rol'] == 'empresa'
                  ? (usuario!['nombre_empresa'] ??
                  '')
                  : '${usuario!['nombre'] ?? ''} ${usuario!['apellido'] ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPCIÓN
            if (usuario!['descripcion'] != null &&
                usuario!['descripcion']
                    .toString()
                    .isNotEmpty)
              Text(
                usuario!['descripcion'],
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: 20),

            // CORREO
            if (usuario!['correo'] != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.email,
                  ),
                  title: Text(
                    usuario!['correo'],
                  ),
                ),
              ),

            // TELÉFONO
            if (usuario!['telefono'] != null &&
                usuario!['telefono']
                    .toString()
                    .isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.phone,
                  ),
                  title: Text(
                    usuario!['telefono'],
                  ),
                ),
              ),

            // DIRECCIÓN
            if (usuario!['direccion'] != null &&
                usuario!['direccion']
                    .toString()
                    .isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.location_on,
                  ),
                  title: Text(
                    usuario!['direccion'],
                  ),
                ),
              ),

            // RUC
            if (usuario!['ruc'] != null &&
                usuario!['ruc']
                    .toString()
                    .isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.badge,
                  ),
                  title: Text(
                    usuario!['ruc'],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ESTRELLAS Y VALORACIÓN
            if (usuario!['rol'] == 'empresa')
              Column(
                children: [
                  const Text(
                    'Valoración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _promedio.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _promedio.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                          Text(
                            '($_totalValoraciones valoraciones)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (Provider.of<AuthProvider>(context, listen: false).userRole == 'empleado') ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _mostrarDialogoCalificar,
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Calificar Empresa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 24),

            // OBRAS
            if (usuario!['rol'] == 'empresa') ...[
              if (usuario!['obras'] != null && (usuario!['obras'] as List).isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Obras de la Empresa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: (usuario!['obras'] as List).length,
                  itemBuilder: (context, index) {
                    final obra = (usuario!['obras'] as List)[index] as Map<String, dynamic>;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF22577A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.construction_rounded, color: Colors.white, size: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                obra['nombre'] ?? 'Obra',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Código: ${obra['codigo_obra'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // BOTÓN SOLICITAR INGRESO — UNO SOLO PARA LA EMPRESA
              SizedBox(
                width: double.infinity,
                child: _buildSolicitarIngresoBoton(usuario?['empresa_id'] as int?),
              ),
            ],

            const SizedBox(height: 24),

            // COMENTARIOS
            if (_valoraciones.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reseñas de Colaboradores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._valoraciones.map(
                    (v) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(Icons.person, color: AppColors.textSecondary),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Colaborador #${v['empleadoId'] ?? ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (v['puntuacion'] ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            v['comentario'] ?? '',
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolicitarIngresoBoton(int? empresaId) {
    final estado = _estadoSolicitud(empresaId);
    final asignado = _estaAsignadoAEmpresa(empresaId);

    if (estado == 'pendiente') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.hourglass_empty),
        label: const Text('Solicitud enviada'),
        onPressed: null,
        style: ElevatedButton.styleFrom(foregroundColor: Colors.grey),
      );
    }

    if (estado == 'aceptada' || asignado) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.check_circle),
        label: const Text('Ya pertenece'),
        onPressed: null,
        style: ElevatedButton.styleFrom(foregroundColor: Colors.green),
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.send),
      label: const Text('Solicitar ingreso'),
      onPressed: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);

        final empleadoId = int.tryParse(auth.currentUserProfile?.employeeId ?? '');
        if (empleadoId == null || empresaId == null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se puede enviar la solicitud: datos incompletos')),
          );
          return;
        }

        try {
          await ApiService.instance.solicitarIngreso(
            empleadoId: empleadoId,
            empresaId: empresaId,
          );

          // Agregar la solicitud al estado local para reflejar el cambio
          setState(() {
            _misSolicitudes.add({
              'estado': 'pendiente',
              'empresa': {'id': empresaId},
            });
          });

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud enviada correctamente')),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar solicitud: $e')),
          );
        }
      },
    );
  }

  void _mostrarDialogoCalificar() {
    int puntuacion = 5;
    final comentarioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Calificar Empresa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Cómo calificarías tu experiencia con esta empresa?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        icon: Icon(
                          starVal <= puntuacion ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            puntuacion = starVal;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: comentarioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu comentario aquí...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (comentarioCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor escribe un comentario')),
                      );
                      return;
                    }
                    try {
                      final companyId = int.tryParse(usuario!['empresa_id']?.toString() ?? '');
                      if (companyId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: No se encontró el ID de la empresa')),
                        );
                        return;
                      }

                      await ApiService.instance.crearValoracion(
                        empresaId: companyId,
                        puntuacion: puntuacion,
                        comentario: comentarioCtrl.text,
                      );

                      Navigator.pop(ctx);
                      cargarPerfil(); // reload ratings list
                      
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reseña guardada correctamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al guardar reseña: $e')),
                      );
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}