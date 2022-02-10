import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import './form_builder/json_schema.dart';
import './common/date_time_constants.dart';
import './common/constants.dart';
import 'package:supabase/supabase.dart' as supa;

class ScheduleInterview extends StatefulWidget {
  ScheduleInterview({Key key}) : super(key: key);

  @override
  State<ScheduleInterview> createState() => _ScheduleInterviewState();
}

class _ScheduleInterviewState extends State<ScheduleInterview> {
  _createForm(context) {
    String form = json.encode({
      'disclaimer': "By continuing you agree to our Terms and Condition",
      'fields': [
        {
          'name': 'candidateEmail',
          'prefix': '',
          'type': 'TextInput',
          // 'keyboardType': 'number',
          'labelText': "Candidate Email",
          // not work
          "validation": {
            "required": true,
          },
        },
        {
          'name': 'interviewerEmail',
          'prefix': '',
          'type': 'Dropdown',
          'options': getInterviewersOption(),
          // 'keyboardType': 'number',
          'labelText': "Interviewer Email",
          // not work
          "validation": {
            "required": true,
          },
        },
        {
          'name': 'slotDate',
          'type': 'Dropdown',
          'labelText': "Slot Date",
          'options': DateTimeConstants.getDates(),
          "validation": {
            "required": true,
          },
        },
        {
          'name': 'slotTime',
          'type': 'Dropdown',
          'labelText': "Slot Time",
          'options': DateTimeConstants.getTimes(context),
          "validation": {
            "required": true,
          },
        },
      ]
    });

    return form;
  }

  List interviewerAvailable = [];

  dynamic getInterviewerAvailability() async {
    final client = supa.SupabaseClient(
        SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

    final selectResponse = await client
        .from('interviewer_availibilty')
        .select('*')
        .is_('availaiblity', true)
        .execute();

    String data = json.encode({});

    if (selectResponse.error == null) {
      // print('response.data: ${selectResponse.data}');
      interviewerAvailable = selectResponse.data;
      // data = json.encode({"jobs": selectResponse.data});

      // print("<><><><><><><><><><><>< $data");
    } else {
      // print('>>>>>>>>>>>>>>>>>>>selectResponse.error: ${selectResponse.error}');
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(selectResponse.error.message)));
    }

    // return data;
  }

  List getInterviewersOption() {
    List options = [];
    interviewerAvailable.forEach((element) {
      options.add(element['interviewer_email']);
    });
    return options;
  }

  @override
  Widget build(BuildContext context) {
    /// get dates
    print(DateTimeConstants.getDates());

    print(DateTimeConstants.getTimes(context));

    return FutureBuilder(
        future:
            getInterviewerAvailability(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else {
              return Container(
                child: JsonSchema(
                    form: _createForm(context),
                    onSubmitSave: (dynamic response, _formKey) {
                      print('on submit ${_formKey.currentState.fields}');
                    }),
              );
            }
          }
        });

    // return Scaffold(
    //     appBar: AppBar(
    //       title: Text('Schedule Interview'),
    //     ),
    //     body: Container(
    //       child: JsonSchema(
    //           form: _createForm(context),
    //           onSubmitSave: (dynamic response, _formKey) {
    //             print('on submit ${_formKey.currentState.fields}');
    //           }),
    //     ));
  }
}
