import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/client/screens/Home/home_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/calendar/calendar_screen.dart';
//import 'package:prototipo1_app/presentation/client/screens/citas/appointment_schedule_screen.dart';
//import 'package:prototipo1_app/util/notification_service.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -10),
            blurRadius: 35,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.38),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // HOME
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: Icon(
              Icons.home,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // CALENDARIO
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
            icon: Icon(
              Icons.calendar_month,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // 🔔 NOTIFICACIÓN
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: Icon(
              Icons.add_task,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
