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

  static const _empresaItems = [
    _NavItem(label: 'Inicio', icon: Icons.home, route: '/empresa'),
    _NavItem(label: 'Sitios', icon: Icons.location_on, route: '/empresa/paradas'),
    _NavItem(label: 'Empleados', icon: Icons.group, route: '/empresa/empleados'),
    _NavItem(label: 'Solicitudes', icon: Icons.request_page, route: '/empresa/solicitudes'),
  ];

  static const _empleadoItems = [
    _NavItem(label: 'Inicio', icon: Icons.home, route: '/empleado'),
    _NavItem(label: 'Asistencia', icon: Icons.fingerprint, route: '/empleado/asistencia'),
    _NavItem(label: 'Buscar', icon: Icons.search, route: '/empleado/buscar'),
    _NavItem(label: 'Mi Perfil', icon: Icons.person, route: '/empleado/perfil'),
  ];

  List<_NavItem> get _items =>
      userRole == 'empresa' ? _empresaItems : _empleadoItems;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex.clamp(0, _items.length - 1),
      onTap: (index) {
        if (index < _items.length) {
          context.go(_items[index].route);
        }
      },
      items: _items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
