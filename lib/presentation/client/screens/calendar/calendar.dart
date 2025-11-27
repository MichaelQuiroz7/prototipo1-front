import 'package:flutter/material.dart';

class Appointment {
  final DateTime date;
  final String dentist;
  final String time;

  Appointment({required this.date, required this.dentist, required this.time});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentMonth = DateTime.now();

  final List<Appointment> appointments = [
    Appointment(date: DateTime(2025, 10, 22), dentist: 'Dra. Ana Pérez', time: '09:00'),
    Appointment(date: DateTime(2025, 10, 25), dentist: 'Dr. Luis Gómez', time: '15:30'),
    Appointment(date: DateTime(2025, 11, 2), dentist: 'Dra. Carla Ruiz', time: '11:00'),
  ];

  List<DateTime> getDaysInMonth(DateTime month) {
    //final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(lastDay.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citas reservadas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMonthHeader(),
            const SizedBox(height: 12),
            buildCalendarGrid(),
            const SizedBox(height: 20),
            const Text('Citas del mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildAppointmentList(),
          ],
        ),
      ),
    );
  }

  Widget buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
            });
          },
        ),
        Text(
          '${getMonthName(currentMonth.month)} ${currentMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget buildCalendarGrid() {
    final days = getDaysInMonth(currentMonth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final hasAppointment = appointments.any((a) =>
            a.date.year == day.year &&
            a.date.month == day.month &&
            a.date.day == day.day);

        return GestureDetector(
          onTap: () {
            // Puedes agregar lógica para filtrar citas por día
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text('${day.day}'),
                if (hasAppointment)
                  const Positioned(
                    bottom: 4,
                    child: Icon(Icons.star, size: 16, color: Colors.orange),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildAppointmentList() {
    final filtered = appointments.where((a) =>
        a.date.month == currentMonth.month &&
        a.date.year == currentMonth.year).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No hay citas este mes.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: filtered.map((a) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.medical_services, color: Colors.blue),
            title: Text(a.dentist),
            subtitle: Text('${a.date.day}/${a.date.month}/${a.date.year} - ${a.time}'),
          ),
        );
      }).toList(),
    );
  }

  String getMonthName(int month) {
    const names = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return names[month - 1];
  }
}