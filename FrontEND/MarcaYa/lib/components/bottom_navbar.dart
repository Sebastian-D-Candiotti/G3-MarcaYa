import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {

  final int currentIndex;

  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(

      currentIndex: currentIndex,

      onTap: onTap,

      backgroundColor: Colors.black,

      selectedItemColor: Colors.amber,

      unselectedItemColor: Colors.white70,

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