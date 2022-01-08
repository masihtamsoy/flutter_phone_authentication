import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:phone_auth_project/form_builder/onboard_form.dart';

import 'package:phone_auth_project/home_list.dart';
import 'package:phone_auth_project/home.dart';
import 'package:phone_auth_project/login.dart';
import 'package:provider/provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dash_widget/dash_widget.dart';
import 'package:dash_widget/store/jobs_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import './common/theme.dart';
import './models/eligibility.dart';

import './company_code.dart';
// import './models/shared_preferences.dart';
// import './models/user.dart';

// import './form_builder/onboard_form.dart';
// import 'login.dart';
// import 'home_list.dart';

// OnboardingScreen
// import 'congrates.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExamEvaluateModal(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final JobsStore _jobsStore = JobsStore();

  Future<String> userId;

  bool isLoggedIn;

  String mobile;

  Future<void> _userLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = (prefs.getBool('isLoggedIn') == null)
        ? false
        : prefs.getBool('isLoggedIn');

    mobile = prefs.getString("mobile");
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification.body);
        print(message.notification.title);
      }
    });

    // FirebaseMessaging.instance.getToken().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _userLoggedIn(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            print(
                "IsLoggedIn+++ mobile+++++++++++++++++++++++++ $isLoggedIn $mobile");
            Widget firstWidget;

            // Assign widget based on availability of currentUser
            if (isLoggedIn != null && isLoggedIn == true) {
              // INFO: save user mobile to state from shared_pref
              Provider.of<ExamEvaluateModal>(context, listen: false)
                  .set_mobile(mobile);
              firstWidget = CompanyCodeScreen();
            } else {
              firstWidget = LoginScreen();
            }

            return MultiProvider(
              providers: [
                Provider<JobsStore>(create: (_) => _jobsStore),
              ],
              child: Observer(
                  name: 'global-observer',
                  builder: (context) {
                    return MaterialApp(
                      title: 'Dashhire',
                      theme: appTheme,

                      routes: {
                        '/home': (context) => HomeScreen(),
                      },
                      home: AnimatedSplashScreen(
                          duration: 800,
                          splash: Text(
                            "Dashhire",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold),
                          ),
                          nextScreen: firstWidget,
                          splashTransition: SplashTransition.fadeTransition,
                          backgroundColor: Colors.deepPurpleAccent),
                      // home: Congrates(),
                      debugShowCheckedModeBanner: false,
                      builder: EasyLoading.init(),
                    );
                  }),
            );
          }
        });
  }
}
