import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:jet_palz/profile/edit_profile.dart';
import 'package:jet_palz/profile/my_ventures.dart';
import 'package:jet_palz/profile/settings.dart';
import 'package:provider/provider.dart';
import 'feed/venture_provider.dart';
import 'chat/chat_provider.dart';
import 'feed/feed.dart';
import 'profile/profile.dart';
import 'theme/light_mode_theme.dart';
import 'app_state.dart';
import 'package:badges/badges.dart' as badges;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up Crashlytics error handlers
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => VentureProvider()),
      ChangeNotifierProvider(create: (_) => RequestProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'JetPalz',
      routes: {
        '/signIn': (context) => const SignIn(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/feed': (context) => const Main(),
        '/onboarding': (context) => const Onboarding(),
        '/editProfile': (context) => const EditProfile(),
        '/myVentures': (context) => const MyVenturesListView(),
        '/settings': (context) => const Settings(),
        '/changeEmail': (context) => const ChangeEmail(),
        '/changePassword': (context) => const ChangePassword(),
        '/notifications': (context) => const NotificationsUI(),
      },
      home: user != null ? const Main() : const SignUp(),
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
