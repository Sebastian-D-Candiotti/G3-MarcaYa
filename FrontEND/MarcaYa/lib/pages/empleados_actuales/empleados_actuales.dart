import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';

class EmpleadosActualesPage extends StatelessWidget {
  const EmpleadosActualesPage({super.key});

  @override
  Widget build(BuildContext context) {

    // MOCK TEMPORAL
    final obras = [
      {
        'obra': 'OBRA PRUEBA',
        'empleados': [
          'Juan Perez',
          'Carlos Ruiz',
        ]
      },
      {
        'obra': 'sa',
        'empleados': [
          'Pedro Gomez',
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: obras.length,
        itemBuilder: (context, index) {

          final obra = obras[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      const Icon(
                        Icons.construction,
                        color: Colors.teal,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          obra['obra'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(obra['empleados'] as List).length} empleados',
                        ),
                      )
                    ],
                  ),

                  const Divider(height: 25),

                  ...(obra['empleados'] as List).map(
                        (empleado) => ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),

                      title: Text(
                        empleado.toString(),
                      ),

                      trailing: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver perfil',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 2,
      ),
    );
  }
}