import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static DateTime dayOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String formatDate(DateTime value) {
    return DateFormat('dd MMM yyyy').format(value);
  }

  static String formatDay(DateTime value) {
    return DateFormat('EEE, dd MMM').format(value);
  }

  static String formatTimeRange(int startMinute, int endMinute) {
    final String start = _formatMinutes(startMinute);
    final String end = _formatMinutes(endMinute);
    return '$start - $end';
  }

  static String _formatMinutes(int minutes) {
    final int hour = minutes ~/ 60;
    final int minute = minutes % 60;
    final DateTime value = DateTime(2024, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(value);
  }

  static int toMinutes(TimeOfDay value) {
    return value.hour * 60 + value.minute;
  }

  static TimeOfDay fromMinutes(int value) {
    return TimeOfDay(hour: value ~/ 60, minute: value % 60);
  }
}
