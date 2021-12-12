import 'package:flutter/material.dart';
import 'package:phone_auth_project/home_list.dart';
import 'package:phone_auth_project/widgets/button_widget.dart';
import './widgets/button_widget.dart';
import './components/web_cam.dart';

class CameraInterviewScreen extends StatefulWidget {
  final String mode;
  const CameraInterviewScreen({Key key, this.mode = 'start'}) : super(key: key);

  @override
  State<CameraInterviewScreen> createState() => _CameraInterviewScreenState();
}

class _CameraInterviewScreenState extends State<CameraInterviewScreen> {
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

  Map _customConfig;

  @override
  void didChangeDependencies() {
    print("----------${widget.mode}-----");
    _customConfig = widget.mode == 'start'
        ? {
            'buttonText': 'START',
            'welcomeText': ['Hi Mate!', 'Tell us about yourself'],
            'infoWidget': _startInterviewWidget(),
            'goto': () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CameraInterviewScreen(mode: 'upload')))
          }
        : widget.mode == 'upload'
            ? {
                'buttonText': 'UPLOAD',
                'welcomeText': ['', 'Your video is ready'],
                'infoWidget': _uploadInterviewWidget(),
                'goto': () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CameraInterviewScreen(mode: 'done')))
              }
            : widget.mode == 'done'
                ? {
                    'buttonText': 'DONE',
                    'welcomeText': [
                      '',
                      'Your video has been successfully shared with the recruiter'
                    ],
                    'infoWidget': _doneInterviewWidget(),
                    'goto': () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()))
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
                  'Introduce yourself',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Text(
                  "${_customConfig['welcomeText'][0]}",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "${_customConfig['welcomeText'][1]}",
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
                    Icons.phone_android_sharp,
                    size: 60,
                  ),
                  Icon(
                    Icons.phonelink_erase,
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
