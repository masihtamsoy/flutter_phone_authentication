import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth_project/home_list.dart';
import 'package:phone_auth_project/widgets/button_widget.dart';
import './widgets/button_widget.dart';
import '../models/eligibility.dart';
import '../common/constants.dart';
import './components/video_full.dart';
import 'package:supabase/supabase.dart' as supa;
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class CameraInterviewScreen extends StatefulWidget {
  final String mode;
  const CameraInterviewScreen({Key key, this.mode = 'start'}) : super(key: key);

  @override
  State<CameraInterviewScreen> createState() => _CameraInterviewScreenState();
}

class _CameraInterviewScreenState extends State<CameraInterviewScreen> {
  void _onFileUpload(context) async {
    final client = supa.SupabaseClient(
        SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

    String videoFileName =
        Provider.of<ExamEvaluateModal>(context, listen: false).video_file_name;

    String videoFilePath =
        Provider.of<ExamEvaluateModal>(context, listen: false).video_file_path;

    print("----file video upload----$videoFilePath $videoFileName");

    var dio = Dio();

    FormData formData = new FormData.fromMap(
      {
        "files.videos": await MultipartFile.fromFile(
          videoFilePath,
          filename: videoFileName,
          // contentType: MediaType(mimeType?[0], mimeType?[1]),
        ),
      },
    );

    Response response = await dio.put(
      'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}',
      data: formData,
      options: Options(),
    );

    // String path = videoFilePath;

    // var request = http.MultipartRequest(
    //   'PUT',
    //   Uri.parse(
    //       'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}'),
    // );

    // var multipartFile = await http.MultipartFile.fromPath(
    //     videoFileName, path); //returns a Future<MultipartFile>
    // request.files.add(multipartFile);
    // http.StreamedResponse response = await request.send();
    // final respStr = await response.stream.bytesToString();
    // var jsonData = jsonDecode(respStr);
    // if (response.statusCode == 200) {
    //   print(response);
    //   // success
    // } else {
    //   print(response);
    //   // error
    // }

    // Response response;
    // Response responsebyte;
    // var dio = Dio();

    // responsebyte = await dio.get(videoFilePath);

    // await dio.put(
    //     'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}', data: );

    // // print(response);

    // var headers = {};
    // var request = http.Request(
    //     'PUT',
    //     Uri.parse(
    //         'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/gorilla.png'));
    // request.body = responsebyte.data;

    // request.headers.addAll(headers);

    // http.StreamedResponse res = await request.send();

    // if (res.statusCode == 200) {
    //   print(await res.stream.bytesToString());
    // } else {
    //   print(res.reasonPhrase);
    // }

    // var file = XFile(videoFilePath).toString();

    // var dio = Dio();

    // var blob = await dio.download(videoFilePath, videoFilePath + '/abc');

    // // var headers = {'Content-Type': 'image/png'};
    // var request = http.Request(
    //     'PUT',
    //     Uri.parse(
    //         'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}'));
    // request.body = file;

    // // request.headers.addAll(headers);

    // http.StreamedResponse response = await request.send();

    // if (response.statusCode == 200) {
    //   print(await response.stream.bytesToString());
    // } else {
    //   print(response.reasonPhrase);
    // }

    // print('File information:');
    // print('- Path: ${file.path}');
    // print('- Name: ${file.name}');
    // print('- MIME type: ${file.mimeType}');

    // Response response;
    // var dio = Dio();

    // String fileName = videoFileName;
    // FormData formData = FormData.fromMap({
    //   "file": await MultipartFile.fromFile(videoFilePath, filename: fileName),
    // });

    // response = await dio.put(
    //     'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}',
    //     data: formData);

    // print(response);

    // dynamic file = await File(videoFilePath);

    // var uri = Uri.parse(
    //     'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}');
    // var response = await http.put(
    //   uri,
    //   // headers: {
    //   //   HttpHeaders.authorizationHeader: 'Basic xxxxxxx', // insert correct credentials here
    //   //   'Content-Type': 'image/jpeg',
    //   // },
    //   body: await file.readAsBytes(),
    // );
    // print(response.statusCode);

    // final myFile = File(videoFilePath).readAsStringSync();

    // print(myFile);

    // // var headers = {'Content-Type': 'image/png'};
    // var request = http.Request(
    //     'PUT',
    //     Uri.parse(
    //         'https://6gfenv2dk7.execute-api.ap-south-1.amazonaws.com/stage/dashhirebucky/${videoFileName}'));
    // request.body = myFile;

    // // request.headers.addAll(headers);

    // http.StreamedResponse response = await request.send();

    // if (response.statusCode == 200) {
    //   print(await response.stream.bytesToString());
    // } else {
    //   print(response.reasonPhrase);
    // }

    // dynamic file = await File(videoFilePath);

    // Future.delayed(Duration(seconds: 10), () {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => CameraInterviewScreen(mode: "done")),
    //       (route) => false);
    // });

    // await client.storage
    //     .from("interviewvideos")
    //     .upload(videoFileName, file)
    //     .then((value) {
    //   if (value.error == null) {
    //     print("Value >>>> ${value.data}");
    //     final uploadString = value.data;
    //     OnboardingOperation.updateOnboarding(
    //         uploadString, 'video', true, context);
    //   } else {
    //     print("Error >>>> ${value.error}");
    //   }
    // });
  }

  Widget _doneInterviewWidget() {
    return Column(
      children: [
        Text(
          'Thanks for using Dashhire video',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        Text(
          'Be in the lookout for our employers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _uploadInterviewWidget() {
    return Column(
      children: [
        Text(
          'Behold, you are ready with video pitch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        Text(
          'press \'upload\' to share your video',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        Text(
          'We are sharing your video pitch to the recruiter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _startInterviewWidget() {
    return Column(
      children: [
        Icon(
          Icons.error_rounded,
          size: 30,
        ),
        Text(
          'Drink some water, clear your throat,',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        Text(
          'and press \'start\' to do your video',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        Text(
          'pitch. Make sure you respond to the',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        Text(
          'instructions above.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.left,
        )
      ],
    );
  }

  void showAlert(BuildContext context) async {
    await _onFileUpload(context);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        // width: 200,
        child: AlertDialog(
          title: Row(
            children: [
              const CircularProgressIndicator(),
              SizedBox(
                width: 20,
              ),
              Text('Stay calm, uploading',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left),
            ],
          ),
          content: Wrap(
            children: [
              Text(
                  'We are sending your pitch to the recruiter. This may take some minutes depending on internet speed')
            ],
          ),
        ),
      ),
    );
  }

  Map _customConfig;

  @override
  void didChangeDependencies() {
    _customConfig = widget.mode == 'start'
        ? {
            'buttonText': 'START',
            'welcomeText': [
              'Introduce yourself',
              'Hi Mate!',
              'Tell us about yourself'
            ],
            'infoWidget': _startInterviewWidget(),
            'goto': () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CameraApp()),
                (route) => false)
          }
        : widget.mode == 'upload'
            ? {
                'buttonText': 'UPLOAD',
                'welcomeText': ['', '', 'Your video is ready'],
                'infoWidget': _uploadInterviewWidget(),
                'goto': () {
                  /// MAKE API call to supabse
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             CameraInterviewScreen(mode: 'done')),
                  //     (route) => false);
                  Future.delayed(Duration.zero, () => showAlert(context));
                }
              }
            : widget.mode == 'done'
                ? {
                    'buttonText': 'DONE',
                    'welcomeText': [
                      '',
                      '',
                      'Your video has been successfully shared with the recruiter'
                    ],
                    'infoWidget': _doneInterviewWidget(),
                    'goto': () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (route) => false)
                  }
                : {};

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // print("----------${_customConfig}");
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                Text('Dashhire', style: TextStyle(fontSize: 50)),
                Text(
                  "${_customConfig['welcomeText'][0]}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Text(
                  "${_customConfig['welcomeText'][1]}",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "${_customConfig['welcomeText'][2]}",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(height: 150, child: _customConfig['infoWidget']),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
          ),
          Container(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.only(left: 80, top: 30),
              child: Row(
                children: [
                  Icon(
                    Icons.laptop_mac_outlined,
                    size: 60,
                  ),
                  Icon(
                    Icons.phone_iphone,
                    size: 60,
                  ),
                  ElevatedButton(
                      child: Text('${_customConfig['buttonText']}',
                          style: TextStyle(fontSize: 15)),
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide(color: Colors.deepPurple)))),
                      onPressed: _customConfig['goto']),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
