import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controller/requirement_state_controller.dart';
import '../location/position.dart';
import '../provider/location_provider.dart';

class TabScanning extends StatefulWidget {
  TabScanning({super.key});
  double distanceForMinor3 = 0;
  double distanceForMinor4 = 0;

  double distanceForMinor8 = 0;

  double x = 0, y = 0;
  @override
  _TabScanningState createState() => _TabScanningState();




}

class _TabScanningState extends State<TabScanning> {
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();

  double x = 0, y = 0;


  List<Position> beaconsPosition = [
    Position(0, 150),
    Position(-150, -150),
    Position(150, -150),

  ];

  double x1 = 0, y1 = 149;
  double x2 = -150, y2 = -150;
  double x3 = 150, y3 = -150;

  double accuracy = 0;
  double d1 = 0, d2 = 0, d3 = 0;
  int rssi = 0;
  int txPower = -67;
  int N = 2;
  List<double> dist = [0.0, 0.0, 0.0];

  bool isTabScanningWidgetCreated =false;


  List<Beacon> defaultBeacons = [
    const Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 3,
      accuracy: 0.0,
      macAddress: "",
      txPower: 0,
    ),
    const Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 4,
      accuracy: 0.0,
      macAddress: "",
      txPower: 0,
    ),
    const Beacon(
      proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
      major: 1,
      minor: 8,
      accuracy: 0.0,
      macAddress: "",
      txPower: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _beacons.addAll(defaultBeacons);

    controller.startStream.listen((flag) {
      if (flag == true) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          isTabScanningWidgetCreated = true;
          initScanBeacon();

        },
        );
      }
    });

    controller.pauseStream.listen((flag) {
      if (flag == true) {
        //pauseScanBeacon();
      }
    });

  }

  initScanBeacon() async {
   if (isTabScanningWidgetCreated) {
     await flutterBeacon.initializeScanning;
     if (!controller.authorizationStatusOk ||
         !controller.locationServiceEnabled ||
         !controller.bluetoothEnabled) {
       print(
           'RETURNED, authorizationStatusOk=${controller
               .authorizationStatusOk}, '
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
                       macAddress: newBeacon.macAddress,
                       txPower: newBeacon.txPower,
                     );
                   }
                 });
               });

               _beacons.sort(_compareParameters);


               for (int i = 0; i < _beacons.length; i++) {
                 rssi = _beacons[i].rssi;

                 if (_beacons[i].minor == 3) {
                   dist[0] = pow(10, ((txPower - rssi) / (10 * 2))) as double;
                 } else if (_beacons[i].minor == 4) {
                   dist[1] = pow(10, ((txPower - rssi) / (10 * 2))) as double;
                 } else if (_beacons[i].minor == 8) {
                   dist[2] = pow(10, ((txPower - rssi) / (10 * 2))) as double;
                 }
               }

               d1 = dist[0];
               d2 = dist[1];
               d3 = dist[2];


               double a = (-2 * x1) + (2 * x2);
               double b = (-2 * y1) + (2 * y2);
               num c = pow(d1, 2) -
                   pow(d2, 2) -
                   pow(x1, 2) +
                   pow(x2, 2) -
                   pow(y1, 2) +
                   pow(y2, 2);
               double d = (-2 * x2) + (2 * x3);
               double e = (-2 * y2) + (2 * y3);
               num f = pow(d2, 2) -
                   pow(d3, 2) -
                   pow(x2, 2) +
                   pow(x3, 2) -
                   pow(y2, 2) +
                   pow(y3, 2);

               widget.x = (c * e - f * b);
               widget.x = widget.x / (e * a - b * d);

               widget.y = (c * d - a * f);
               widget.y = widget.y / (b * d - a * e);

               x = widget.x;
               y = widget.y;

               Provider.of<LocationProvider>(context, listen: false).updateLocation(x, y);
             });
           }
         });
   }
  }


  pauseScanBeacon() async {
    //_streamRanging?.pause();
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
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text(
                        'iBeacon',
                        style: TextStyle(fontSize: 22.0),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            beacon.proximityUUID,
                            style: const TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            'Mac Adresi: ${beacon.macAddress}\nMajor: ${beacon.major}\nMinor: ${beacon.minor}'
                            '\nTxPower: ${beacon.txPower}\nAccuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          Text(
                            '\nd1: ${d1}\nd2: ${d2}\nd3: ${d3}\n\nx: ${widget.x}\ny: ${widget.y}',
                            style: const TextStyle(fontSize: 14.0),
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
