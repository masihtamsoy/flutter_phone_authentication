import 'package:flutter/material.dart';
import 'package:location/location.dart';

import './location/permission_status.dart';
import './location/service_enabled.dart';
import './location/get_location.dart';

class LocationCapture extends StatelessWidget {
  const LocationCapture({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: const <Widget>[
            PermissionStatusWidget(),
            Divider(height: 32),
            ServiceEnabledWidget(),
            Divider(height: 32),
            GetLocationWidget(),
            Divider(height: 32),
            // ListenLocationWidget(),
            // Divider(height: 32),
            // ChangeSettings(),
            // Divider(height: 32),
            // EnableInBackgroundWidget(),
            // Divider(height: 32),
            // ChangeNotificationWidget()
          ],
        ),
      ),
    );
  }
}
