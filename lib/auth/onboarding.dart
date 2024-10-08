import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';
import 'package:jet_palz/constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../components/my_snack_bar.dart';
import '../helpers/is_username_available.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<Onboarding> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late TextEditingController _usernameTextController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false; // Loading state variable

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
            children: [
              const SizedBox(
                height: 24,
              ),
              Image.asset(
                'assets/logo.png',
                width: double.infinity,
                height: 200,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 500,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                        child: PageView(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            const OnboardTextWidget(
                              title: 'Find Your Travel Tribe',
                              description:
                                  'Connect with groups of like-minded travellers to your dream destinations',
                            ),
                            const OnboardTextWidget(
                              title: 'Expand your network',
                              description:
                                  'Network with entrepreneurs, freelancers, and remote professionals from diverse industries whilst having fun',
                            ),
                            const OnboardTextWidget(
                              title: 'Build Lasting Memories',
                              description:
                                  'Learn, grow, and share unforgettable experiences, fulfilling both soul and bank account',
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    const Text(
                                      'We Are Almost There!',
                                      style: TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    const Text(
                                      'Enter your username',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 24.0),
                                    MyTextField(
                                      controller: _usernameTextController,
                                      hintText: "Username",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Username is required';
                                        }
                                        if (value.length < 3) {
                                          return 'Username must be at least 3 characters long';
                                        }
                                        if (value.length > 18) {
                                          return 'Username must be below 18 characters long';
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
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0.0, 0.0, 8.0),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: 4,
                            axisDirection: Axis.horizontal,
                            onDotClicked: (i) async {
                              await _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              setState(() {});
                            },
                            effect: const ExpandingDotsEffect(
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
                padding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 8),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: MyButton(
                    onPressed: _isLoading
                        ? () {}
                        : () async {
                            if (_pageController.page == 3 &&
                                _formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true; // Start loading
                              });

                              final username = _usernameTextController.text;
                              try {
                                final isAvailable =
                                    await isUsernameAvailable(username);

                                if (isAvailable) {
                                  // Username is available, proceed with registration
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({
                                    'username': username,
                                    'photo_url': DefaultPfp,
                                  });
                                  Navigator.pushReplacementNamed(
                                      context, '/feed');
                                } else {
                                  // Username is not available, inform the user
                                  MySnackBar.show(
                                    context,
                                    content: const Text(
                                        'Username is not available. Please choose a different one.'),
                                  );
                                }
                              } catch (e, stackTrace) {
                                // Handle Firestore errors
                                FirebaseCrashlytics.instance
                                    .recordError(e, stackTrace, reason: "onboarding error");
                                MySnackBar.show(
                                  context,
                                  content: const Text(
                                      'An error occurred. Please try again later.'),
                                );
                              }

                              setState(() {
                                _isLoading = false; // Stop loading
                              });
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Next'),
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
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    ));
  }
}
