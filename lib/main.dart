import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jet_palz/auth/forgot_password.dart';
import 'package:jet_palz/auth/onboarding.dart';
import 'package:jet_palz/auth/sign_in.dart';
import 'package:jet_palz/auth/sign_up.dart';
import 'package:jet_palz/chat/chat.dart';
import 'package:jet_palz/chat/notifications_ui.dart';
import 'package:jet_palz/chat/request_provider.dart';
import 'package:jet_palz/firebase_options.dart';
import 'package:jet_palz/profile/change_email.dart';
import 'package:jet_palz/profile/change_password.dart';
import 'package:jet_palz/profile/contact.dart';
import 'package:jet_palz/profile/edit_profile.dart';
import 'package:jet_palz/profile/my_ventures.dart';
import 'package:jet_palz/profile/user_settings.dart';
import 'package:provider/provider.dart';
import 'feed/venture_provider.dart';
import 'chat/chat_provider.dart';
import 'feed/feed.dart';
import 'notifications.dart';
import 'profile/profile.dart';
import 'theme/light_mode_theme.dart';
import 'app_state.dart';
import 'package:badges/badges.dart' as badges;

// Remember to turn off clear text in /Users/richard_alt/Desktop/JetPalz/android/app/src/main/AndroidManifest.xml
const bool emulator = false;

Future<void> _connectEmulator() async {
  final localHostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  FirebaseFirestore.instance.useFirestoreEmulator(localHostString, 8080);
  FirebaseAuth.instance.useAuthEmulator(
    localHostString,
    9099,
  );
  FirebaseStorage.instance.useStorageEmulator(
    localHostString,
    9199,
  );
  FirebaseFunctions.instance.useFunctionsEmulator(localHostString, 5001);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (emulator) {
    await _connectEmulator();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up Crashlytics error handlers
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  User? user = FirebaseAuth.instance.currentUser;

  bool usernameExists = false;
  if (user != null) {
    // Fetch user document from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Check if username field is present and not null
    if (userDoc.exists && userDoc['username'] != null) {
      usernameExists = true;
    }
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => VentureProvider()),
      ChangeNotifierProvider(create: (_) => RequestProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
    ],
    child: MyApp(userExists: user != null, usernameExists: usernameExists),
  ));
}

class MyApp extends StatelessWidget {
  final bool userExists;
  final bool usernameExists;

  const MyApp({
    super.key,
    required this.userExists,
    required this.usernameExists,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: 'JetPalz',
      routes: {
        '/signIn': (context) => const SignIn(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/feed': (context) => const Main(),
        '/onboarding': (context) => const Onboarding(),
        '/editProfile': (context) => const EditProfile(),
        '/myVentures': (context) => const MyVenturesListView(),
        '/settings': (context) => const UserSettings(),
        '/changeEmail': (context) => const ChangeEmail(),
        '/changePassword': (context) => const ChangePassword(),
        '/notifications': (context) => const NotificationsUI(),
        '/contact': (context) => const Contact(),
      },
      home: userExists && usernameExists ? const Main() : const SignUp(),
      theme: lightModeTheme.themeData,
      debugShowCheckedModeBanner: false,
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int _index = 1;
  final List<Widget> screens = [const Chat(), const Feed(), const Profile()];

  @override
  void initState() {
    super.initState();
    handleFCMTokenRefresh();
    RequestProvider().initNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRequests = context.watch<RequestProvider>().requests.isNotEmpty;

    final hasJoins =
        context.watch<RequestProvider>().acceptedRequests.isNotEmpty;

    final hasRejects =
        context.watch<RequestProvider>().rejectedRequests.isNotEmpty;

    final hasNotifications = hasRequests || hasJoins || hasRejects;

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: badges.Badge(
              showBadge: hasNotifications,
              position: badges.BadgePosition.topEnd(top: -5, end: -5),
              badgeContent: Container(),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            label: "Chat",
            selectedIcon: const Icon(Icons.chat_bubble),
          ),
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Feed",
            selectedIcon: Icon(Icons.home),
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
            selectedIcon: Icon(Icons.person),
          )
        ],
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        selectedIndex: _index,
      ),
    );
  }
}
