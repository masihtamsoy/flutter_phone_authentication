import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import '../home_list.dart';
import './../widgets/button_widget.dart';
import '../common/constants.dart';

class LocationCapture extends StatefulWidget {
  LocationCapture({Key key}) : super(key: key);

  @override
  State<LocationCapture> createState() => _LocationCaptureState();
}

class _LocationCaptureState extends State<LocationCapture> {
  final Location location = Location();

  var _permissionGranted;
  bool _serviceEnabled;
  bool _loading = false;
  bool _recievedLocation = false;

  LocationData _location;
  String _error;

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
    }
  }

  Future<void> _requestService() async {
    if (_serviceEnabled == true) {
      return;
    }
    final bool serviceRequestedResult = await location.requestService();
    setState(() {
      _serviceEnabled = serviceRequestedResult;
    });
  }

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final LocationData _locationResult = await location.getLocation();

      setState(() {
        _location = _locationResult;
        _loading = false;
      });

      double lat = _locationResult.latitude;
      double long = _locationResult.longitude;

      // INFO: update lat and long to table and goto Home page
      OnboardingOperation.updateOnboarding(lat, 'lat', false, context);

      OnboardingOperation.updateOnboarding(long, 'long', false, context);
    } on PlatformException catch (err) {
      print(err);
      setState(() {
        _error = err.code;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _requestPermission();
    _requestService();
  }

  @override
  Widget build(BuildContext context) {
    /// This gets run 2 times; can be placed somewhere neater
    if (_recievedLocation == false &&
        _permissionGranted == PermissionStatus.granted &&
        _serviceEnabled) {
      _getLocation();
      _recievedLocation = true;
    }
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image.network(
              'https://res.cloudinary.com/dmtuysbcn/image/upload/v1637748317/onboarding/location_map_z7kmbv.jpg',
              // height: 140,
              fit: BoxFit.fill,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
          ),
          Container(
            child: Text(
              "We need location access to show jobs near you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: RoundedButtonWidget(
                buttonText: 'Continue',
                onPressed: () {
                  print(
                      '---build------${_permissionGranted}---------${_serviceEnabled}');

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false);
                }),
          ),
          Text(
            'Location: ' + (_error ?? '${_location ?? "unknown"}'),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
