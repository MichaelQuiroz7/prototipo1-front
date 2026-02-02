import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/promociones/dto/promocion.dto.dart';
import 'package:prototipo1_app/config/promociones/promotions_services.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class PromocionModal extends StatefulWidget {
  final Tratamiento tratamiento;
  final Promocion? promocion;
  final VoidCallback onSuccess;

  const PromocionModal({
    super.key,
    required this.tratamiento,
    required this.onSuccess,
    this.promocion,
  });

  @override
  State<PromocionModal> createState() => _PromocionModalState();
}

class _PromocionModalState extends State<PromocionModal> {
  final _formKey = GlobalKey<FormState>();

  final _precioAntesController = TextEditingController();
  final _precioAhoraController = TextEditingController();
  final _limiteController = TextEditingController(text: "100");

  bool es2x1 = false;
  DateTime? fechaFin;

  final PromocionesService _service = PromocionesService();

  @override
  void initState() {
    super.initState();

    _precioAntesController.text =
        widget.tratamiento.precio.toString();

    if (widget.promocion != null) {
      final p = widget.promocion!;

      _precioAntesController.text = p.precioAntes.toString();
      _precioAhoraController.text =
          p.precioAhora == p.precioAntes ? "" : p.precioAhora.toString();

      es2x1 = p.es2x1;
      fechaFin = p.fechaFin;
      _limiteController.text = p.limite.toString();
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        fechaFin = picked;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione fecha fin"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final precioAntes = double.parse(_precioAntesController.text);
    final precioAhora = _precioAhoraController.text.isEmpty
        ? precioAntes
        : double.parse(_precioAhoraController.text);

    try {
      if (widget.promocion == null) {
        await _service.crearPromocion(
          Promocion(
            idTratamiento: widget.tratamiento.idTratamiento,
            precioAntes: precioAntes,
            precioAhora: precioAhora,
            es2x1: es2x1,
            fechaInicio: DateTime.now(),
            fechaFin: fechaFin!,
            limite: int.parse(_limiteController.text),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Promoción agregada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _service.actualizarPromocion(
          Promocion(
            idPromocion: widget.promocion!.idPromocion,
            idTratamiento: widget.tratamiento.idTratamiento,
            precioAntes: precioAntes,
            precioAhora: precioAhora,
            es2x1: es2x1,
            fechaInicio: widget.promocion!.fechaInicio,
            fechaFin: fechaFin!,
            limite: int.parse(_limiteController.text),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Promoción actualizada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onSuccess();

      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.promocion != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF7CCFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? "Editar Promoción" : "Nueva Promoción",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.tratamiento.nombre,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 25),
                          _customField(
                            controller: _precioAntesController,
                            label: "Precio Antes",
                          ),
                          const SizedBox(height: 15),
                          _customField(
                            controller: _precioAhoraController,
                            label: "Precio Promoción (Opcional)",
                            isRequired: false,
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: _seleccionarFecha,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 18),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    fechaFin == null
                                        ? "Promoción hasta"
                                        : "Hasta: ${fechaFin!.day}/${fechaFin!.month}/${fechaFin!.year}",
                                  ),
                                  const Icon(Icons.calendar_month),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _customField(
                            controller: _limiteController,
                            label: "Número de beneficiarios",
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Aplicar 2 x 1"),
                              Switch(
                                value: es2x1,
                                onChanged: (v) {
                                  setState(() {
                                    es2x1 = v;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _guardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                isEdit
                                    ? "Actualizar Promoción"
                                    : "Guardar Promoción",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _customField({
    required TextEditingController controller,
    required String label,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (!isRequired) return null;
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
