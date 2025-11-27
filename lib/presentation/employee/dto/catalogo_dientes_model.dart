class CatalogoDientes {
  final int idDiente;
  final String? dienteNumero;
  final String? nombre;
  final int? cuadrante;
  final String? tipo;
  final bool eliminado;

  CatalogoDientes({
    required this.idDiente,
    this.dienteNumero,
    this.nombre,
    this.cuadrante,
    this.tipo,
    this.eliminado = false,
  });

  factory CatalogoDientes.fromJson(Map<String, dynamic> json) {
    return CatalogoDientes(
      idDiente: json['idDiente'],
      dienteNumero: json['dienteNumero'],
      nombre: json['nombre'],
      cuadrante: json['cuadrante'],
      tipo: json['tipo'],
      eliminado: json['eliminado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDiente': idDiente,
      'dienteNumero': dienteNumero,
      'nombre': nombre,
      'cuadrante': cuadrante,
      'tipo': tipo,
      'eliminado': eliminado,
    };
  }
}