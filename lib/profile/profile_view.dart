import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../components/my_appBar.dart';
import '../components/my_snack_bar.dart';

class ProfileView extends StatefulWidget {
  final String? userId; // Add this to accept another user's ID

  const ProfileView({super.key, this.userId});

  @override
  State<ProfileView> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileView> {
  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserData(widget.userId ?? _currentUser?.uid);
  }

  Future<void> _fetchUserData(String? userId) async {
    if (userId != null) {
      try {
        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDataSnapshot.exists) {
          setState(() {
            _userData = userDataSnapshot.data() as Map<String, dynamic>?;
          });
        }
      } catch (error) {
        // Record the error to Firebase Crashlytics
        FirebaseCrashlytics.instance.recordError(error, StackTrace.current,
            reason: "Error fetching user data for ID: $userId");
        MySnackBar.show(context, content: const Text("Error fetching data"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        automaticallyImplyLeading: true, // Allow back navigation
        title: "Profile",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: _userData != null &&
                                  _userData!['photo_url'] != null
                              ? Image.network(
                                  _userData!['photo_url'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _userData?['username'] ?? 'Loading...',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _userData?['profession'] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (_userData != null &&
                                _userData!['description'] != null &&
                                _userData!['description'].isNotEmpty)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  Text(
                                    _userData!['description'] ?? "",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                                ],
                              )
                            : const Text(""),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Countries I want to visit',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (_userData != null &&
                                    _userData!['countries_interest'] != null &&
                                    _userData!['countries_interest'].isNotEmpty)
                                ? (_userData!['countries_interest']
                                        as List<dynamic>)
                                    .map((country) {
                                    return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 255, 198, 40),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            country.toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface),
                                          ),
                                        ));
                                  }).toList()
                                : [
                                    const Text(
                                      "This user hasn't added any countries",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Professions I am interested in',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (_userData != null &&
                                    _userData!['professions_interest'] !=
                                        null &&
                                    _userData!['professions_interest']
                                        .isNotEmpty)
                                ? (_userData!['professions_interest']
                                        as List<dynamic>)
                                    .map((profession) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255,
                                              71,
                                              200,
                                              255), // Same background color as the Chip
                                          borderRadius: BorderRadius.circular(
                                              20), // Same border radius as the Chip
                                        ),
                                        child: Text(
                                          profession.toString(),
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface // Adjust text color as needed
                                              ),
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Text(
                                      "This user hasn't added any professions",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
