// Write in ideas to question journey

// import 'dart:convert';

// Make it a class
// define getter and setter
//
// current active screen: index in screens
// next screen, index : based on form1, form2,... JsonSchema should be able to render form
// previous screen, index in screens
// String screens_journey = json.encode({
//   'journeyTime': '60', // in min
//   'screens': [form1, form2, form3, form4, form5]
// });
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './json_schema.dart';
import '../congrates.dart';

import './../models/eligibility.dart';
import './../utils/supabase_service.dart';

// QuestionJourney extends Journey
// In future there can be other journeys that can be extracted from Journey class
class QuestionJourney extends StatefulWidget {
  QuestionJourney({Key key, this.screenIndex});

  final int screenIndex;

  @override
  _QuestionJourneyState createState() => _QuestionJourneyState();
}

class _QuestionJourneyState extends State<QuestionJourney> {
  String journey;
  dynamic response;

  // // Make a method: params: journey and index
  // // return: JsonSchema(onSubmitSave: implement<Navigation>, form: implement<journey json>)
  String _getFormScreen() {
    final screenIndex = widget.screenIndex;
    // journey is defined

    final form = json.decode(journey)['screens'][screenIndex];

    return json.encode(form);
  }

  int _getScreenCount() {
    final screenCount = json.decode(journey)['screens'].length;

    return screenCount;
  }

  dynamic getJobRelationQuestion() async {
    if (widget.screenIndex == 0) {
      Map job =
          Provider.of<ExamEvaluateModal>(context, listen: false).job_selected;

      // print("??????????????????????????? ${job['id']}");

      int jobId = job["id"];

      SupabaseService supabase = new SupabaseService();
      final selectResponse = await supabase.filter("test", "job_id", jobId);
      journey = json.encode({});

      if (selectResponse.error == null) {
        print('response.data: ${selectResponse.data}');
        journey = json.encode(selectResponse.data[0]["question"]);

        // INFO: Save journey question on first_step then reuse the saved state
        Provider.of<ExamEvaluateModal>(context, listen: false)
            .set_ques_journey(journey);

        // print("<><><><><><><><><><><>< $journey");
      } else {
        // print('>>>>>>>>>>>>>>>>>>>selectResponse.error: ${selectResponse.error}');
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(selectResponse.error.message)));
      }
    } else {
      // INFO: get question journey json from state
      journey =
          Provider.of<ExamEvaluateModal>(context, listen: false).ques_journey;
      // print("<>-------------><><>< $journey");
    }

    return journey;
  }

  @override
  Widget build(BuildContext context) {
    String company_name = Provider.of<ExamEvaluateModal>(context, listen: false)
        .job_selected['company_name'];

    return FutureBuilder(
        future: getJobRelationQuestion(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text("Test"), automaticallyImplyLeading: true),
                  body: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          color: Theme.of(context).secondaryHeaderColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("$company_name"),
                              Text(
                                  "${widget.screenIndex + 1} / ${_getScreenCount()}")
                            ],
                          ),
                        ),
                        JsonSchema(
                            // INFO: response here is context
                            onSubmitSave: (dynamic response, _formKey) {
                              print("response $response");

                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => new Congrates()));

                              // INFO: on question submit update marks attained by user
                              // response.read<ExamEvaluateModal>().assignMark();

                              // INFO: use screenIndex to pull out json object from screens json passed
                              // TODO: This condition should be tight
                              // When screenIndex == _getScreenCount() index error occur

                              if (widget.screenIndex == _getScreenCount() - 1) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new Congrates()));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            new QuestionJourney(
                                                screenIndex:
                                                    widget.screenIndex + 1)));
                              }
                            },
                            form: _getFormScreen()),
                      ]));
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // NOTE: on each screen try getting the result on questions and score (try evaluating answers on submit)
    // ex. say screen 1 have 2 question. On screen calculate the partial score and update _score in Provider

    // journey = json.encode({
    //   'timeLimit': 60,
    //   'screens': [
    //     // 1st screen
    //     {
    //       // define other params in screen
    //       'question': {
    //         'source': "Find the number of A in BBBAAAACCCAADDDDDAeeeeeA",
    //         'type': 'Text',
    //         'pid': '1',
    //       },
    //       // calculate question's answer mark in Widget; update _score
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'answer': '8',
    //           'name': 'q1',
    //           'type': 'Radio',
    //           'labelText': "",
    //           'options': ['7', '8', '6', '5'],
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     // 2nd screen
    //     {
    //       'question': {
    //         'source': "7 * 11 -9 is equal to",
    //         'type': 'Text',
    //         'pid': '2',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'answer': '68',
    //           'name': 'q2',
    //           'type': 'Radio',
    //           'labelText': "",
    //           'options': ['14', '9', '68', '36'],
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             "Pack of 1 box has 10 cigarette, Pack of _____ = 120 cigarette Fill in the blanks with right value",
    //         'type': 'Text',
    //         'pid': '3',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'answer': '12',
    //           'name': 'q3',
    //           'type': 'Radio',
    //           'labelText': "",
    //           'options': ['10', '100', '12', '1.2'],
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             'https://res.cloudinary.com/dmtuysbcn/image/upload/v1635441627/questions/q4_nehbqa.png',
    //         'type': 'Image',
    //         'pid': '4',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'answer': 'faizal',
    //           'name': 'q4',
    //           'type': 'TextInput',
    //           'labelText': "",
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             'https://res.cloudinary.com/dmtuysbcn/image/upload/v1635441627/questions/q5_ogi2xz.png',
    //         'type': 'Image',
    //         'pid': '5',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'name': 'q5',
    //           'answer': '34',
    //           'type': 'TextInput',
    //           'labelText': "",
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             'https://res.cloudinary.com/dmtuysbcn/image/upload/v1635441627/questions/q6_amfqhw.png',
    //         'type': 'Image',
    //         'pid': '6',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'answer': 'zomato',
    //           'name': 'q6',
    //           'type': 'TextInput',
    //           'labelText': "",
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             'Ram has 10 books. Sham gave him 15 books. Ghanshyam also gave him 23 books. How many total books Ram has now?',
    //         'type': 'Text',
    //         'pid': '7',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'answer': '48',
    //           'name': 'q7',
    //           'type': 'TextInput',
    //           //  'labelText': "Job Title",
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         },
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source': 'Ctrl + Z is shortcut for',
    //         'type': 'Text',
    //         'pid': '8',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'name': 'q8',
    //           'answer': 'Undo',
    //           'type': 'Radio',
    //           'labelText': "",
    //           'options': ['Paste', 'New file', 'Delete', 'Undo'],
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             'https://res.cloudinary.com/dmtuysbcn/image/upload/v1635441630/questions/q9_tddqsm.png',
    //         'type': 'Image',
    //         'pid': '9',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'name': 'q9',
    //           'type': 'TextInput',
    //           'labelText': "",
    //           'answer': "knief",
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //     {
    //       'question': {
    //         'source':
    //             '"My name are Rohan and I have two children". What is wrong in this statement?',
    //         'type': 'Text',
    //         'pid': '10',
    //       },
    //       'fields': [
    //         {
    //           'mark': 10,
    //           'name': 'q10',
    //           'type': 'Radio',
    //           'labelText': "",
    //           'answer': "are",
    //           'options': ['My name', 'Children', 'are', 'I have'],
    //           // not work
    //           "validation": {
    //             "required": true,
    //           }
    //         }
    //       ]
    //     },
    //   ]
    // });
  }
}
