import 'package:flutter/material.dart';

class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  bool isAvailable;

  TimeSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  String get label =>
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
      '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
}


List<TimeSlot> generateTimeSlots() {
  final List<TimeSlot> slots = [];
  TimeOfDay current = const TimeOfDay(hour: 9, minute: 0);

  while (true) {
    final endMinuteTotal = current.hour * 60 + current.minute + 30;
    final endHour = endMinuteTotal ~/ 60;
    final endMinute = endMinuteTotal % 60;

    if (endHour > 19 || (endHour == 19 && endMinute > 0)) break;

    final end = TimeOfDay(hour: endHour, minute: endMinute);

    final isLunchTime =
        current.hour == 12 || (current.hour == 12 && current.minute < 30);

    slots.add(
      TimeSlot(
        start: current,
        end: end,
        isAvailable: !isLunchTime,
      ),
    );

    current = end;
  }

  return slots;
}



