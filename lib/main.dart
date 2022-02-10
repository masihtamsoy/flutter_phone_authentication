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
import './available_slot.dart';
import './schedule_interview.dart';
import './fill_availability.dart';
// import './models/shared_preferences.dart';
// import './models/user.dart';

// import './form_builder/onboard_form.dart';
// import 'login.dart';
// import 'home_list.dart';

// OnboardingScreen
// import 'congrates.dart';

/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      // 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExamEvaluateModal(),
      child: MyApp(),
    ),
  );

  // await FirebaseMessaging.instance.getToken().then(print);
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

    try {
      // Does not work with emulators
      FirebaseMessaging.instance.getToken().then(print);
    } catch (e) {}

    /// Terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   arguments: MessageArguments(message, true),
        // );
      }
    });

    /// Forground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
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
                        '/available-slots': (context) => AvailableSlot(),
                        '/schedule-interview': (context) => ScheduleInterview(),
                        '/fill-availability': (context) => FillAvailability(),
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
