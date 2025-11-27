class OdontoColor {
  final int idColor;
  final String colorNombre;
  final String colorHex;
  final String uso;
  final String significadoClinico;
  final bool eliminado;

  OdontoColor({
    required this.idColor,
    required this.colorNombre,
    required this.colorHex,
    required this.uso,
    required this.significadoClinico,
    this.eliminado = false,
  });

  factory OdontoColor.fromJson(Map<String, dynamic> json) {
    return OdontoColor(
      idColor: json['idColor'],
      colorNombre: json['colorNombre'],
      colorHex: json['colorHex'],
      uso: json['uso'],
      significadoClinico: json['significadoClinico'],
      eliminado: json['eliminado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idColor': idColor,
      'colorNombre': colorNombre,
      'colorHex': colorHex,
      'uso': uso,
      'significadoClinico': significadoClinico,
      'eliminado': eliminado,
    };
  }
}
