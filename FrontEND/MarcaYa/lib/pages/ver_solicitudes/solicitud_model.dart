import 'package:flutter/material.dart';

/// Request status enum.
enum EstadoSolicitud { pendiente, aceptada, rechazada }

/// Income request data model used across the solicitudes list view.
class SolicitudIngreso {
  final String id;
  final String nombre;
  final String dni;
  final String fecha;
  final String iniciales;
  final Color avatarColor;
  final double valoracionPromedio;
  EstadoSolicitud estado;
  String? motivoRechazo;

  SolicitudIngreso({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.fecha,
    required this.iniciales,
    required this.avatarColor,
    required this.valoracionPromedio,
    this.estado = EstadoSolicitud.pendiente,
    this.motivoRechazo,
  });
}
