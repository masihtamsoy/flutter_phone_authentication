/// Currently commented out... cannot get recorded blob file
// import 'dart:html' as html;
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:supabase/supabase.dart' as supa;
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';

// import '../common/constants.dart';
// import './../camera_interview_screen.dart';

// /*
//  * getUserMedia sample
//  */
// class WebCam extends StatefulWidget {
//   static String tag = 'get_usermedia_sample';

//   @override
//   _WebCamState createState() => _WebCamState();
// }

// class _WebCamState extends State<WebCam> {
//   MediaStream _localStream;
//   final _localRenderer = RTCVideoRenderer();
//   bool _inCalling = false;
//   bool _previewReady = false;
//   dynamic _objectUrl = '';
//   MediaRecorder _mediaRecorder;
//   html.Blob _blob;

//   List<MediaDeviceInfo> _cameras;

//   bool get _isRec => _mediaRecorder != null;
//   List<dynamic> cameras;

//   VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     // start with video call
//     _makeCall();

//     initRenderers();

//     navigator.mediaDevices.enumerateDevices().then((md) {
//       setState(() {
//         cameras = md.where((d) => d.kind == 'videoinput').toList();
//       });
//     });

//     _controller = VideoPlayerController.network(
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//   }

//   @override
//   void deactivate() {
//     super.deactivate();
//     if (_inCalling) {
//       _stop();
//     }
//     _localRenderer.dispose();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _controller.dispose();
//   }

//   void initRenderers() async {
//     await _localRenderer.initialize();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   void _makeCall() async {
//     final mediaConstraints = <String, dynamic>{
//       'audio': true,
//       'video': {
//         'mandatory': {
//           'minWidth':
//               '1280', // Provide your own width, height and frame rate here
//           'minHeight': '720',
//           'minFrameRate': '30',
//         },
//       }
//     };

//     try {
//       var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
//       _cameras = await Helper.cameras;
//       _localStream = stream;
//       _localRenderer.srcObject = _localStream;
//     } catch (e) {
//       print(e.toString());
//     }
//     if (!mounted) return;

//     setState(() {
//       _inCalling = true;
//     });
//   }

