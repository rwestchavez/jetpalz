import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_appBar.dart';

class ProfileView extends StatefulWidget {
  final String? userId; // Add this to accept another user's ID

  const ProfileView({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileView> {
  User? _currentUser;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserData(widget.userId ?? _currentUser?.uid);
  }

  Future<String?> _fetchPhotoUrl() async {
    return _userData['photo_url'];
  }

  Future<void> _fetchUserData(String? userId) async {
    if (userId != null) {
      try {
        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        setState(() {
          _userData = userDataSnapshot.data() as Map<String, dynamic>;
        });
      } catch (e) {
        print('Error fetching user data: $e');
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
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0.0),
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
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.lightBlue[200],
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.lightBlue[200],
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
                              backgroundColor: Colors.lightBlue[200],
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
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.lightBlue[200],
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
                            '${_userData['username'] ?? 'Loading...'}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_userData['profession'] ?? 'Loading...'}',
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
                    padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (_userData['description'] != null &&
                                  _userData['description'].isNotEmpty)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 32),
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
                              : Text(""),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Countries I want to visit',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: (_userData['countries_interest'] !=
                                          null &&
                                      _userData['countries_interest']
                                          .isNotEmpty)
                                  ? (_userData['countries_interest']
                                          as List<dynamic>)
                                      .map((country) {
                                      return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
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
                                      Text(
                                        "This user hasn't added any countries",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professions I am interested in',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: (_userData['professions_interest'] !=
                                          null &&
                                      _userData['professions_interest']
                                          .isNotEmpty)
                                  ? (_userData['professions_interest']
                                          as List<dynamic>)
                                      .map((profession) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(255, 71, 200,
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
                                      Text(
                                        "This user hasn't added any professions",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 44.0,
                    thickness: 1.0,
                    indent: 24.0,
                    endIndent: 24.0,
                    color: Colors.grey,
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
