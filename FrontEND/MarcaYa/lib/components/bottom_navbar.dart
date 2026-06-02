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

  List<_NavItem> get _items {
    if (userRole == 'empresa') {
      return const [
        _NavItem(Icons.home, 'Inicio', '/empresa'),
        _NavItem(Icons.search, 'Buscar', '/empresa/buscar'),
        _NavItem(Icons.request_page, 'Solicitudes', '/empresa/solicitudes'),
        _NavItem(Icons.business, 'Obras', '/empresa/obras'),
        _NavItem(Icons.person, 'Perfil', '/empresa/perfil'),
      ];
    }
    return const [
      _NavItem(Icons.home, 'Inicio', '/empleado'),
      _NavItem(Icons.search, 'Buscar', '/empleado/buscar'),
      _NavItem(Icons.person, 'Perfil', '/empleado/perfil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return BottomNavigationBar(
      currentIndex: currentIndex < items.length ? currentIndex : 0,
      onTap: (index) {
        if (index < items.length) {
          context.go(items[index].route);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.label, this.route);
}
