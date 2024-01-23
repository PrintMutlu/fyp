import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fyp_new/location/trilateration.dart';
import 'package:fyp_new/view/chart.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controller/requirement_state_controller.dart';
import '../location/kalman_filter.dart';
import '../location/position.dart';
import '../provider/location_provider.dart';

class TabScanning extends StatefulWidget {
  TabScanning({super.key});

  double x = 0, y = 0;

  @override
  _TabScanningState createState() => _TabScanningState();
}

class _TabScanningState extends State<TabScanning> {
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();

  KalmanFilter kalmanFilter = KalmanFilter();
  double x = 0, y = 0;

  List<int> rssiValues3 = []; List<int> rssiValues4 = []; List<int> rssiValues8 = [];

  List<int> rssiValues31 = []; List<int> rssiValues41 = []; List<int> rssiValues81 = [];

  Trilateration trilateration = Trilateration(beaconsPosition: [
    Position(0, 150),
    Position(-150, -150),
    Position(150, -150),
  ]);

  double x1 = 0.58, y1 = 2.05; double x2 = -2.2, y2 = -2.3; double x3 = 1.8, y3 = -2.1;

  double d1 = 0, d2 = 0, d3 = 0;
  int rssi = 0;
  int txPower = -67;
  int N = 2;
  List<double> dist = [0.0, 0.0, 0.0];

  bool isTabScanningWidgetCreated = false;

