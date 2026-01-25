// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.


/// A time of day without Material dependency.
class TimeOfDay {
  const TimeOfDay({required this.hour, required this.minute});
  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) {
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  String format(bool use24Hour) {
    if (use24Hour) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm';
  }

  TimeOfDay replacing({int? hour, int? minute}) {
    return TimeOfDay(hour: hour ?? this.hour, minute: minute ?? this.minute);
  }

  @override
  String toString() {
    return 'TimeOfDay(${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})';
  }
}
