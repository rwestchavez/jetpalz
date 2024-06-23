import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_snack_bar.dart';
import '../constants.dart';

class EditVenture extends StatefulWidget {
  final DocumentReference ventureRef;
  final Map<String, dynamic> ventureData;

  const EditVenture({
    required this.ventureRef,
    required this.ventureData,
    Key? key,
  }) : super(key: key);

  @override
  State<EditVenture> createState() => _EditVentureWidgetState();
}

class _EditVentureWidgetState extends State<EditVenture> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  String? description;
  String? country;
  String? industry;
  int? people;
  String? month;
  int? weeks;

  @override
  void initState() {
    super.initState();
    textController.text = widget.ventureData['description'] ?? '';
    description = widget.ventureData['description'];
    country = widget.ventureData['country'];
    industry = widget.ventureData['industry'];
    people = widget.ventureData['max_people'];
    month = widget.ventureData['starting_month'];
    weeks = widget.ventureData['estimated_weeks'];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Edit Venture',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;

                              await widget.ventureRef.update({
                                'description': description,
                                'country': country,
                                'industry': industry,
                                'max_people': people,
                                'starting_month': month,
                                'estimated_weeks': weeks,
                              });

                              MySnackBar.show(context,
                                  content: const Text("Venture Updated"));
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //  SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value != null && value.length > 400) {
                              return 'Description must be less than 400 characters';
                            }
                            return null;
                          },
                          onChanged: (value) => description = value,
                          controller: textController,
                          minLines: 1,
                          maxLines: null,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ), // Light border color
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: "Description",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ), // Set the color of the hint text
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.0),
                              ), // Light border color
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          initialItem: country,
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ), // Light border color
                          ),
                          hintText: 'Country',
                          items: countries,
                          onChanged: (value) {
                            setState(() {
                              country = value;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          initialItem: industry,
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ), // Light border color
                          ),
                          hintText: 'Profession looking for',
                          items: industries,
                          onChanged: (value) {
                            setState(() {
                              industry = value;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          initialItem: people?.toString(),
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ), // Light border color
                          ),
                          hintText: 'Number of people',
                          items: peopleNum,
                          onChanged: (value) {
                            setState(() {
                              people = int.parse(value!);
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          initialItem: month,
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ), // Light border color
                          ),
                          hintText: 'Starting month',
                          items: months,
                          onChanged: (value) {
                            setState(() {
                              month = value;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          initialItem: weeks?.toString(),
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ), // Light border color
                          ),
                          hintText: 'Estimated duration (weeks)',
                          items: weekNum,
                          onChanged: (value) {
                            setState(() {
                              weeks = int.parse(value!);
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Required"
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
