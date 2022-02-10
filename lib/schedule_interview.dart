import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import './form_builder/json_schema.dart';
import './common/date_time_constants.dart';

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
          title: Text('Schedule Interview'),
        ),
        body: Container(
          child: JsonSchema(
              form: _createForm(context),
              onSubmitSave: (dynamic response, _formKey) {
                print('on submit ${_formKey.currentState.fields}');
              }),
        ));
  }
}
