import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth_project/login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_auth_project/referral_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:url_launcher/url_launcher.dart';
import './form_builder/ques_journey.dart';
import './../models/eligibility.dart';
import './congrates.dart';
// import 'components/file_upload_card.dart';
import 'components/camera_app_card.dart';
// import './utils/supabase_service.dart';

// Avoid namespace conflict with Providers
import 'package:supabase/supabase.dart' as supa;
import './common/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid;
  String data;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _getTotalJobs() {
    final totalJobs = json.decode(data)['jobs']?.length ?? 0;

    return totalJobs;
  }

  _getJob(int index) {
    final job = json.decode(data)['jobs'][index];

    return job;
  }

  dynamic getJobListing() async {
    String mobile =
        Provider.of<ExamEvaluateModal>(context, listen: false).mobile;

    String companyCode =
        Provider.of<ExamEvaluateModal>(context, listen: false).company_code;

    print("getJobListing >>>>>> $mobile $companyCode");

    final client = supa.SupabaseClient(
        SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

    // final selectResponse = await client.from("jobs").select("*").execute();

    final selectResponse = await client.rpc('get_job_list', params: {
      'company_code_param': companyCode,
      'mobile_number_param': mobile,
    }).execute();

    data = json.encode({});

    if (selectResponse.error == null) {
      print('response.data: ${selectResponse.data}');
      data = json.encode({"jobs": selectResponse.data});

      // print("<><><><><><><><><><><>< $data");
    } else {
      // print('>>>>>>>>>>>>>>>>>>>selectResponse.error: ${selectResponse.error}');
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(selectResponse.error.message)));
    }

    return data;
  }

  Future<void> _setUserLoggedIn() async {
    final SharedPreferences prefs = await _prefs;
    // Use isLoggedIn as a checker around the application
    prefs.setBool("isLoggedIn", false);
  }

  Widget _noJobCard() {
    return Center(
      child: Container(
        child: Text(
          "No Jobs listed, Contact us",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _launchWhatsapp() async {
    const url =
        "https://wa.me/?text=Your friend has referred you for job. Follow the link and use his referral code : %20TADA%20Use company code : %20SMART%20Use this link to apply for job:https://app.pragti.in?rf?=tada&code?=smart";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getJobListing(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return new Scaffold(
                appBar: new AppBar(
                  title: new Text("Jobs"),
                  automaticallyImplyLeading: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        _setUserLoggedIn();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false);
                      },
                    )
                  ],
                ),
                body: Container(
                    child: Column(
                  children: [
                    // Show File upload card
                    // FileUpload(),
                    // Show video upload card
                    CameraAppCard(),
                    // Show jobs card
                    _getTotalJobs() == 0
                        ? Text('')
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _getTotalJobs(), // the length
                            itemBuilder: (context, index) {
                              String title = _getJob(index)['title'];
                              String company_name =
                                  _getJob(index)['company_name'];
                              String location = _getJob(index)['location'];
                              String salary = _getJob(index)['salary'];

                              return Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          // leading: Icon(Icons.arrow_drop_down_circle),
                                          title: Text(
                                            "$title",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.work),
                                                  Text('$company_name'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_city),
                                                  Text('$location'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: SvgPicture.network(
                                            _getJob(index)['icon_uri'],
                                            semanticsLabel: 'A shark?!',
                                            placeholderBuilder: (BuildContext
                                                    context) =>
                                                Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            30.0),
                                                    child:
                                                        const CircularProgressIndicator()),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.money),
                                              Text(
                                                '$salary',
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.6)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ButtonBar(
                                          alignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Test comprises of MCQ and aptitude",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                            ConstrainedBox(
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                      width: 110, height: 40),
                                              child: MaterialButton(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: () {
                                                  // maintain state: job_selected
                                                  Provider.of<ExamEvaluateModal>(
                                                          context,
                                                          listen: false)
                                                      .job_select(
                                                          _getJob(index));

                                                  /// Start counter global
                                                  // initiate CountdownTimer-------
                                                  CountdownController
                                                      countdownController =
                                                      CountdownController(
                                                          duration: Duration(
                                                              // seconds: 10,
                                                              minutes: 10),
                                                          onEnd: () {
                                                            /// open dialog box: with 'continue'
                                                            /// msg: Your time to complete test has expired. Your application has been submitted!
                                                            /// goto congrates page
                                                            print(
                                                                '-----onEnd---- counter---minutes--');

                                                            Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        Congrates(
                                                                            isTimeouted:
                                                                                true)),
                                                                (route) =>
                                                                    false);
                                                          });

                                                  countdownController.start();

                                                  Provider.of<ExamEvaluateModal>(
                                                          context,
                                                          listen: false)
                                                      .countdownController_select(
                                                          countdownController);

                                                  //-----------------------------

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            new QuestionJourney(
                                                                screenIndex:
                                                                    0)),
                                                  );
                                                },
                                                child: Text(
                                                  'Start Test'.toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Image.asset('assets/card-sample-image-2.jpg'),
                                      ],
                                    ),
                                  ));
                            }),

                    kIsWeb
                        ? GestureDetector(
                            onTap: _launchWhatsapp, child: ReferralCard())
                        : null,
                  ],
                )),
              ); // snapshot.data  :- get your object which is pass from your downloadData() function
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
