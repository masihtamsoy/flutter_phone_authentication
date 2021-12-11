import 'package:flutter/material.dart';
import './widgets/button_widget.dart';
import './components/web_cam.dart';

class CameraInterviewScreen extends StatefulWidget {
  CameraInterviewScreen({Key key}) : super(key: key);

  @override
  _CameraInterviewScreenState createState() => _CameraInterviewScreenState();
}

class _CameraInterviewScreenState extends State<CameraInterviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Center(child: Text("Introduce yourself")),
          ),
          Expanded(
              flex: 3,
              child: Column(
                children: [Text("Hi Tanmay,"), Text(" Tell us about yourself")],
              )),
          Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text("Drink some water, clear your throat,"),
                  Text("and press 'start' to do your video pitch"),
                  Text("Make sure you follow instruction"),
                  RoundedButtonWidget(
                      buttonText: 'START',
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => WebCam()));
                      })
                ],
              ))
        ],
      ),
    );
  }
}
