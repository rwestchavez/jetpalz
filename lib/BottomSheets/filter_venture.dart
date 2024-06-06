import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

import '../constants.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import '../constants.dart';
import '../app_state.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import '../constants.dart';
import '../app_state.dart';

class FilterVenture extends StatefulWidget {
  const FilterVenture({super.key});

  @override
  State<FilterVenture> createState() => _FilterVentureState();
}

class _FilterVentureState extends State<FilterVenture> {
  List<String> selectedCountries = [];
  List<String> selectedIndustries = [];
  int? selectedPeople;
  String? selectedMonth;
  int? selectedWeeks;

  final SingleSelectController<String?> peopleController =
      SingleSelectController<String?>(null);
  final SingleSelectController<String?> monthController =
      SingleSelectController<String?>(null);
  final SingleSelectController<String?> weeksController =
      SingleSelectController<String?>(null);

  final MultiSelectController<String> countryController =
      MultiSelectController<String>([]);
  final MultiSelectController<String> industryController =
      MultiSelectController<String>([]);

  void resetFilters() {
    setState(() {
      selectedCountries = [];
      selectedIndustries = [];
      selectedPeople = null;
      selectedMonth = null;
      selectedWeeks = null;

      peopleController.value = null;
      monthController.value = null;
      weeksController.value = null;
      countryController.clear();
      industryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_rounded),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomDropdown<String>.multiSelect(
                      multiSelectController: countryController,
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      hintText: 'Countries',
                      items: countries,
                      onListChanged: (selected) {
                        selectedCountries = selected;
                        print('changing value to: $selected');
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown<String>.multiSelect(
                      multiSelectController: industryController,
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      hintText: 'Industries',
                      items: industries,
                      onListChanged: (selected) {
                        selectedIndustries = selected;
                        print('changing value to: $selected');
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown<String>(
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      controller: peopleController,
                      hintText: 'Number of people',
                      items: numbers,
                      onChanged: (selected) {
                        selectedPeople = int.parse(selected!);
                        print('changing value to: $selected');
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown<String>(
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      controller: monthController,
                      hintText: 'Starting month',
                      items: months,
                      onChanged: (selected) {
                        selectedMonth = selected;
                        print('changing value to: $selected');
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown<String>(
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      controller: weeksController,
                      hintText: 'Estimated weeks',
                      items: numbers,
                      onChanged: (selected) {
                        selectedWeeks = int.parse(selected!);
                        print('changing value to: $selected');
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              appState.updateFilters(
                                countries: selectedCountries,
                                industries: selectedIndustries,
                                maxPeople: selectedPeople,
                                month: selectedMonth,
                                weeks: selectedWeeks,
                              );
                              Navigator.pop(
                                  context); // Close the filter screen after applying
                            },
                            child: const Text("Apply Filter"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: resetFilters,
                            child: const Text("Reset Filter"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
