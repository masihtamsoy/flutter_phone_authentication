import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import './form_builder/json_schema.dart';
import './common/date_time_constants.dart';
import './common/constants.dart';
import 'package:supabase/supabase.dart' as supa;

class FillAvailability extends StatefulWidget {
  FillAvailability({Key key}) : super(key: key);

  @override
  State<FillAvailability> createState() => _FillAvailabilityState();
}

class _FillAvailabilityState extends State<FillAvailability> {
  _createForm(context) {
    String form = json.encode({
      'disclaimer': "By continuing you agree to our Terms and Condition",
      'fields': [
        {
          'name': 'interviewerEmail',
          'prefix': '',
          'type': 'TextInput',
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

  @override
  Widget build(BuildContext context) {
    /// get dates
    print(DateTimeConstants.getDates());

    print(DateTimeConstants.getTimes(context));

    return Scaffold(
        appBar: AppBar(
          title: Text('Interviewer Fill Availability'),
        ),
        body: Container(
          child: JsonSchema(
              form: _createForm(context),
              onSubmitSave: (dynamic response, _formKey) async {
                String interviewerEmail =
                    _formKey.currentState.fields['interviewerEmail'].value;
                print('on submit ${interviewerEmail}');

                String slotDate =
                    _formKey.currentState.fields['slotDate'].value;
                print('on submit ${slotDate}');

                String slotTime =
                    _formKey.currentState.fields['slotTime'].value;
                print('on submit ${slotTime}');

                final client = supa.SupabaseClient(
                    SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

                final updateResponse =
                    await client.from("interviewer_availibilty").insert({
                  'interviewer_email': interviewerEmail,
                  'availaiblity': true,
                  'scheduled': true,
                  'slot_date': slotDate,
                  'slot_time': slotTime
                }).execute();

                /// String formats allowed for date and time
                //  'slot_date': '2022-03-01',
                //   'slot_time': '18:20:00'

                String data = json.encode({});

                if (updateResponse.error == null) {
                  print('response.data: ${updateResponse.data}');
                  // data = json.encode({"jobs": updateResponse.data});

                  // print("<><><><><><><><><><><>< $data");
                } else {
                  // print('>>>>>>>>>>>>>>>>>>>updateResponse.error: ${updateResponse.error}');
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(updateResponse.error.message)));
                }
              }),
        ));
  }
}
