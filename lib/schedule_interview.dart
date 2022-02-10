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
          'name': 'companyName',
          'prefix': '',
          'type': 'TextInput',
          // 'keyboardType': 'number',
          'labelText': "Company Name",
          // not work
          "validation": {
            "required": true,
          },
        },
        {
          'name': 'interview',
          'prefix': '',
          'type': 'Dropdown',
          'options': getInterviewersOption(),
          // 'keyboardType': 'number',
          'labelText': "Interview",
          // not work
          "validation": {
            "required": true,
          },
        },
        // {
        //   'name': 'slotDate',
        //   'type': 'Dropdown',
        //   'labelText': "Slot Date",
        //   'options': DateTimeConstants.getDates(),
        //   "validation": {
        //     "required": true,
        //   },
        // },
        // {
        //   'name': 'slotTime',
        //   'type': 'Dropdown',
        //   'labelText': "Slot Time",
        //   'options': DateTimeConstants.getTimes(context),
        //   "validation": {
        //     "required": true,
        //   },
        // },
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
        .is_('scheduled', false)
        .execute();
    // .is_('availaiblity', true)

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
      String optionStr =
          "${element['interviewer_email']} | ${element['slot_date']} | ${element['slot_time']}";
      options.add(optionStr);
    });
    return options;
  }

  @override
  Widget build(BuildContext context) {
    // /// get dates
    // print(DateTimeConstants.getDates());

    // print(DateTimeConstants.getTimes(context));

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
                    onSubmitSave: (dynamic response, _formKey) async {
                      List val = _formKey.currentState.fields['interview'].value
                          .split(" | ");
                      String email = val[0];
                      String slotDate = val[1];
                      String slotTime = val[2];

                      print(interviewerAvailable);
                      var availabilityId;

                      interviewerAvailable.forEach((element) {
                        if (element['interviewer_email'] == email &&
                            element['slot_date'] == slotDate &&
                            element['slot_time'] == slotTime) {
                          availabilityId = element['id'];
                        }
                      });
                      print("----${availabilityId}");

                      final client = supa.SupabaseClient(
                          SupaConstants.supabaseUrl, SupaConstants.supabaseKey);
                      final updateResponse = await client
                          .from("interviewer_availibilty")
                          .update({'scheduled': true})
                          .eq('id', availabilityId)
                          .execute();

                      // if (updateResponse.error == null) {
                      //   print('response.data: ${updateResponse.data}');
                      //   FocusScope.of(context).unfocus();
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text('Success Added')));
                      // } else {
                      //   // print('>>>>>>>>>>>>>>>>>>>updateResponse.error: ${updateResponse.error}');
                      //   FocusScope.of(context).unfocus();
                      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //       content: Text(updateResponse.error.message)));
                      // }

                      final insertResponse =
                          await client.from("scheduled_interviews").insert({
                        'interviewer_email': email,
                        'candidate_email': _formKey
                            .currentState.fields['candidateEmail'].value,
                        'company_name':
                            _formKey.currentState.fields['companyName'].value,
                        'availability_id': availabilityId,
                        'scheduled': true,
                      }).execute();

                      if (insertResponse.error == null) {
                        setState(() {});
                        print('response.data: ${insertResponse.data}');
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Success Added')));
                      } else {
                        // print('>>>>>>>>>>>>>>>>>>>insertResponse.error: ${insertResponse.error}');
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(insertResponse.error.message)));
                      }
                    }),
              );
            }
          }
        });
  }
}
