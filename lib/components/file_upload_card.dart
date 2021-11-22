import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase/supabase.dart' as supa;
import 'package:provider/provider.dart';
import '../models/eligibility.dart';
import '../common/constants.dart';

class FileUpload extends StatefulWidget {
  FileUpload({Key key}) : super(key: key);

  @override
  _FileUploadState createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  bool _processing = false;

  void _onFileUpload() async {
    setState(() {
      _processing = true;
    });

    final client = supa.SupabaseClient(
        SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

    var pickedFile = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (pickedFile != null) {
      final file = File(pickedFile.files.first.path);

      await client.storage
          .from("resume")
          .upload(pickedFile.files.first.name, file)
          .then((value) {
        setState(() {
          _processing = false;
        });
        if (value.error == null) {
          // Make API call to onbarding to save latest URL from storage
          // print(">>> ${pickedFile.files.first.path}");
          // print(">>> ${pickedFile.files.first.name}");
          print(">>>>>>>>>>>>>>>>>>> ${value.data}");
          final uploadString = value.data;
          OnboardingOperation.updateOnboarding(
              uploadString, 'resume', false, context);
        } else {
          print("Error >>>> ${value.error}");
        }
      });
    }
  }

  Widget _resumeUploadCard() {
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
              title: Text('Upload Resume'),
              subtitle:
                  Text('Your resume is needed by companies that you apply to'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Row(
                    children: [
                      Text('Upload'),
                      SizedBox(
                        width: 2,
                      ),
                      Container(
                          width: 12,
                          height: 12,
                          child: _processing
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                )
                              : Icon(
                                  Icons.upload,
                                  size: 16,
                                ))
                    ],
                  ),
                  onPressed: () {
                    _onFileUpload();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _resumeUploadCard(),
    );
  }
}
