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
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();


  List<Beacon> defaultBeacons = [
    Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 3,
      accuracy: 0.0,
    ),
    Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 4,
      accuracy: 0.0,
    ),
    Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 8,
      accuracy: 0.0,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Default beacon'ları ekleyerek başla
    _beacons.addAll(defaultBeacons);

    controller.startStream.listen((flag) {
      if (flag == true) {
        initScanBeacon();
      }
    });

    controller.pauseStream.listen((flag) {
      if (flag == true) {
        pauseScanBeacon();
      }
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    if (!controller.authorizationStatusOk ||
        !controller.locationServiceEnabled ||
        !controller.bluetoothEnabled) {
      print(
          'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
              'locationServiceEnabled=${controller.locationServiceEnabled}, '
              'bluetoothEnabled=${controller.bluetoothEnabled}');
      return;
    }

    final regions = <Region>[
      Region(
        identifier: 'ibeacon',
        proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
          print(result);
          if (mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;

              // Güncel bilgilerle _beacons listesini güncelle
              _beacons.forEach((existingBeacon) {
                result.beacons.forEach((newBeacon) {
                  if (existingBeacon.major == newBeacon.major &&
                      existingBeacon.minor == newBeacon.minor) {
                    // Yeni bir Beacon nesnesi oluştur ve eski nesnenin yerine ekle
                    _beacons[_beacons.indexOf(existingBeacon)] = Beacon(
                      proximityUUID: existingBeacon.proximityUUID,
                      major: existingBeacon.major,
                      minor: existingBeacon.minor,
                      accuracy: newBeacon.accuracy,
                      rssi: newBeacon.rssi,
                      // Diğer güncellenecek özellikleri de ekleyebilirsiniz.
                    );
                  }
                });
              });

              _beacons.sort(_compareParameters);
            });
          }
        });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        //_beacons.clear();
      });
    }
  }

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
      body: SafeArea(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: _beacons.map(
                  (beacon) {
                return InkWell(
                 /* onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(minorValue: beacon.minor),
                      ),
                    );
                    print('Tıklanan Beacon: ${beacon.proximityUUID}');
                  },*/
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        beacon.proximityUUID,
                        style: TextStyle(fontSize: 15.0),
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            flex: 1,
                            fit: FlexFit.tight,
                          ),
                          Flexible(
                            child: Text(
                              'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            flex: 2,
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



/*
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../controller/requirement_state_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'chart.dart';

class DetailsPage extends StatefulWidget {
  final int minorValue;
  final int rssiValue;
  final double accuracyValue;
  final String? macAddressValue;
  final int? txPowerValue;

  DetailsPage({required this.minorValue, required this.rssiValue, required this.accuracyValue, this.macAddressValue, this.txPowerValue});

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
}*/