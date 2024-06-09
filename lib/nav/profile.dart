import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/main.dart';
import '../components/my_appBar.dart';
import '../components/single_line_widget.dart'; // Make sure to import the new component

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

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
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        automaticallyImplyLeading: false,
        title: "My Profile",
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0.0),
          child: SingleChildScrollView(
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
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_userData['display_name'] ?? 'Loading...'}',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_userData['profession'] ?? 'Loading...'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_userData['description'] ?? 'No description provided'}',
                          style: TextStyle(fontSize: 16),
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
                          'Countries I want to visit',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _userData['countries_interest'] != null
                                ? (_userData['countries_interest']
                                        as List<dynamic>)
                                    .map((country) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(
                                          country.toString(),
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        backgroundColor: Colors.orangeAccent,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    Chip(
                                      label: Text(
                                        'No countries provided',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      backgroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _userData['professions_interest'] != null
                                ? (_userData['professions_interest']
                                        as List<dynamic>)
                                    .map((profession) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(
                                          profession.toString(),
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        backgroundColor: Colors.lightBlueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    Chip(
                                      label: Text(
                                        'No professions provided',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      backgroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
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
                SingleLineWidget(
                  icon: Icons.account_circle_outlined,
                  text: 'Edit Profile',
                  onTap: () {
                    // Handle Edit Profile tap
                  },
                ),
                SingleLineWidget(
                  icon: Icons.airplanemode_active,
                  text: 'My Ventures',
                  onTap: () {
                    // Handle My Ventures tap
                  },
                ),
                SingleLineWidget(
                  icon: Icons.settings_outlined,
                  text: 'Account Settings',
                  onTap: () {
                    // Handle Account Settings tap
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
