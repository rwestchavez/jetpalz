import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  List<String> ventureCountries = [];
  List<String> ventureIndustries = [];
  int? maxPeople;
  String? ventureMonth;
  int? estimatedWeeks;

  void updateFilters({
    List<String>? countries,
    List<String>? industries,
    int? maxPeople,
    String? month,
    int? weeks,
  }) {
    ventureCountries = countries ?? ventureCountries;
    ventureIndustries = industries ?? ventureIndustries;
    maxPeople = maxPeople ?? maxPeople;
    ventureMonth = month ?? ventureMonth;
    estimatedWeeks = weeks ?? estimatedWeeks;

    notifyListeners();
  }
}
