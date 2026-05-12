import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color voidBlack = Color(0xFF05070D);
  static const Color midnight = Color(0xFF071119);
  static const Color charcoal = Color(0xFF101923);
  static const Color obsidian = Color(0xFF12131C);
  static const Color surface = Color(0xFF14202A);
  static const Color surfaceHigh = Color(0xFF1A2A35);
  static const Color surfaceSoft = Color(0xFF202D36);

  static const Color pearl = Color(0xFFF3F7EF);
  static const Color pearlMuted = Color(0xFFB8C7C3);
  static const Color textDim = Color(0xFF7F918E);
  static const Color ink = Color(0xFF102126);

  static const Color scannerCyan = Color(0xFF36F5E5);
  static const Color scannerTeal = Color(0xFF00CBBF);
  static const Color scannerDeep = Color(0xFF0D817F);
  static const Color rewardGold = Color(0xFFFFC857);
  static const Color amber = Color(0xFFFFA947);
  static const Color ember = Color(0xFFFF6B4A);
  static const Color violet = Color(0xFF7B61FF);

  static const Color primary = scannerTeal;
  static const Color primaryLight = scannerCyan;
  static const Color primaryDark = scannerDeep;
  static const Color secondary = rewardGold;
  static const Color secondaryLight = Color(0xFFFFDF85);
  static const Color accent = amber;
  static const Color accentLight = Color(0xFFFFD7A1);

  static const Color lightBg = Color(0xFFF5F7F1);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF142027);
  static const Color lightTextSecondary = Color(0xFF5F6F6B);

  static const Color darkBg = midnight;
  static const Color darkCard = surface;
  static const Color darkText = pearl;
  static const Color darkTextSecondary = pearlMuted;
  static const Color darkSurface = surfaceHigh;

  static const Color fire = Color(0xFFFF5F4A);
  static const Color water = Color(0xFF3BA7FF);
  static const Color earth = Color(0xFFB8895B);
  static const Color air = Color(0xFF9DD8FF);
  static const Color electric = Color(0xFFFFE15A);
  static const Color nature = Color(0xFF43D17A);
  static const Color shadow = Color(0xFF8B6CFF);
  static const Color light = Color(0xFFFFF5D6);

  static const Color rarityCommon = Color(0xFF8FA09B);
  static const Color rarityUncommon = Color(0xFF43D17A);
  static const Color rarityRare = Color(0xFF3BA7FF);
  static const Color rarityEpic = Color(0xFFB567FF);
  static const Color rarityLegendary = rewardGold;

  static const Color success = nature;
  static const Color warning = rewardGold;
  static const Color error = ember;
  static const Color info = water;

  static const LinearGradient appBackdrop = LinearGradient(
    colors: [voidBlack, midnight, Color(0xFF0F1820)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient scanGradient = LinearGradient(
    colors: [scannerCyan, scannerTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rewardGradient = LinearGradient(
    colors: [rewardGold, amber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = scanGradient;

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [surfaceHigh, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rarityLegendaryGradient = LinearGradient(
    colors: [rewardGold, Color(0xFFFF7F4F), Color(0xFFE9F2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return fire;
      case 'water':
        return water;
      case 'earth':
        return earth;
      case 'air':
        return air;
      case 'electric':
        return electric;
      case 'nature':
        return nature;
      case 'shadow':
        return shadow;
      case 'light':
        return light;
      default:
        return scannerTeal;
    }
  }

  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return rarityCommon;
      case 'uncommon':
        return rarityUncommon;
      case 'rare':
        return rarityRare;
      case 'epic':
        return rarityEpic;
      case 'legendary':
        return rarityLegendary;
      default:
        return rarityCommon;
    }
  }
}
