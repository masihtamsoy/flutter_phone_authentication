// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
// import 'dart:html' as html;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth_project/camera_interview_screen.dart';
import 'package:video_player/video_player.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:supabase/supabase.dart' as supa;
import '../common/constants.dart';
import '../models/eligibility.dart';
import 'package:provider/provider.dart';

class CameraHomeScreen extends StatefulWidget {
  @override
  _CameraHomeScreenState createState() {
    return _CameraHomeScreenState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    // INFO: back camera is not required
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void logError(String code, String message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _CameraHomeScreenState extends State<CameraHomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController controller;
  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  AnimationController _flashModeControlRowAnimationController;
  Animation<double> _flashModeControlRowAnimation;
  AnimationController _exposureModeControlRowAnimationController;
  Animation<double> _exposureModeControlRowAnimation;
  AnimationController _focusModeControlRowAnimationController;
  Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  bool _processing = false;
  double _baseScale = 1.0;
  bool _showActionAfterRecording = false;
  bool _isRec = false;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();

    /// Start off with openning camera on page load
    onNewCameraSelected(cameras[0]);

    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    controller.dispose();
    videoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          // _captureControlRowWidget(),
          // INFO: does not work 'isCaptureOrientationLcoked called om null'
          // _modeControlRowWidget(),
          // Padding(
          //   // padding: const EdgeInsets.all(5.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       // _cameraTogglesRowWidget(),
          //       // SizedBox(
          //       //   width: 25,
          //       // ),
          //       // _uploadWidget(context),
          //       // _thumbnailWidget(),
          //       // _showActionAfterRecording
          //       //     ? _actionAfterRecordingWidget()
          //       //     : Container(),
          //     ],
          //   ),
          // ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_showActionAfterRecording
          ? FloatingActionButton(
              heroTag: "rec",
              onPressed: () {
                _isRec ? onStopButtonPressed() : onVideoRecordButtonPressed();
              },
              tooltip: _isRec ? 'Stop Record' : 'Start Record',
              child: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 30),
                FloatingActionButton(
                  heroTag: "redo",
                  onPressed: () {
                    setState(() {
                      _showActionAfterRecording = false;
                    });

                    /// Start camera
                    onNewCameraSelected(cameras[0]);
                  },
                  tooltip: 'Redo',
                  child: Icon(Icons.undo),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: "preview",
                  onPressed: () {
                    showAlert(context);
                  },
                  tooltip: 'Preview',
                  child: Icon(Icons.play_arrow),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: "done",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CameraInterviewScreen(mode: "upload")));
                  },
                  tooltip: 'Done',
                  child: Icon(Icons.arrow_forward),
                )
              ],
            ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              // onScaleUpdate: _handleScaleUpdate,
              onTapDown: (details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  Widget _uploadWidget(context) {
    // print("upload widget >>>>>>>>>>>>>>>>> $_processing");
    return ElevatedButton(
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
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.upload,
                      size: 16,
                    ))
        ],
      ),
      onPressed: () {
        if (_processing == false) {
          _onFileUpload(context);
        }
      },
    );
  }

  // void _openRecordingPreview() {
  //   print(videoFile.path);
  //   if (kIsWeb) {
  //     // Does not play on new tab, instead it downloads
  //     html.window.open(videoFile.path, '_blank');
  //   } else {
  //     /// TODO: Make a preview video player for mobile
  //   }
  // }

  void showAlert(BuildContext context) async {
    await _startVideoPlayer();
    final VideoPlayerController localVideoController = videoController;
    showDialog(
      context: context,
      builder: (context) => SizedBox(
        width: 320,
        height: 100,
        child: AlertDialog(
            backgroundColor: Colors.black,
            content: Center(child: _thumbnailWidget())),
      ),
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController localVideoController = videoController;

    return Container(
      child: localVideoController == null && imageFile == null
          ? Container()
          : ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: (localVideoController == null)
                  ? (
                      // The captured image on the web contains a network-accessible URL
                      // pointing to a location within the browser. It may be displayed
                      // either with Image.network or Image.memory after loading the image
                      // bytes to memory.
                      kIsWeb
                          ? Image.network(imageFile.path)
                          : Image.file(File(imageFile.path)))
                  : Container(
                      child: Center(
                        child: AspectRatio(
                            aspectRatio: localVideoController.value.size != null
                                ? localVideoController.value.aspectRatio
                                : 1.0,
                            child: VideoPlayer(localVideoController)),
                      ),
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.pink)),
                    ),
            ),
    );
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flash_on),
              color: Colors.blue,
              onPressed: controller != null ? onFlashModeButtonPressed : null,
            ),
            // The exposure and focus mode are currently not supported on the web.
            ...(!kIsWeb
                ? [
                    IconButton(
                      icon: Icon(Icons.exposure),
                      color: Colors.blue,
                      onPressed: controller != null
                          ? onExposureModeButtonPressed
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_center_focus),
                      color: Colors.blue,
                      onPressed:
                          controller != null ? onFocusModeButtonPressed : null,
                    )
                  ]
                : []),
            IconButton(
              icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
              color: Colors.blue,
              onPressed: controller != null ? onAudioModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
                  ? Icons.screen_lock_rotation
                  : Icons.screen_rotation),
              color: Colors.blue,
              onPressed: controller != null
                  ? onCaptureOrientationLockButtonPressed
                  : null,
            ),
          ],
        ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              icon: Icon(Icons.flash_off),
              color: controller?.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_auto),
              color: controller?.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_on),
              color: controller?.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.highlight),
              color: controller?.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Exposure Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller.setExposurePoint(null);
                        showInSnackBar('Resetting exposure point');
                      }
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                  ),
                  TextButton(
                    child: Text('RESET OFFSET'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => controller.setExposureOffset(0.0)
                        : null,
                  ),
                ],
              ),
              Center(
                child: Text("Exposure Offset"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Focus Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) controller.setFocusPoint(null);
                      showInSnackBar('Resetting focus point');
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController cameraController = controller;
    _isRec = cameraController != null &&
            cameraController.value.isInitialized &&
            cameraController.value.isRecordingVideo
        ? true
        : false;

    print('-----isrecording-----$_isRec');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: Icon(_isRec ? Icons.stop : Icons.videocam),
          onPressed: () {
            _isRec ? onStopButtonPressed() : onVideoRecordButtonPressed();
            // onNewCameraSelected(cameraController.description);
          },
        ),
        // // take pics
        // IconButton(
        //   icon: const Icon(Icons.camera_alt),
        //   color: Colors.blue,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           !cameraController.value.isRecordingVideo
        //       ? onTakePictureButtonPressed
        //       : null,
        // ),
        // IconButton(
        //     onPressed: cameraController != null &&
        //             cameraController.value.isInitialized &&
        //             cameraController.value.isRecordingVideo
        //         ? onStopButtonPressed
        //         : onVideoRecordButtonPressed,
        //     icon: Icon(cameraController != null &&
        //             cameraController.value.isInitialized &&
        //             cameraController.value.isRecordingVideo
        //         ? Icons.stop
        //         : Icons.fiber_manual_record)),
        // IconButton(
        //   icon: const Icon(Icons.videocam),
        //   color: Colors.blue,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           !cameraController.value.isRecordingVideo
        //       ? onVideoRecordButtonPressed
        //       : null,
        // ),
        // IconButton(
        //   icon: cameraController != null &&
        //           cameraController.value.isRecordingPaused
        //       ? Icon(Icons.play_arrow)
        //       : Icon(Icons.pause),
        //   color: Colors.blue,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           cameraController.value.isRecordingVideo
        //       ? (cameraController.value.isRecordingPaused)
        //           ? onResumeButtonPressed
        //           : onPauseButtonPressed
        //       : null,
        // ),
        // IconButton(
        //   icon: const Icon(Icons.stop),
        //   color: Colors.red,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           cameraController.value.isRecordingVideo
        //       ? onStopButtonPressed
        //       : null,
        // ),
        // // Pause camera while recording video
        // IconButton(
        //   icon: const Icon(Icons.pause_presentation),
        //   color:
        //       cameraController != null && cameraController.value.isPreviewPaused
        //           ? Colors.red
        //           : Colors.blue,
        //   onPressed:
        //       cameraController == null ? null : onPausePreviewButtonPressed,
        // ),
      ],
    );
  }

  Widget _cameraRecordWidget() {
    final onChanged = (CameraDescription description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    };
    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      bool _isRec = false;
      _isRec = controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
          ? true
          : false;

      print('----------$controller');
      // CameraDescription description = controller.description;
      return SizedBox(
        width: 90.0,
        child: IconButton(
          icon: Icon(_isRec ? Icons.stop : Icons.videocam),
          onPressed: () {
            // // onNewCameraSelected(controller.description);
            // if (_isRec) {
            //   return null;
            // } else {}
            // print('description------- $description');
            // onNewCameraSelected(description);
          },
        ),
      );
    }
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    final onChanged = (CameraDescription description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
      // onVideoRecordButtonPressed();
    };

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.low : ResolutionPreset.low,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();

      // onVideoRecordButtonPressed();

      /// camera-web causes error on zoom
      // await Future.wait([
      //   // The exposure mode is currently not supported on the web.
      //   ...(!kIsWeb
      //       ? [
      //           cameraController
      //               .getMinExposureOffset()
      //               .then((value) => _minAvailableExposureOffset = value),
      //           cameraController
      //               .getMaxExposureOffset()
      //               .then((value) => _maxAvailableExposureOffset = value)
      //         ]
      //       : []),
      //   cameraController
      //       .getMaxZoomLevel()
      //       .then((value) => _maxAvailableZoom = value),
      //   cameraController
      //       .getMinZoomLevel()
      //       .then((value) => _minAvailableZoom = value),
      // ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) showInSnackBar('Picture saved to ${file.path}');
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller.description);
    }
  }

  void onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted)
        setState(() {
          _isRec = true;
        });
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        setState(() {
          _showActionAfterRecording = true;
          _isRec = false;
        });

        // showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;

        // print("--------file----${file.name}---${file.path}");

        // On stop set videoFileName and videoFilePath
        Provider.of<ExamEvaluateModal>(context, listen: false)
            .video_params(file.name, file.path);

        /// error: Infinity : preview does now works
        // _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) setState(() {});
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    setState(() {
      _showActionAfterRecording = false;
    });

    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.network(videoFile.path)
        : VideoPlayerController.file(File(videoFile.path));

    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vController.addListener(videoPlayerListener);
    await vController.setLooping(false);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile> takePicture() async {
    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _onFileUpload(context) async {
    setState(() {
      _processing = true;
    });

    final client = supa.SupabaseClient(
        SupaConstants.supabaseUrl, SupaConstants.supabaseKey);

    String videoFileName =
        Provider.of<ExamEvaluateModal>(context, listen: false).video_file_name;

    String videoFilePath =
        Provider.of<ExamEvaluateModal>(context, listen: false).video_file_path;

    dynamic file = await File(videoFilePath);

    await client.storage
        .from("interviewvideos")
        .upload(videoFileName, file)
        .then((value) {
      setState(() {
        _processing = true;
      });
      if (value.error == null) {
        print("Value >>>> ${value.data}");
        final uploadString = value.data;
        OnboardingOperation.updateOnboarding(
            uploadString, 'video', true, context);
      } else {
        print("Error >>>> ${value.error}");
      }
    });
  }
}

class CameraApp extends StatefulWidget {
  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>>(
        future: _getCameras(), // function where you call your api
        builder: (BuildContext context,
            AsyncSnapshot<List<CameraDescription>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else {
              return SizedBox.expand(
                child:
                    Container(color: Colors.black, child: CameraHomeScreen()),
              );
            }
          }
        });
  }
}

List<CameraDescription> cameras = [];

Future<List<CameraDescription>> _getCameras() async {
  List<CameraDescription> availCameras = [];
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    availCameras = await availableCameras();
    print("<<<<<<<<<<>>>>>>>>>> $availCameras");
    if (kIsWeb) {
      // Show front camera only
      cameras = [availCameras[0]];
    } else {
      cameras = [availCameras[1]];
    }

    return cameras;
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  // runApp(CameraApp());
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
_ambiguate<T>(value) => value;
