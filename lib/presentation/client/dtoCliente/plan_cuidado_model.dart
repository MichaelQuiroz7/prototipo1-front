class PlanCuidadoUI {
  final String estadoGeneral;
  final String riesgos;
  final List<ProductoUI> productos;
  final bool necesitaCita;

  PlanCuidadoUI({
    required this.estadoGeneral,
    required this.riesgos,
    required this.productos,
    required this.necesitaCita,
  });
}

class ProductoUI {
  final String nombre;
  final String precio;
  final String link;

  ProductoUI({
    required this.nombre,
    required this.precio,
    required this.link,
  });
}
