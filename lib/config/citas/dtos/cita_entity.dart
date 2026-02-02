class CitaEntity {
  final int? idCita;
  final int idCliente;
  final int idTratamiento;
  final String nombreTratamiento;
  final double precio;
  final String fecha; // yyyy-MM-dd
  final String horaInicio; // HH:mm
  final String horaFin; // HH:mm
  final String estado;
  final bool eliminado;
  final DateTime? fechaCreacion;

  CitaEntity({
    this.idCita,
    required this.idCliente,
    required this.idTratamiento,
    required this.nombreTratamiento,
    required this.precio,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.estado = 'pendiente',
    this.eliminado = false,
    this.fechaCreacion,
  });

  factory CitaEntity.fromJson(Map<String, dynamic> json) {
    return CitaEntity(
      idCita: json['idCita'],
      idCliente: json['idCliente'],
      idTratamiento: json['idTratamiento'],
      nombreTratamiento: json['nombreTratamiento'],
      precio: double.parse(json['precio'].toString()),
      fecha: json['fecha'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      estado: json['estado'],
      eliminado: json['eliminado'],
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCliente': idCliente,
      'idTratamiento': idTratamiento,
      'nombreTratamiento': nombreTratamiento,
      'precio': precio,
      'fecha': fecha,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'estado': estado,
    };
  }




}


