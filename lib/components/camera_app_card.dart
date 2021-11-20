import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase/supabase.dart' as supa;
import '../common/constants.dart';
import './video_full.dart';

class CameraAppCard extends StatefulWidget {
  CameraAppCard({Key key}) : super(key: key);

  @override
  _CameraAppCardState createState() => _CameraAppCardState();
}

class _CameraAppCardState extends State<CameraAppCard> {
  Widget _interviewVideoUploadCard() {
    return Container(
        padding: const EdgeInsets.only(bottom: 8),
        // width: double.infinity,
        // height: 100,
        child: Card(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.album),
              title: Text('Upload Interview video'),
              subtitle: Text('You can showcase your skills using video'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('Upload'),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CameraApp()));
                  },
                ),
                const SizedBox(width: 8),
                // TextButton(
                //   child: const Text('See Current'),
                //   onPressed: () {/* ... */},
                // ),
                // const SizedBox(width: 8),
              ],
            ),
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _interviewVideoUploadCard(),
    );
  }
}
