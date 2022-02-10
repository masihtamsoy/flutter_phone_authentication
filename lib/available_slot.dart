import 'dart:convert';

import 'package:flutter/material.dart';
import './common/constants.dart';
import 'package:supabase/supabase.dart' as supa;

class AvailableSlot extends StatefulWidget {
  AvailableSlot({Key key}) : super(key: key);

  @override
  State<AvailableSlot> createState() => _AvailableSlotState();
}

class _AvailableSlotState extends State<AvailableSlot> {
  dynamic getJobListing() async {
    final client = supa.SupabaseClient(
        SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

    final selectResponse =
        await client.from('interviewer_availibilty').select('*').execute();

    String data = json.encode({});

    if (selectResponse.error == null) {
      print('response.data: ${selectResponse.data}');
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
            else {
              return Text('Available Slot');
            }
          }
        });
  }
}
