import 'package:flutter/material.dart';

class CropHealthProvider extends ChangeNotifier {
  String _lastDiagnosis = '';

  String get lastDiagnosis => _lastDiagnosis;
  bool get hasDiagnosis => _lastDiagnosis.isNotEmpty;

  void updateDiagnosis(String diagnosis) {
    _lastDiagnosis = diagnosis;
    notifyListeners();
  }

  void clearDiagnosis() {
    _lastDiagnosis = '';
    notifyListeners();
  }
}
