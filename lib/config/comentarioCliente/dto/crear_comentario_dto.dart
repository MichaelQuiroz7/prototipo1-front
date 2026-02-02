class CrearComentarioDto {
  final int idCliente;
  final double puntuacion;
  final String feedback;

  CrearComentarioDto({
    required this.idCliente,
    required this.puntuacion,
    required this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'idCliente': idCliente,
      'puntuacion': puntuacion,
      'feedback': feedback,
    };
  }
}
