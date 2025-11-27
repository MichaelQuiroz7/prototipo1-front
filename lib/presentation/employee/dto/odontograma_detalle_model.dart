import 'catalogo_dientes_model.dart';
import 'odontocolor_model.dart';

class OdontogramaDetalle {
  int idDetalle;
  int idOdontograma;
  int idDiente;

  // Campos editables
  int idColor;
  String estado;
  String? observacion;

  bool eliminado;

  CatalogoDientes? diente;
  OdontoColor? color;

  OdontogramaDetalle({
    required this.idDetalle,
    required this.idOdontograma,
    required this.idDiente,
    required this.idColor,
    required this.estado,
    this.observacion,
    this.eliminado = false,
    this.diente,
    this.color,
  });

  factory OdontogramaDetalle.fromJson(Map<String, dynamic> json) {
    return OdontogramaDetalle(
      idDetalle: json['idDetalle'] ?? json['id_detalle'],
      idOdontograma: json['idOdontograma'] ?? json['id_odontograma'],
      idDiente: json['idDiente'] ?? json['id_diente'],
      idColor: json['idColor'] ?? json['id_color'],
      estado: json['estado'] ?? '',
      observacion: json['observacion'],
      eliminado: json['eliminado'] ?? false,
      diente: json['diente'] != null
          ? CatalogoDientes.fromJson(json['diente'])
          : null,
      color: json['color'] != null
          ? OdontoColor.fromJson(json['color'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetalle': idDetalle,
      'idOdontograma': idOdontograma,
      'idDiente': idDiente,
      'idColor': idColor,
      'estado': estado,
      'observacion': observacion,
      'eliminado': eliminado,
      'diente': diente?.toJson(),
      'color': color?.toJson(),
    };
  }
}
