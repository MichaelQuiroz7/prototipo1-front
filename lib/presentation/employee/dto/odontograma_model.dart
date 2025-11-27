import 'odontograma_detalle_model.dart';

class Odontograma {
  final int idOdontograma;
  final int idCliente;
  final DateTime fechaRegistro;
  final String? observacionesGenerales;
  final bool eliminado;
  final List<OdontogramaDetalle> detalles;

  Odontograma({
    required this.idOdontograma,
    required this.idCliente,
    required this.fechaRegistro,
    this.observacionesGenerales,
    this.eliminado = false,
    this.detalles = const [],
  });

  factory Odontograma.fromJson(Map<String, dynamic> json) {
    return Odontograma(
      idOdontograma: json['idOdontograma'],
      idCliente: json['idCliente'],
      fechaRegistro:
          DateTime.tryParse(json['fechaRegistro'] ?? '') ?? DateTime.now(),
      observacionesGenerales: json['observacionesGenerales'],
      eliminado: json['eliminado'] ?? false,
      detalles: (json['detalles'] as List? ?? [])
          .map((e) => OdontogramaDetalle.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idOdontograma': idOdontograma,
      'idCliente': idCliente,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'observacionesGenerales': observacionesGenerales,
      'eliminado': eliminado,
      'detalles': detalles.map((e) => e.toJson()).toList(),
    };
  }
}
