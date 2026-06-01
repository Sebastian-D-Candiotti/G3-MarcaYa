import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';

class PerfilPublicoPage extends StatefulWidget {
  final int usuarioId;
  const PerfilPublicoPage({super.key, required this.usuarioId});

  @override
  State<PerfilPublicoPage> createState() => _PerfilPublicoPageState();
}

class _PerfilPublicoPageState extends State<PerfilPublicoPage> {
  Map<String, dynamic>? usuario;
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

      print(data);

      setState(() {
        usuario = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      debugPrint(e.toString());
    }
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

            // ESTRELLAS
            if (usuario!['rol'] == 'empresa')
              Column(
                children: [

                  const Text(
                    'Valoración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children:
                    List.generate(
                      5,
                          (_) => const Icon(
                        Icons.star,
                        color:
                        Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // OBRAS
            if (usuario!['rol'] == 'empresa' &&
                usuario!['obras'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Obras actuales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...List<Widget>.from(
                    (usuario!['obras'] as List).map(
                          (obra) => Card(
                        child: ListTile(
                          title: Text(obra['nombre'] ?? ''),
                          subtitle: Text(obra['codigo_obra'] ?? ''),

                          // BOTÓN SOLICITAR INGRESO
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text('Solicitar ingreso'),
                            onPressed: () async {
                              final auth = Provider.of<AuthProvider>(context, listen: false);

                              final empleadoId = auth.currentUserProfile!.id; // ID del empleado logueado
                              final obraId = int.parse(obra['id'].toString()); // ID de la obra seleccionada

                              try {
                                await ApiService.instance.solicitarIngreso(
                                  obraId: obraId,
                                  empleadoId: empleadoId,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Solicitud enviada correctamente'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al enviar solicitud: $e'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 25),

            // COMENTARIOS
            if (usuario!['comentarios'] != null &&
                (usuario!['comentarios']
                as List)
                    .isNotEmpty)
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [

                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...List<Widget>.from(
                    (usuario!['comentarios']
                    as List)
                        .map(
                          (c) =>
                          Card(
                            child:
                            ListTile(
                              title: Text(
                                c['empleado'] ??
                                    'Anónimo',
                              ),
                              subtitle:
                              Text(
                                c['comentario'] ??
                                    '',
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
}