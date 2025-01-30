import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged.map((results) => results.first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.data == ConnectivityResult.none) {
          return Text('Offline', style: TextStyle(color: Colors.red));
        } else {
          return Text('Online', style: TextStyle(color: Colors.green));
        }
      },
    );
  }
}
