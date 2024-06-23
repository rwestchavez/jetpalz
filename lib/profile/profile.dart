import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_appBar.dart';
import '../components/my_snack_bar.dart';
import '../components/single_line_widget.dart'; // Make sure to import the new component

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  User? _user;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<String?> _fetchPhotoUrl() async {
    return _userData['photo_url'];
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        setState(() {
          _userData = userDataSnapshot.data() as Map<String, dynamic>;
        });
      } catch (e) {
        MySnackBar.show(context, content: Text("Error $e"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        automaticallyImplyLeading: false,
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
                      FutureBuilder<String?>(
                        future: _fetchPhotoUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.data == null) {
                            return const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.transparent,
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.error,
                                size: 50,
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.network(
                                  snapshot.data!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${_userData['username'] ?? ''}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_userData['profession'] ?? ''}',
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
                        (_userData['description'] != null &&
                                _userData['description'].isNotEmpty)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  Text(
                                    _userData['description'],
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
                            children: (_userData['countries_interest'] !=
                                        null &&
                                    _userData['countries_interest'].isNotEmpty)
                                ? (_userData['countries_interest']
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
                                      'Add countries by editing your profile...',
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
                            children:
                                (_userData['professions_interest'] != null &&
                                        _userData['professions_interest']
                                            .isNotEmpty)
                                    ? (_userData['professions_interest']
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
                                                      .surface
                                                  // Adjust text color as needed
                                                  ),
                                            ),
                                          ),
                                        );
                                      }).toList()
                                    : [
                                        const Text(
                                          'Add professions by editing your profile...',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 44.0,
                    thickness: 1.0,
                    indent: 24.0,
                    endIndent: 24.0,
                    color: Colors.grey,
                  ),
                  SingleLineWidget(
                    icon: Icons.account_circle_outlined,
                    text: 'Edit Profile',
                    onTap: () async {
                      final changesMade =
                          await Navigator.pushNamed(context, '/editProfile');
                      if (changesMade == true) {
                        // Reload user data if changes were made
                        _fetchUserData();
                      }
                    },
                  ),
                  SingleLineWidget(
                    icon: Icons.airplanemode_active,
                    text: 'Venture Requests',
                    onTap: () {
                      Navigator.pushNamed(context, '/myVentures');
                      // Handle My Ventures tap
                    },
                  ),
                  SingleLineWidget(
                    icon: Icons.settings_outlined,
                    text: 'Account Settings',
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                      // Handle Account Settings tap
                    },
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
