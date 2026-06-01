import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  final String userRole;
  final int currentIndex;

  const BottomNavbar({
    super.key,
    required this.userRole,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final String baseRoute =
    userRole == 'empresa'
        ? '/empresa'
        : '/empleado';

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(baseRoute);
            break;

          case 1:
            context.go('$baseRoute/buscar');
            break;

          case 2:
            context.go('$baseRoute/perfil');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}