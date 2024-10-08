import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../components/my_snack_bar.dart';
import '../constants.dart';

class CreateVenture extends StatefulWidget {
  const CreateVenture({super.key});

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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
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
                            onPressed: isLoading
                                ? () {}
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        FirebaseFirestore firestore =
                                            FirebaseFirestore.instance;
                                        final currentUser =
                                            FirebaseAuth.instance.currentUser;
                                        final userDoc = firestore
                                            .collection('users')
                                            .doc(currentUser!.uid);
                                        final venturesRef =
                                            firestore.collection('ventures');

                                        var userSnap = await userDoc.get();
                                        var userData = userSnap.data()
                                            as Map<String, dynamic>;
                                        String creatorName =
                                            userData['username'];

                                        // Check if the user is already a venture creator
                                        QuerySnapshot venturesSnapshot =
                                            await venturesRef
                                                .where('creator',
                                                    isEqualTo: userDoc)
                                                .get();

                                        if (venturesSnapshot.docs.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'You can only be the creator of one venture at a time.',
                                                textAlign: TextAlign.center,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }

                                        await firestore.runTransaction(
                                            (transaction) async {
                                          Map<String, dynamic> ventureData = {
                                            'country': country,
                                            'creator': userDoc,
                                            'creator_name': creatorName,
                                            'industry': industry,
                                            'description': description,
                                            'member_num': 1,
                                            'starting_month': month,
                                            'estimated_weeks': weeks,
                                            'created_time': DateTime.now(),
                                            'max_people': people,
                                            'chat': null,
                                          };

                                          DocumentReference newVentureRef =
                                              venturesRef.doc();
                                          transaction.set(
                                              newVentureRef, ventureData);
                                        });

                                        MySnackBar.show(context,
                                            content:
                                                const Text("Venture Created"));
                                        Navigator.pop(context);
                                      } catch (e, stackTrace) {
                                        FirebaseCrashlytics.instance
                                            .recordError(e, stackTrace,
                                                reason: "create venture error");
                                        MySnackBar.show(context,
                                            content: const Text(
                                                "Error creating venture"));
                                      } finally {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.length > 400) {
                                // Adjust the maximum character limit as needed
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
      ),
    );
  }
}
