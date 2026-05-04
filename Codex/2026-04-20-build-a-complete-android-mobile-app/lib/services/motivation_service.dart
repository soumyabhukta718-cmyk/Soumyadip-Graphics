import '../models/motivation_item.dart';

class MotivationService {
  static const List<MotivationItem> _items = <MotivationItem>[
    MotivationItem(
      english: 'Small focused sessions beat random long hours.',
      bengali: 'ছোট কিন্তু মনোযোগী সেশন এলোমেলো দীর্ঘ পড়ার চেয়ে বেশি কার্যকর।',
      tip: 'Start with the toughest subject first while your energy is fresh.',
    ),
    MotivationItem(
      english: 'Every page you revise today reduces exam fear tomorrow.',
      bengali: 'আজকের প্রতিটি revision আগামী দিনের exam fear কমায়।',
      tip: 'Keep your phone away for the first 20 minutes of study.',
    ),
    MotivationItem(
      english: 'Consistency creates confidence.',
      bengali: 'নিয়মিত চর্চাই আত্মবিশ্বাস তৈরি করে।',
      tip: 'Use one notebook to track formulas, facts, and mistakes.',
    ),
    MotivationItem(
      english: 'Your next mock test improves when today’s basics become clear.',
      bengali: 'আজকের basic পরিষ্কার হলে আগামী mock test আরও ভালো হবে।',
      tip: 'After every topic, ask: what, why, and how is it solved?',
    ),
  ];

  MotivationItem forDate(DateTime date) {
    final int index = date.dayOfYear % _items.length;
    return _items[index];
  }
}

extension on DateTime {
  int get dayOfYear {
    final DateTime start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}
