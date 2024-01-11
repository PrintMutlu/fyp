import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import '../controller/requirement_state_controller.dart';


import 'chart.dart';

class DetailsPage extends StatefulWidget {
  final int minorValue;

  DetailsPage({required this.minorValue});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();
  final regions = <Region>[];

  late int minorV;

  List<int> rssiValues = [];
  List<int> numbers = List.generate(20, (index) => index + 1);

  @override
  void initState() {
    super.initState();

    minorV = widget.minorValue;
    regions.add(
      Region(
        identifier: 'ibeacon',
        proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
        major: 1,
        minor: minorV,
      ),
    );

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
          print(result);
          if (mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;

              _beacons.clear();
              _beacons.addAll(_regionBeacons.values.expand((element) => element));

              _beacons.sort(_compareParameters);

              if (_beacons.isNotEmpty) {
                rssiValues.add(_beacons.first.rssi);
                if (rssiValues.length > 20) {
                  // Eğer liste 20'den büyükse, ilk elemanları sil
                  rssiValues.removeRange(0, rssiValues.length - 20);
                }
              }
            });
          }
        });
  }

  /*final regions = <Region>[
    Region(
      identifier: 'ibeacon',
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major:1,
      minor: minorV,
    ),
  ];
*/

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon Detayları'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 340,
              height: 420,
              decoration: BoxDecoration(),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('iBeacon',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 20),
                  Text('UUID: 1AA10000-0A46-215F-E97E-5A966A7DEDC3'),
                  const SizedBox(height: 20),
                  Text(
                      'Mac Adresi:  ${_beacons.isNotEmpty ? _beacons.first.macAddress : ''}'),
                  const SizedBox(height: 20),
                  Text('Major: 1'),
                  const SizedBox(height: 20),
                  Text(
                      'Minor: ${_beacons.isNotEmpty ? _beacons.first.minor : ''}'),
                  const SizedBox(height: 20),
                  Text(
                      'Accuracy: ${_beacons.isNotEmpty ? _beacons.first.accuracy.toStringAsFixed(2) + 'm' : ''}'),
                  const SizedBox(height: 20),
                  Text(
                      'Proximity: ${_beacons.isNotEmpty ? _beacons.first.proximity.toString() : ''}'),
                  const SizedBox(height: 20),
                  Text(
                      'TxPower: ${_beacons.isNotEmpty ? _beacons.first.txPower : ''}'),
                  const SizedBox(height: 20),
                  Text(
                      'RSSI: ${_beacons.isNotEmpty ? _beacons.first.rssi.toString() : ''}'),

                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('RSSI Değerleri: ${rssiValues.toString()}'),
            SizedBox(
              height: 20,
            ),

            //List<int> rssiValues = [];
            //List<int> numbers = List.generate(20, (index) => index + 1);

            ElevatedButton(
              onPressed: () {
                // Yeni sayfaya yönlendirme yap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartPage(rssiValues: rssiValues),
                  ),
                );
              },
              child: Text('Grafik'),
            ),

          ],
        ),
      ),
    );
  }
}