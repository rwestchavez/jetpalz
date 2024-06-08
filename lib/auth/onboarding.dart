import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<Onboarding> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late TextEditingController _usernameTextController;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _usernameTextController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameTextController.dispose();
    super.dispose();
  }

  Future<bool> _isUsernameAvailable(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (!FocusScope.of(context).hasPrimaryFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Scaffold(
            body: SafeArea(
          child: Column(
            //  mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 24,
              ),
              Image.asset(
                'assets/logo.png',
                width: double.infinity, // Adjust width as needed
                height: 200,
                // fit: BoxFit.contain, // Adjust image fit
              ),
              // LogoWidget
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 500,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                        child: PageView(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            OnboardTextWidget(
                              title: 'Find Your Travel Tribe',
                              description:
                                  'Connect with groups of like-minded travellers to your dream destinations',
                            ),
                            OnboardTextWidget(
                              title: 'Expand your network',
                              description:
                                  'Network with entrepreneurs, freelancers, and remote professionals from diverse industries whilst having fun',
                            ),
                            OnboardTextWidget(
                              title: 'Build Lasting Memories',
                              description:
                                  'Learn, grow, and share unforgettable experiences, fulfilling both soul and bank account',
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Text(
                                        'We Are Almost There!',
                                        style: TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 12.0),
                                      Text(
                                        'Enter your username',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      SizedBox(height: 24.0),
                                      MyTextField(
                                        controller: _usernameTextController,
                                        autofocus: true,
                                        hintText: "Username",
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Username is required';
                                          }
                                          if (value.length < 3) {
                                            return 'Username must be at least 3 characters long';
                                          }
                                          if (!RegExp(r'^[a-zA-Z0-9_]+$')
                                              .hasMatch(value)) {
                                            return 'Username can only contain letters, numbers, and underscores';
                                          }
                                          return null; // Return null if validation passes
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 16.0),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: 4,
                            axisDirection: Axis.horizontal,
                            onDotClicked: (i) async {
                              await _pageController.animateToPage(
                                i,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {});
                            },
                            effect: ExpandingDotsEffect(
                              expansionFactor: 3.0,
                              spacing: 8.0,
                              radius: 16.0,
                              dotWidth: 8.0,
                              dotHeight: 8.0,
                              dotColor: Colors.grey,
                              activeDotColor: Colors.lightBlueAccent,
                              paintStyle: PaintingStyle.fill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 48.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: MyButton(
                    onPressed: () async {
                      if (_pageController.page == 3 &&
                          _formKey.currentState!.validate()) {
                        final username = _usernameTextController.text;
                        final isAvailable =
                            await _isUsernameAvailable(username);

                        if (isAvailable) {
                          // Username is available, proceed with registration
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'display_name': username,
                          });
                          Navigator.pushReplacementNamed(context, '/feed');
                        } else {
                          // Username is not available, inform the user
                          (
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Username is not available. Please choose a different one.'),
                            )),
                          );
                        }
                      } else {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}

class OnboardTextWidget extends StatelessWidget {
  final String title;
  final String description;

  const OnboardTextWidget({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: EdgeInsets.fromLTRB(16, 140.0, 16, 0),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    ));
  }
}
