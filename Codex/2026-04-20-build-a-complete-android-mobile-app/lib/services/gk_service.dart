import '../models/gk_item.dart';

class GkService {
  static const List<GkItem> _items = <GkItem>[
    GkItem(
      title: 'Indian Constitution',
      summary: 'The Constitution of India came into effect on 26 January 1950.',
      category: 'Polity',
    ),
    GkItem(
      title: 'Sundarbans',
      summary: 'The Sundarbans is the largest mangrove forest in the world.',
      category: 'Geography',
    ),
    GkItem(
      title: 'Nobel Prize',
      summary: 'Rabindranath Tagore was the first non-European Nobel laureate in Literature.',
      category: 'History',
    ),
    GkItem(
      title: 'Photosynthesis',
      summary: 'Plants prepare food using sunlight, chlorophyll, carbon dioxide, and water.',
      category: 'Science',
    ),
    GkItem(
      title: 'RBI',
      summary: 'The Reserve Bank of India was established in 1935.',
      category: 'Economy',
    ),
  ];

  List<GkItem> todayFeed(DateTime date) {
    final int start = date.day % _items.length;
    return List<GkItem>.generate(
      3,
      (int index) => _items[(start + index) % _items.length],
    );
  }
}