  int rssi3 = 0; int rssi4 = 0; int rssi8 = 0;


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
        WidgetsBinding.instance?.addPostFrameCallback(
          (_) {
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
            _beacons.forEach((existingBeacon) {
              result.beacons.forEach((newBeacon) {
                if (existingBeacon.major == newBeacon.major &&
                    existingBeacon.minor == newBeacon.minor) {
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

            /* Apply median filter to RSSI values
               rssiValues31 = _applyMedianFilter(_beacons
                   .where((beacon) => beacon.minor == 3)
                   .map((beacon) => beacon.rssi)
                   .toList());

               rssiValues41 = _applyMedianFilter(_beacons
                   .where((beacon) => beacon.minor == 4)
                   .map((beacon) => beacon.rssi)
                   .toList());

               rssiValues81 = _applyMedianFilter(_beacons
                   .where((beacon) => beacon.minor == 8)
                   .map((beacon) => beacon.rssi)
                   .toList());
*/

            for (int i = 0; i < _beacons.length; i++) {
              rssi = _beacons[i].rssi;

              if (_beacons[i].minor == 3) {
                //rssi3 = _applyMedianFilter(rssiValues31);
                //rssi3 = rssi;

                //dist[0] = pow(10, ((txPower - rssi3) / (10 * 1))) as double;

                dist[0] = _beacons[i].accuracy;

                rssiValues31.add(rssi);

                if (rssiValues31.length > 5) {
                     rssiValues31.removeAt(0);
                   }

                rssiValues3.add(rssi);
                if (rssiValues3.length > 20) {
                  rssiValues3.removeAt(0);
                }

              } else if (_beacons[i].minor == 4) {
                //rssi4 = _applyMedianFilter(rssiValues41);
                //rssi4 = rssi;

                //dist[1] = pow(10, ((txPower - rssi4) / (10 * 2))) as double;

                dist[1] = _beacons[i].accuracy;

                rssiValues41.add( rssi);
                   if (rssiValues41.length > 5) {
                     rssiValues41.removeAt(0);
                   }

                rssiValues4.add(rssi);
                if (rssiValues4.length > 20) {
                  rssiValues4.removeAt(0);
                }
              } else if (_beacons[i].minor == 8) {
                //rssi8 = _applyMedianFilter(rssiValues81);
                //rssi8 = rssi;

                //dist[2] = pow(10, ((txPower - rssi8) / (10 * 2))) as double;

                dist[2] = _beacons[i].accuracy;

                rssiValues81.add( rssi);
                   if (rssiValues81.length > 5) {
                     rssiValues81.removeAt(0);
                   }

                rssiValues8.add(rssi);
                if (rssiValues8.length > 20) {
                  rssiValues8.removeAt(0);
                }
              }
            }

            d1 = dist[0];
            d2 = dist[1];
            d3 = dist[2];


            if (0.0 <= d1 && d1 < 0.5 && 0.55 < d2 && 0.55 < d3) {

              widget.x = 150;
              widget.y = 100;
              x = 150;
              y = 100;

              if (0.0 <= d1 && d1 < 0.35) {
                widget.x = 150;
                widget.y = 60;
                x = 150;
                y = 60;

                if (0.0 <= d1 && d1 < 0.25) {
                  widget.x = 150;
                  widget.y = 42;
                  x = 150;
                  y = 42;

                  if (0.0 <= d1 && d1 < 0.15) {
                    widget.x = 150;
                    widget.y = 32;
                    x = 150;
                    y = 32;

                    if (0.0 <= d1 && d1 < 0.06) {
                      widget.x = 150;
                      widget.y = 25;
                      x = 150;
                      y = 25;
                    }
                  }
                }
              }

            } else if (0.55 < d1 && 0.0 <= d2 && d2 < 0.5 && 0.55 < d3) {

              widget.x = 90;
              widget.y = 200;
              x = 90;
              y = 200;

              if (0.0 <= d2 && d2 < 0.35) {

                widget.x = 52;
                widget.y = 230;
                x = 52;
                y = 230;

                if (0.0 <= d2 && d2 < 0.25) {

                  widget.x = 43;
                  widget.y = 248;
                  x = 43;
                  y = 248;

                  if (0.0 <= d2 && d2 < 0.15) {

                    widget.x = 35;
                    widget.y = 263;
                    x = 35;
                    y = 263;

                    if (0.0 <= d2 && d2 < 0.06) {

                      widget.x = 20;
                      widget.y = 278;
                      x = 20;
                      y = 278;

                    }
                  }
                }
              }

            } else if (0.55 < d1 && 0.55 < d2 && 0.0 <= d3 && d3 < 0.5) {

              widget.x = 200;
              widget.y = 200;
              x = 200;
              y = 200;

              if (0.0 <= d3 && d3 < 0.35) {

                widget.x = 235;
                widget.y = 235;
                x = 235;
                y = 235;

                if (0.0 <= d3 && d3 < 0.25) {

                  widget.x = 248;
                  widget.y = 248;
                  x = 248;
                  y = 248;

                  if (0.0 <= d3 && d3 < 0.15) {

                    widget.x = 265;
                    widget.y = 265;
                    x = 265;
                    y = 265;

                    if (0.0 <= d3 && d3 < 0.06) {

                      widget.x = 270;
                      widget.y = 272;
                      x = 270;
                      y = 270;

                    }
                  }
                }
              }

            } else {

              widget.x = 150;
              widget.y = 150;
              x = 150;
              y = 150;

            }


            //Position? position = trilateration.calculatePosition(d1,d2,d3);

            //widget.x = position!.x;
            //widget.y = position.y;



            /*Position measurement = Position(x, y);
               Position kalmanFilteredPosition = kalmanFilter.update(measurement);

               widget.x = kalmanFilteredPosition.x;
               widget.y = kalmanFilteredPosition.y;

               x = widget.x;
               y = widget.y;
*/

            Provider.of<LocationProvider>(context, listen: false)
                .updateLocation(x, y);
          });
        }
      });
    }
  }

  int _applyMedianFilter(List<int> values) {
    values.sort();
    int length = values.length;

    if (values.isEmpty) {
      return 0;
    } else if (length == 5) {
      return values[2];
    } else {
      return values[length-1];
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
                  onTap: () {
                    if (beacon.minor == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChartPage(rssiValues: rssiValues3),
                        ),
                      );
                    } else if (beacon.minor == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChartPage(rssiValues: rssiValues4),
                        ),
                      );
                    } else if (beacon.minor == 8) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChartPage(rssiValues: rssiValues8),
                        ),
                      );
                    }
                  },
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
                          /*Text(
                            '\nd1: ${d1}\nd2: ${d2}\nd3: ${d3}\n\nx: ${x}\ny: ${y}',
                            style: const TextStyle(fontSize: 14.0),
                          ),*/
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