//   Future<void> _stop() async {
//     try {
//       if (kIsWeb) {
//         _localStream?.getTracks().forEach((track) => track.stop());
//       }
//       await _localStream?.dispose();
//       _localStream = null;
//       _localRenderer.srcObject = null;
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   void _hangUp() async {
//     await _stop();
//     setState(() {
//       _inCalling = false;
//     });
//   }

//   void _startRecording() async {
//     if (_localStream == null) throw Exception('Can\'t record without a stream');
//     _mediaRecorder = MediaRecorder();
//     setState(() {});
//     _mediaRecorder?.startWeb(
//       _localStream,
//       onDataChunk: (blob, isLastOne) {
//         try {
//           setState(() {
//             _blob = blob;
//           });
//         } catch (e) {
//           print('------error----$e');
//         }
//         // print("--------$blob");
//       },
//     );
//   }

//   void _stopRecording() async {
//     // print("${_localStream.getVideoTracks()}");
//     // [Track(id: 0eb892a0-df19-4761-b873-5a12a6bfa5a6, kind: video, label: FaceTime HD Camera, enabled: true, muted: false)]

//     final objectUrl = await _mediaRecorder?.stop();
//     setState(() {
//       _mediaRecorder = null;
//       _previewReady = true;
//       _objectUrl = objectUrl;
//     });
//   }

//   void _openRecordingPreview() {
//     print(_objectUrl);
//     // ignore: unsafe_html
//     html.window.open(_objectUrl, '_blank');
//   }

//   // Widget _vid() {
//   //   return Container(
//   //     child: Center(
//   //         child: _controller.value.isInitialized
//   //             ? AspectRatio(
//   //                 aspectRatio: _controller.value.aspectRatio,
//   //                 child: VideoPlayer(_controller),
//   //               )
//   //             : Container(),
//   //       ),
//   //       // floatingActionButton: FloatingActionButton(
//   //       //   onPressed: () {
//   //       //     setState(() {
//   //       //       _controller.value.isPlaying
//   //       //           ? _controller.pause()
//   //       //           : _controller.play();
//   //       //     });
//   //       //   },
//   //       //   child: Icon(
//   //       //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//   //       //   ),
//   //       // ),
//   //     );}

//   // }

//   Widget _captureFrame() {
//     // if (_localStream == null) throw Exception('Can\'t record without a stream');
//     // final videoTrack = _localStream
//     //     .getVideoTracks()
//     //     .firstWhere((track) => track.kind == 'video');
//     // final frame = await videoTrack.captureFrame();

//     // print("-----frame-------$frame");
//     // html.Blob blob = new html.Blob(await frame.asUint8List());
//     // print("-----blob-------$blob");
//     // print("------videoTrack------ $videoTrack");
//     // print("-------videoTrackStrin------ ${videoTrack.toString()}");
//     final file = File(_objectUrl);

//     return Container(
//         child: Center(
//       child: _controller.value.isInitialized
//           ? AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             )
//           : Container(),
//     ));

//     // _localRenderer.srcObject = _localStream;

//     // f.File file = f.File(videoTrack.toString());

//     //  _localRenderer.renderVideo;

//     // final client = supa.SupabaseClient(
//     //     SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

//     // await client.storage
//     //     .from("interviewvideos")
//     //     .upload(_objectUrl.id, file)
//     //     .then((value) {
//     //   if (value.error == null) {
//     //     print("Value >>>> ${value.data}");
//     //     // final uploadString = value.data;
//     //     // OnboardingOperation.updateOnboarding(
//     //     //     uploadString, 'video', true, context);
//     //   } else {
//     //     print("Error >>>> ${value.error}");
//     //   }
//     // });

//     // await showDialog(
//     //     context: context,
//     //     builder: (context) => AlertDialog(
//     //           content:
//     //               Image.memory(frame.asUint8List(), height: 720, width: 1280),
//     //           actions: <Widget>[
//     //             TextButton(
//     //               onPressed: Navigator.of(context, rootNavigator: true).pop,
//     //               child: Text('OK'),
//     //             )
//     //           ],
//     //         ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Interview'),
//         actions: [
//           _captureFrame()
//           // IconButton(
//           //   icon: Icon(Icons.camera),
//           //   onPressed: _captureFrame,
//           // ),
//         ],
//       ),
//       body: OrientationBuilder(
//         builder: (context, orientation) {
//           return Center(
//             child: Container(
//               margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               decoration: BoxDecoration(color: Colors.black54),
//               child: RTCVideoView(_localRenderer, mirror: true),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: !_previewReady
//           ? FloatingActionButton(
//               onPressed: _isRec ? _stopRecording : _startRecording,
//               tooltip: _isRec ? 'Stop Record' : 'Start Record',
//               child: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
//             )
//           : Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 SizedBox(width: 30),
//                 FloatingActionButton(
//                   onPressed: () {
//                     setState(() {
//                       _previewReady = false;
//                     });
//                   },
//                   tooltip: 'Redo',
//                   child: Icon(Icons.undo),
//                 ),
//                 SizedBox(width: 10),
//                 FloatingActionButton(
//                   onPressed: () {
//                     _openRecordingPreview();
//                   },
//                   tooltip: 'Preview',
//                   child: Icon(Icons.play_arrow),
//                 ),
//                 SizedBox(width: 10),
//                 FloatingActionButton(
//                   onPressed: () async {
//                     print('---------integration not done---');
//                   },
//                   tooltip: 'Done',
//                   child: Icon(Icons.arrow_forward),
//                 )
//               ],
//             ),
//     );
//   }

//   void _switchCamera(String deviceId) async {
//     if (_localStream == null) return;

//     await Helper.switchCamera(
//         _localStream.getVideoTracks()[0], deviceId, _localStream);
//     setState(() {});
//   }
// }
