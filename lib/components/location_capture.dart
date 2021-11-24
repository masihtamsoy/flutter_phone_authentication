import 'package:flutter/material.dart';
import 'package:location/location.dart';

import './location/permission_status.dart';
import './location/service_enabled.dart';
import './location/get_location.dart';

import './../widgets/button_widget.dart';

class LocationCapture extends StatelessWidget {
  const LocationCapture({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
            child:
                RoundedButtonWidget(buttonText: 'Continue', onPressed: () {}),
          ),
          // ListenLocationWidget(),
          // Divider(height: 32),
          // ChangeSettings(),
          // Divider(height: 32),
          // EnableInBackgroundWidget(),
          // Divider(height: 32),
          // ChangeNotificationWidget()
        ],
      ),
    );
  }
}
