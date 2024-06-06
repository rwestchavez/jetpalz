import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState._privateConstructor();

  // Singleton instance
  static final AppState _instance = AppState._privateConstructor();

  // Getter to access the singleton instance
  factory AppState() => _instance;

  List<String> ventureCountries = [];
  List<String> ventureIndustries = [];
  int? maxPeople;
  String? ventureMonth;
  int? estimatedWeeks;

  void updateFilters({
    required List<String> countries,
    required List<String> industries,
    int? people,
    String? month,
    int? weeks,
  }) {
    ventureCountries = countries;
    ventureIndustries = industries;
    maxPeople = people;
    ventureMonth = month;
    estimatedWeeks = weeks;

    notifyListeners();
  }
}
