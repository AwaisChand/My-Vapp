import 'package:flutter/foundation.dart';

/// Bottom navigation order:
/// 0 Cash · 1 Offer · 2 Home · 3 Economy · 4 Vapofumeur
class BottomNavIndex {
  static const cash = 0;
  static const offer = 1;
  static const home = 2;
  static const economy = 3;
  static const vapofumeur = 4;
}

class BottomNavViewModel extends ChangeNotifier {
  int selectedIndex = BottomNavIndex.home;

  void selectTab(int index) {
    if (index < 0 || index > BottomNavIndex.vapofumeur || selectedIndex == index) {
      return;
    }
    selectedIndex = index;
    notifyListeners();
  }

  void goHome() => selectTab(BottomNavIndex.home);
}
