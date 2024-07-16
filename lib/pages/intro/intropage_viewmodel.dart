import 'package:propertysmart2/export/file_exports.dart';
import 'package:flutter/material.dart';

class IntroPageViewModel extends BaseViewModel {
  late PageController pageController;

  void init() {
    pageController = PageController();
    notifyListeners();
  }

  void pageNavigator(int index) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> navigateToView(BuildContext context, Widget view) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => view));
    notifyListeners();
  }
}
