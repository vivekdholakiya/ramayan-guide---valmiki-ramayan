import 'package:flutter_test/flutter_test.dart';
import 'package:valmiki_ramayan/models/ramayan_item.dart';
import 'package:valmiki_ramayan/providers/story_access_provider.dart';

void main() {
  group('Story Locking & Access Consistency Tests', () {
    test('Independent locking per category: first 2 free, remaining locked', () {
      final state = StoryAccessState(
        categoryStoryOrder: {
          'cat_a': ['a1', 'a2', 'a3', 'a4'],
          'cat_b': ['b1', 'b2', 'b3', 'b4'],
        },
      );

      // Category A stories
      const itemA1 = RamayanItem(id: 'a1', title: 'A1', description: '', language: 'gu', category: 'cat_a');
      const itemA2 = RamayanItem(id: 'a2', title: 'A2', description: '', language: 'gu', category: 'cat_a');
      const itemA3 = RamayanItem(id: 'a3', title: 'A3', description: '', language: 'gu', category: 'cat_a');
      const itemA4 = RamayanItem(id: 'a4', title: 'A4', description: '', language: 'gu', category: 'cat_a');

      // Test case 1: Category A first 2 are free, 3+ are locked
      expect(state.isStoryLocked(itemA1), isFalse);
      expect(state.isStoryLocked(itemA2), isFalse);
      expect(state.isStoryLocked(itemA3), isTrue);
      expect(state.isStoryLocked(itemA4), isTrue);

      // Category B stories (Test case 8: Independent category count)
      const itemB1 = RamayanItem(id: 'b1', title: 'B1', description: '', language: 'gu', category: 'cat_b');
      const itemB2 = RamayanItem(id: 'b2', title: 'B2', description: '', language: 'gu', category: 'cat_b');
      const itemB3 = RamayanItem(id: 'b3', title: 'B3', description: '', language: 'gu', category: 'cat_b');

      expect(state.isStoryLocked(itemB1), isFalse);
      expect(state.isStoryLocked(itemB2), isFalse);
      expect(state.isStoryLocked(itemB3), isTrue);
    });

    test('Locked story remains locked regardless of where it is rendered (Favorites, Recent)', () {
      final state = StoryAccessState(
        categoryStoryOrder: {
          'cat_a': ['a1', 'a2', 'a3', 'a4'],
        },
      );

      // Story A3 is in Favorites or Recent list
      const favoriteStory = RamayanItem(id: 'a3', title: 'Story in Favs', description: '', language: 'gu', category: 'cat_a');
      const recentStory = RamayanItem(id: 'a3', title: 'Story in Recent', description: '', language: 'gu', category: 'cat_a');

      // Test case 2 & Test case 6:
      expect(state.isStoryLocked(favoriteStory), isTrue);
      expect(state.isStoryLocked(recentStory), isTrue);

      // Free story remains free in Favorites and Recent
      const freeFav = RamayanItem(id: 'a1', title: 'Story 1 in Favs', description: '', language: 'gu', category: 'cat_a');
      expect(state.isStoryLocked(freeFav), isFalse);
    });

    test('Seven Kandas (sath_kand) order calculation: Bal & Ayodhya free, rest locked', () {
      const state = StoryAccessState();

      const balKand = RamayanItem(id: '1', title: 'બાલ કાંડ', description: '', language: 'gu', category: 'sath_kand');
      const ayodhyaKand = RamayanItem(id: '2', title: 'અયોધ્યા કાંડ', description: '', language: 'gu', category: 'sath_kand');
      const aranyaKand = RamayanItem(id: '3', title: 'અરણ્ય કાંડ', description: '', language: 'gu', category: 'sath_kand');
      const kishkindhaKand = RamayanItem(id: '4', title: 'કિષ્કિંધા કાંડ', description: '', language: 'gu', category: 'sath_kand');
      const sundarKand = RamayanItem(id: '5', title: 'સુંદર કાંડ', description: '', language: 'gu', category: 'sath_kand');
      const yuddhaKand = RamayanItem(id: '6', title: 'યુદ્ધ કાંડ', description: '', language: 'gu', category: 'sath_kand');
      const uttarKand = RamayanItem(id: '7', title: 'ઉત્તર કાંડ', description: '', language: 'gu', category: 'sath_kand');

      expect(state.isStoryLocked(balKand), isFalse);
      expect(state.isStoryLocked(ayodhyaKand), isFalse);
      expect(state.isStoryLocked(aranyaKand), isTrue);
      expect(state.isStoryLocked(kishkindhaKand), isTrue);
      expect(state.isStoryLocked(sundarKand), isTrue);
      expect(state.isStoryLocked(yuddhaKand), isTrue);
      expect(state.isStoryLocked(uttarKand), isTrue);
    });
  });
}
