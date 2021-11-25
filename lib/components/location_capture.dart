import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import './location/permission_status.dart';
import './location/service_enabled.dart';
import './location/get_location.dart';

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

      OnboardingOperation.updateOnboarding(long, 'long', true, context);
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // [@NOTE][@INFO]Figure way to use it as service
          // PermissionStatusWidget(),
          // Divider(height: 32),
          // ServiceEnabledWidget(),
          // Divider(height: 32),
          // GetLocationWidget(),
          // Divider(height: 32),

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
          Container(
            child: RoundedButtonWidget(
                buttonText: 'Continue',
                onPressed: () {
                  _requestPermission();
                  _requestService();
                  _getLocation();
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
