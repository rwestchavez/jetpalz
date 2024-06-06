import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ListViewStuff/listview_widget.dart';
import '../ListViewStuff/venture_provider.dart';
import '../components/my_appBar.dart';
import '../components/my_button.dart';
import '../constants.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Page2(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor:
                          0.5, // Adjust this factor to control the height
                      child: CreateVenture());
                },
              ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 5,
          child: Icon(
            Icons.airplanemode_active,
            color: Theme.of(context).colorScheme.onSecondary,
            size: 40,
          )),
      appBar: MyAppBar(
        title: "Feed",
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return FractionallySizedBox(
                        heightFactor:
                            0.5, // Adjust this factor to control the height
                        child: Filter());
                  },
                );
              },
              icon: const Icon(Icons.filter_alt_outlined)),
        ],
      ),
    );
  }
}

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
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

class CreateVenture extends StatefulWidget {
  const CreateVenture({Key? key}) : super(key: key);

  @override
  State<CreateVenture> createState() => _CreateVentureWidgetState();
}

class _CreateVentureWidgetState extends State<CreateVenture> {
  final TextEditingController textController = TextEditingController();
  String? description = "";
  String? country = "";
  String? industry = "";
  int? people = 0;
  String? month = "";
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
                          final currentUser = FirebaseAuth.instance.currentUser;
                          final userDoc = FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser!.uid);

                          final CollectionReference ref =
                              FirebaseFirestore.instance.collection('ventures');
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
                              color: Colors
                                  .grey), // Set the color of the hint text
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
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
                            color: Colors.grey
                                .withOpacity(0.3), // Light border color
                          ),
                        ),
                        hintText: 'Country',
                        items: countries,
                        onChanged: (value) {
                          country = value;
                          print('changing value to: $value');
                        },
                      ),
                      SizedBox(height: 12),
                      CustomDropdown<String>(
                        decoration: CustomDropdownDecoration(
                          closedBorder: Border.all(
                            color: Colors.grey
                                .withOpacity(0.3), // Light border color
                          ),
                        ),
                        hintText: 'Industry',
                        items: industries,
                        onChanged: (value) {
                          industry = value;
                          print('changing value to: $value');
                        },
                      ),
                      SizedBox(height: 12),
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
                      SizedBox(height: 12),
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
                      SizedBox(height: 12),
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
                      // Add more text here for description
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => VentureProvider(),
        child: Scaffold(
          body: Consumer<VentureProvider>(
            builder: (context, usersProvider, _) => ListViewWidget(
              usersProvider: usersProvider,
            ),
          ),
        ),
      );
}
