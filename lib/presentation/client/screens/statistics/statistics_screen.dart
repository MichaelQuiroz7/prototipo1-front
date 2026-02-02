import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/citas/dtos/cita_entity.dart';
import 'package:prototipo1_app/presentation/client/Components/monthly_bar_chart.dart';
import 'package:prototipo1_app/presentation/client/Components/simple_bar_chart.dart';
import 'package:prototipo1_app/presentation/client/providers/helper/employed_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _estadoSeleccionado = 'pendiente';
  String _modoGrafico = '6m'; 

  final List<String> _estados = [
    'pendiente',
    'asistio',
    'no_asistio',
    'cancelada',
    'reagendada',
  ];

  // ===============================
  // BUILD
  // ===============================

  @override
  Widget build(BuildContext context) {
    final primaryColorTheme = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Estadísticas", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<CitaEntity>>(
        key: ValueKey("$_estadoSeleccionado-$_modoGrafico"),
        future: _cargarCitasPorEstado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error cargando citas"));
          }

          final citasEstado = snapshot.data ?? [];

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth > 600;
              final double horizontalPadding = isTablet ? 24 : 16;
              final double iconSize = isTablet ? 56 : 48;

              return SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- Estados ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _estados.map((estado) {
                        final activo = estado == _estadoSeleccionado;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _estadoSeleccionado = estado;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                height: iconSize,
                                width: iconSize,
                                decoration: BoxDecoration(
                                  color: activo
                                      ? Colors.blue.shade200
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _iconoPorEstado(estado),
                                  color:
                                      activo ? Colors.blue : Colors.grey[600],
                                  size: iconSize * 0.45,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _labelEstado(estado),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: activo
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      activo ? Colors.blue : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ---------------- Gráfico ----------------
                    _containerGrafico(citasEstado, primaryColorTheme),

                    const SizedBox(height: 24),

                    // ---------------- Resumen ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Resumen · ${_labelEstado(_estadoSeleccionado)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.date_range, size: 18),
                          onSelected: (value) {
                            setState(() {
                              _modoGrafico = value;
                            });
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: '6m', child: Text("6 meses")),
                            PopupMenuItem(value: 'mes', child: Text("Mensual")),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ---------------- Métricas ----------------
                    GridView.count(
                      crossAxisCount: isTablet ? 3 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isTablet ? 1.6 : 1.4,
                      children: [
                        _MetricCard(
                          title: "TOTAL CITAS",
                          value: citasEstado.length.toString(),
                        ),
                        _MetricCard(
                          title: "INGRESOS",
                          value:
                              "\$${_calcularIngresos(citasEstado).toStringAsFixed(2)}",
                        ),
                        _MetricCard(
                          title: "ELIMINADAS",
                          value: citasEstado
                              .where((c) => c.eliminado == true)
                              .length
                              .toString(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------------- Lista ----------------
                    Text(
                      "Citas (${citasEstado.length})",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    ...citasEstado.map(_citaTile),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===============================
  // DATA LOAD
  // ===============================

  Future<List<CitaEntity>> _cargarCitasPorEstado() async {
    List<CitaEntity> citas;

    switch (_estadoSeleccionado) {
      case 'pendiente':
        citas = await EmployedHelper.obtenerPendientes();
        break;
      case 'asistio':
        citas = await EmployedHelper.obtenerAsistidas();
        break;
      case 'no_asistio':
        citas = await EmployedHelper.obtenerNoAsistidas();
        break;
      case 'cancelada':
        citas = await EmployedHelper.obtenerCanceladas();
        break;
      case 'reagendada':
        citas = await EmployedHelper.obtenerReagendadas();
        break;
      default:
        citas = await EmployedHelper.consultarTodas();
    }

    debugPrint("→ Estado: $_estadoSeleccionado → ${citas.length} citas");
    for (final c in citas) {
      debugPrint("   ${c.fecha} - ${c.estado} - eliminado=${c.eliminado}");
    }

    return citas;
  }

  // ===============================
  // GRÁFICO
  // ===============================

  Widget _containerGrafico(
    List<CitaEntity> citasEstado,
    Color primaryColorTheme,
  ) {
    final Map<String, double> data = _modoGrafico == 'mes'
        ? _datosPorMesSeleccionado(
            citasEstado,
            mes: DateTime.now().month,
            anio: DateTime.now().year,
          )
        : _datosUltimos6Meses(citasEstado);

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _modoGrafico == 'mes'
          ? MonthlyBarChart(data: data, barColor: primaryColorTheme)
          : SimpleBarChart(data: data, barColor: primaryColorTheme),
    );
  }

  // ===============================
  // MAPEO A GRÁFICA
  // ===============================

  Map<String, double> _datosUltimos6Meses(List<CitaEntity> todas) {
    final now = DateTime.now();

    // Construir rango de últimos 6 meses
    final inicio = DateTime(now.year, now.month - 5, 1);
    final fin = DateTime(now.year, now.month + 1, 0);

    final rango = DateTimeRange(start: inicio, end: fin);

    // Usar helper para filtrar por fechas
    final filtradas = EmployedHelper.filtrarPorRangoFechas(
      citas: todas,
      rango: rango,
    );

    // Inicializar mapa con los 6 meses
    final Map<String, double> result = {};

    for (int i = 5; i >= 0; i--) {
      final mes = DateTime(now.year, now.month - i, 1);
      final label = "${mes.month}/${mes.year.toString().substring(2)}";
      result[label] = 0.0;
    }

    // Acumular precios por mes
    for (final c in filtradas) {
      // if (c.eliminado == true) continue;

      try {
        final fecha = DateTime.parse(c.fecha);
        final label = "${fecha.month}/${fecha.year.toString().substring(2)}";

        if (result.containsKey(label)) {
          result[label] = result[label]! + 1;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("⚠️ Error parseando fecha en gráfica: ${c.fecha}");
        }
      }
    }

    return result;
  }

  Map<String, double> _datosPorMesSeleccionado(
    List<CitaEntity> citas, {
    required int mes,
    required int anio,
  }) {
    final totalDias = DateTime(anio, mes + 1, 0).day;
    final Map<String, double> result = {};

    for (int i = 1; i <= totalDias; i++) {
      result["$i"] = 0.0;
    }

    for (final c in citas) {
      // if (c.eliminado == true) continue;

      try {
        final fecha = DateTime.parse(c.fecha);

        if (fecha.month == mes && fecha.year == anio) {
          final key = "${fecha.day}";
          result[key] = result[key]! + 1;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("⚠️ Error parseando fecha mensual: ${c.fecha}");
        }
      }
    }

    return result;
  }

  // ===============================
  // MÉTRICAS
  // ===============================

  double _calcularIngresos(List<CitaEntity> citas) {
    return citas
        // .where((c) => c.eliminado == false)
        .fold(0.0, (sum, c) => sum + c.precio);
  }

  // ===============================
  // UI HELPERS
  // ===============================

  IconData _iconoPorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'asistio':
        return Icons.check_circle;
      case 'no_asistio':
        return Icons.cancel;
      case 'cancelada':
        return Icons.block;
      case 'reagendada':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'asistio':
        return 'Asistió';
      case 'no_asistio':
        return 'No asistió';
      case 'cancelada':
        return 'Cancelada';
      case 'reagendada':
        return 'Reagendada';
      default:
        return estado;
    }
  }

  Widget _citaTile(CitaEntity c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_iconoPorEstado(c.estado), color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.nombreTratamiento,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  "${c.fecha} · ${c.horaInicio}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "\$${c.precio.toStringAsFixed(2)}",
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ======================================================
//  MÉTRICA
// ======================================================
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
