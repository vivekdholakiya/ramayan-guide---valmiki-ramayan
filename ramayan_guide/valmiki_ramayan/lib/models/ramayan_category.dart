import 'package:flutter/material.dart';

/// RamayanCategory model representing each of the 8 main categories in the Ramayan.
class RamayanCategory {
  final String id;
  final String gu;
  final String hi;
  final String en;
  final IconData icon;
  final String imageAsset;

  const RamayanCategory({
    required this.id,
    required this.gu,
    required this.hi,
    required this.en,
    required this.icon,
    required this.imageAsset,
  });

  /// Helper getter to retrieve localized title based on language code.
  String getLocalizedTitle(String languageCode) {
    switch (languageCode) {
      case 'gu':
        return gu;
      case 'hi':
        return hi;
      case 'en':
      default:
        return en;
    }
  }

  /// The 8 primary categories corresponding to Firestore subcollection IDs under RamayanaData/gu/.
  static const List<RamayanCategory> categories = [
    RamayanCategory(
      id: 'sath_kand',
      gu: 'સાત કાંડ',
      hi: 'सात कांड',
      en: 'Seven Kandas',
      icon: Icons.menu_book_rounded,
      imageAsset: 'assets/images/seven_kand.png',
    ),
    RamayanCategory(
      id: 'rishio',
      gu: 'ઋષિઓ',
      hi: 'ऋषि मुनि',
      en: 'Rishis & Sages',
      icon: Icons.self_improvement_rounded,
      imageAsset: 'assets/images/rishis.png',
    ),
    RamayanCategory(
      id: 'vanaro',
      gu: 'વાનરો',
      hi: 'વાનર',
      en: 'Vanaras',
      icon: Icons.pets_rounded,
      imageAsset: 'assets/images/vanaras.png',
    ),
    RamayanCategory(
      id: 'rakshaso',
      gu: 'રાક્ષસો',
      hi: 'राक्षस',
      en: 'Rakshasas',
      icon: Icons.shield_rounded,
      imageAsset: 'assets/images/rakshasas.png',
    ),
    RamayanCategory(
      id: 'anya_patrono',
      gu: 'અન્ય પાત્રો',
      hi: 'अन्य पात्र',
      en: 'Other Characters',
      icon: Icons.groups_rounded,
      imageAsset: 'assets/images/other_char.png',
    ),
    RamayanCategory(
      id: 'mukhya_sthalo',
      gu: 'મુખ્ય સ્થળો',
      hi: 'मुख्य स्थल',
      en: 'Key Places',
      icon: Icons.explore_rounded,
      imageAsset: 'assets/images/places.png',
    ),
    RamayanCategory(
      id: 'temples',
      gu: 'મંદિરો',
      hi: 'मंदिर',
      en: 'Temples',
      icon: Icons.account_balance_rounded,
      imageAsset: 'assets/images/temples.png',
    ),
    RamayanCategory(
      id: 'divya_astro',
      gu: 'દિવ્ય અસ્ત્રો',
      hi: 'दिव्य अस्त्र',
      en: 'Divine Weapons',
      icon: Icons.auto_awesome_rounded,
      imageAsset: 'assets/images/divine_weapons.png',
    ),
  ];

  static RamayanCategory? findById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
