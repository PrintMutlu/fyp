import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fyp_new/view/details_page.dart';
import 'package:get/get.dart';

import '../controller/requirement_state_controller.dart';

class TabScanning extends StatefulWidget {
  @override
  _TabScanningState createState() => _TabScanningState();
}

class _TabScanningState extends State<TabScanning> {

  final _beacons = <Beacon>[];

  List<int> minorV = [3,4,8];

  List<Beacon> defaultBeacons = [
    const Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 3,
      accuracy: 0.0,
    ),
    const Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 4,
      accuracy: 0.0,
    ),
    const Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 8,
      accuracy: 0.0,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _beacons.addAll(defaultBeacons);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: _beacons.map(
                  (beacon) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(minorValue: beacon.minor),
                      ),
                    );
                    print('Tıklanan Beacon: ${beacon.proximityUUID}');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        'iBeacon',
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                            flex: 1,
                            fit: FlexFit.tight,
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

}
