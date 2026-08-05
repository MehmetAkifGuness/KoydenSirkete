import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  String? _selectedAction;

  String? get selectedAction => _selectedAction;

  void selectAction(String action) {
    _selectedAction = action;
    notifyListeners();
  }
}
