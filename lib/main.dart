import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jet_palz/auth/forgot_password.dart';
import 'package:jet_palz/auth/onboarding.dart';
import 'package:jet_palz/auth/sign_in.dart';
import 'package:jet_palz/auth/sign_up.dart';
import 'package:jet_palz/auth/email_sign_up.dart';
import 'package:jet_palz/firebase_options.dart';
import 'package:jet_palz/profile/edit_profile.dart';
import 'package:provider/provider.dart';
import 'ListViewStuff/venture_provider.dart';
import 'nav/chat.dart';
import 'nav/feed.dart';
import 'nav/profile.dart';
import 'theme/dark_mode_theme.dart';
import 'theme/light_mode_theme.dart';
import 'app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => VentureProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors
          .transparent, // Change this to the desired color// Optional: Set this to transparent if you don't want a status bar color
    ));
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'JetPalz', // Add a title for your app
      routes: {
        '/signIn': (context) => SignIn(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/feed': (context) => const Main(),
        '/onboarding': (context) => const Onboarding(),
        '/editProfile': (context) => const EditProfile(),
      },
      home: user != null ? const Main() : const SignUp(),
      theme: lightModeTheme.themeData,
      darkTheme: darkModeTheme.themeData,
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
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
            selectedIcon: Icon(Icons.chat_bubble),
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Feed",
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
            selectedIcon: Icon(Icons.person),
          )
        ],
        onDestinationSelected: (value) {
          setState(
            () {
              _index = value;
            },
          );
        },
        selectedIndex: _index,
      ),
    );
  }
}
