import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prototipo1_app/presentation/client/Components/animated_dashboard_card.dart';

class BodyEmployedScreen extends StatelessWidget {
  const BodyEmployedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _responsiveGrid(context),
              const SizedBox(height: 24),
              _earningsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Dashboard | Perfect Teeth',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ---------------- RESPONSIVE GRID ----------------
  Widget _responsiveGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isTablet ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            AnimatedDashboardCard(
              title: 'Promociones',
              value: '4',
              icon: Icons.local_offer,
              color: Colors.orange,
              onTap: () {
                context.push('/categorias');
              },
            ),
            AnimatedDashboardCard(
              title: 'Pacientes',
              value: '128',
              icon: Icons.groups,
              color: Colors.blue,
              onTap: () {
                // 🔹 NO enviamos nada → carga clientes
                context.push('/clientes');
              },
            ),
            const AnimatedDashboardCard(
              title: 'Reseñas',
              value: '56',
              icon: Icons.star_rate,
              color: Colors.amber,
            ),
            AnimatedDashboardCard(
              title: 'Especialistas',
              value: '8',
              icon: Icons.medical_services,
              color: Colors.green,
              onTap: () {
                // 🔥 AQUÍ enviamos idRol = 2
                context.push(
                  '/clientes',
                  extra: 2,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------- EARNINGS SECTION ----------------
  Widget _earningsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _earningsHeader(),
          const SizedBox(height: 16),
          const Text(
            '343.695',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _barChart(),
          const SizedBox(height: 16),
          _statsCTA(context),
        ],
      ),
    );
  }

  Widget _earningsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Gráficos de ingresos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Movimientos',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- BAR CHART ----------------
  Widget _barChart() {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          BarItem(label: 'Jan', height: 60),
          BarItem(label: 'Feb', height: 120),
          BarItem(label: 'Mar', height: 90),
          BarItem(label: 'Apr', height: 150),
        ],
      ),
    );
  }

  // ---------------- CTA ----------------
  Widget _statsCTA(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/estadisticas');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Text(
            'Consultar estadísticas',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

// ---------------- BAR ITEM ----------------
class BarItem extends StatelessWidget {
  final String label;
  final double height;

  const BarItem({
    super.key,
    required this.label,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: height,
            width: 18,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
