import 'package:flutter/material.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currentCurrency = 'Bitcoin';

  String get currentCurrency => _currentCurrency;

  void changeCurrency(String currentCurrency) {
    _currentCurrency = currentCurrency;
    notifyListeners();
  }
}
