import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class BuscarPage extends StatefulWidget {


  final String userRole;

  const BuscarPage({
    super.key,
    required this.userRole,
  });

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {

  List<dynamic> usuarios = [];
  List<dynamic> usuariosFiltrados = [];

  bool cargando = true;
  String filtroTipo = 'todos';

  final TextEditingController buscarController =
  TextEditingController();


  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {

    try {

      final auth = context.read<AuthProvider>();

      final usuarioActualId =
          auth.currentUserProfile?.id;

      final data =
      await ApiService.instance.obtenerUsuarios();

      List<dynamic> usuariosVisibles;

      if (widget.userRole == 'empresa') {

        usuariosVisibles = data.where((usuario) {

          return usuario['id'] != usuarioActualId &&
              usuario['rol'] == 'empleado';

        }).toList();

      } else {

        usuariosVisibles = data.where((usuario) {

          return usuario['id'] != usuarioActualId;

        }).toList();

      }

      setState(() {

        usuarios = usuariosVisibles;
        usuariosFiltrados = usuariosVisibles;
        cargando = false;

      });

    } catch (e) {

      setState(() {
        cargando = false;
      });

      debugPrint(e.toString());

    }

  }

  void filtrarUsuarios(String texto) {
    setState(() {
      usuariosFiltrados = usuarios.where((usuario) {

        final nombre = usuario['nombre'] != null
            ? usuario['nombre'].toString().toLowerCase()
            : '';

        final descripcion = usuario['descripcion'] != null
            ? usuario['descripcion'].toString().toLowerCase()
            : '';

        final rol = usuario['rol'] != null
            ? usuario['rol'].toString().toLowerCase()
            : '';

        final coincideTexto = nombre.contains(texto.toLowerCase()) ||
            descripcion.contains(texto.toLowerCase());

        final coincideTipo = filtroTipo == 'todos' ? true : rol == filtroTipo;

        return coincideTexto && coincideTipo;

      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Buscar Usuarios'),
      ),

      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(

        children: [

          Padding(
            padding: const EdgeInsets.all(16),

            child: DropdownButtonFormField<String>(

              value: filtroTipo,

              decoration: InputDecoration(
                labelText: 'Filtrar por tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: 'todos',
                  child: Text('Todos'),
                ),

                DropdownMenuItem(
                  value: 'empresa',
                  child: Text('Empresas'),
                ),

                DropdownMenuItem(
                  value: 'empleado',
                  child: Text('Empleados'),
                ),

              ],

              onChanged: (value) {

                setState(() {
                  filtroTipo = value!;
                });

                filtrarUsuarios(
                  buscarController.text,
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: TextField(

              controller: buscarController,

              onChanged: filtrarUsuarios,

              decoration: InputDecoration(

                hintText:
                'Buscar por nombre o descripción',

                prefixIcon:
                const Icon(Icons.search),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(

            child: ListView.builder(

              itemCount:
              usuariosFiltrados.length,

              itemBuilder: (context, index) {

                final usuario =
                usuariosFiltrados[index];

                return Card(

                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(

                    leading: CircleAvatar(

                      radius: 24,

                      backgroundImage:
                      usuario['foto_url'] != null &&
                          usuario['foto_url']
                              .toString()
                              .isNotEmpty
                          ? CachedNetworkImageProvider(
                        usuario['foto_url'],
                      )
                          : null,

                      child:
                      usuario['foto_url'] == null ||
                          usuario['foto_url']
                              .toString()
                              .isEmpty
                          ? Text(
                        usuario['nombre']
                            .toString()[0]
                            .toUpperCase(),
                      )
                          : null,
                    ),

                    title: Text(
                      usuario['nombre'] ?? '',
                    ),

                    subtitle: Text(
                      usuario['descripcion'] ?? '',
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                    ),

                    trailing: Icon(
                      usuario['rol'] ==
                          'empresa'
                          ? Icons.business
                          : Icons.person,
                    ),

                    onTap: () {

                      context.push(
                        '/perfil-publico',
                        extra: {
                          'usuarioId':
                          usuario['id']
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavbar(
        userRole: widget.userRole,
        currentIndex: 1,
      ),
    );
  }
}