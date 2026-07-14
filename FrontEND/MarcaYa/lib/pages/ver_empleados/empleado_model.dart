import 'package:flutter/material.dart';

/// Employee status enum.
enum EstadoEmpleado { activo, inactivo }

/// Employee data model used across the employee list view.
class Empleado {
  final String id;
  final String nombre;
  final String dni;
  final String iniciales;
  final Color avatarColor;
  final int asistencias;
  final int tardanzas;
  EstadoEmpleado estado;
  final int? usuarioId;

  Empleado({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.iniciales,
    required this.avatarColor,
    required this.asistencias,
    required this.tardanzas,
    this.estado = EstadoEmpleado.activo,
    this.usuarioId,
  });
}
