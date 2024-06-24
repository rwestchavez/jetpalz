import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState._privateConstructor();

  static final AppState _instance = AppState._privateConstructor();

  factory AppState() => _instance;

  String? ventureCountry;
  String? ventureIndustry;
  int? maxPeople;
  String? ventureMonth;
  int? estimatedWeeks;

  void updateFilters({
    String? country,
    String? industry,
    int? people,
    String? month,
    int? weeks,
  }) {
    ventureCountry = country;
    ventureIndustry = industry;
    maxPeople = people;
    ventureMonth = month;
    estimatedWeeks = weeks;

    notifyListeners();
  }
}
