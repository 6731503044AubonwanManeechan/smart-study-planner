import 'package:flutter/material.dart';

class AppLanguage extends ChangeNotifier {
  String _language = "en";

  String get language => _language;

  /// ✅ เพิ่มตรงนี้
  Locale get locale => Locale(_language);

  void changeLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  String getText(String en, String th) {
    return _language == "en" ? en : th;
  }
}