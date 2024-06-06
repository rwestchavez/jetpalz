import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class FilterVenture extends StatefulWidget {
  const FilterVenture({super.key});

  @override
  State<FilterVenture> createState() => _FilterVentureState();
}

class _FilterVentureState extends State<FilterVenture> {
  String? description = "";
  String? country = "";
  String? industry = "";
  int? people = 0;

  String? month = "";
  int? weeks = 0;

  @override
  Widget build(BuildContext context) {
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
                // Add logic to close the widget
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
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      hintText: 'Countries',
                      items: countries,
                      onListChanged: (value) {
                        print('changing value to: $value');
                      },
                      listValidator: (value) =>
                          value.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown<String>.multiSelect(
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      hintText: 'Industries',
                      items: industries,
                      onListChanged: (value) {
                        print('changing value to: $value');
                      },
                      listValidator: (value) =>
                          value.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown<String>(
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          color: Colors.grey
                              .withOpacity(0.3), // Light border color
                        ),
                      ),
                      hintText: 'Number of people',
                      items: numbers,
                      onChanged: (value) {
                        people = int.parse(value!);
                        print('changing value to: $value');
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
                      hintText: 'Starting month',
                      items: months,
                      onChanged: (value) {
                        month = value;
                        print('changing value to: $value');
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
                      hintText: 'Estimated weeks',
                      items: numbers,
                      onChanged: (value) {
                        weeks = int.parse(value!);
                        print('changing value to: $value');
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement apply filter logic here
                            },
                            child: const Text("Apply Filter"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement reset filter logic here
                            },
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
