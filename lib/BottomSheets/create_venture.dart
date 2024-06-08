import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class CreateVenture extends StatefulWidget {
  const CreateVenture({Key? key}) : super(key: key);

  @override
  State<CreateVenture> createState() => _CreateVentureWidgetState();
}

class _CreateVentureWidgetState extends State<CreateVenture> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  String? description = "";
  String? country;
  String? industry;
  int? people = 0;
  String? month;
  int? weeks = 0;

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
                      icon: Icon(
                        Icons.close,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Create Venture',
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
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              final userDoc = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser!.uid);

                              final CollectionReference ref = FirebaseFirestore
                                  .instance
                                  .collection('ventures');
                              await ref.add({
                                'country': country,
                                'creator': userDoc,
                                'industry': industry,
                                'description': description,
                                'member_list': [userDoc],
                                'starting_month': month,
                                'estimated_weeks': weeks,
                                'created_time': DateTime.now(),
                                'max_people': people,
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Post',
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
              SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextField(
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
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ), // Set the color of the hint text
                            contentPadding: EdgeInsets.symmetric(
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
                        SizedBox(height: 12),
                        CustomDropdown<String>(
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
                        SizedBox(height: 12),
                        CustomDropdown<String>(
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
                        SizedBox(height: 12),
                        CustomDropdown<String>(
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
                        SizedBox(height: 12),
                        CustomDropdown<String>(
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
                        SizedBox(height: 12),
                        CustomDropdown<String>(
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
                        // Add more text here for description
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
