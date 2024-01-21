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

  List<int> rssiValues3 = [];
  List<int> rssiValues4 = [];
  List<int> rssiValues8 = [];

  List<int> rssiValues31 = [];
  List<int> rssiValues41 = [];
  List<int> rssiValues81 = [];

/*
  List<Position> beaconsPosition = [
    Position(0, 150),
    Position(-150, -150),
    Position(150, -150),

  ];
  */

  Trilateration trilateration = Trilateration(beaconsPosition: [
    Position(0, 150),
    Position(-150, -150),
    Position(150, -150),
  ]);

  double x1 = 0.58, y1 = 2.05;
  double x2 = -2.2, y2 = -2.3;
  double x3 = 1.8, y3 = -2.1;

  double d1 = 0, d2 = 0, d3 = 0;
  int rssi = 0;
  int txPower = -67;
  int N = 2;
  List<double> dist = [0.0, 0.0, 0.0];

  bool isTabScanningWidgetCreated = false;

  int rssi3 = 0;
  int rssi4 = 0;
  int rssi8 = 0;


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
                rssi3 = _applyMedianFilter(rssiValues31);
                rssi3 = rssi;

                dist[0] = pow(10, ((txPower - rssi) / (10 * 2))) as double;
                //dist[0] = _beacons[i].accuracy;

                rssiValues31.add(rssi);

                if (rssiValues31.length > 7) {
                     rssiValues31.removeAt(0);
                   }

                rssiValues3.add(rssi);
                if (rssiValues3.length > 20) {
                  rssiValues3.removeAt(0);
                }

              } else if (_beacons[i].minor == 4) {
                rssi4 = _applyMedianFilter(rssiValues41);
                rssi4 = rssi;

                dist[1] = pow(10, ((txPower - rssi) / (10 * 2))) as double;
               // dist[1] = _beacons[i].accuracy;

                rssiValues41.add( rssi);
                   if (rssiValues41.length > 7) {
                     rssiValues41.removeAt(0);
                   }

                rssiValues4.add(rssi);
                if (rssiValues4.length > 20) {
                  rssiValues4.removeAt(0);
                }
              } else if (_beacons[i].minor == 8) {
                rssi8 = _applyMedianFilter(rssiValues81);
                rssi8 = rssi;

                dist[2] = pow(10, ((txPower - rssi) / (10 * 2))) as double;
                //dist[2] = _beacons[i].accuracy;

                rssiValues81.add( rssi);
                   if (rssiValues81.length > 7) {
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



            if (-1 > rssi3 && rssi3 > -70 && -55 > rssi4 && rssi4 > -110 && -55 > rssi8 && rssi8 > -110) {

              widget.x = 150;
              widget.y = 75;
              x = 150;
              y = 75;

              if (-1 > rssi3 && rssi3 > -65 && -55 > rssi4 && rssi4 > -95 && -67 > rssi8 && rssi8 > -110) {
                // print("1");

                widget.x = 75;
                widget.y = 75;
                x = 75;
                y = 75;

              } else if (-1 > rssi3 && rssi3 < -70 && -67 > rssi4 && rssi4 > -110 && -55 > rssi8 && rssi8 > -95) {
                // print("2");

                widget.x = 225;
                widget.y = 75;
                x = 225;
                y = 75;

              } else if (-1 > rssi3 && rssi3 > -60 && -60 > rssi4 && rssi4 > -70 && -60 > rssi8 && rssi8 > -70) {

                widget.x = 150;
                widget.y = 75;
                x = 150;
                y = 75;

              }


            } else if (-50 > rssi3 && rssi3 > -95 && -1 > rssi4 && rssi4 > -56 && -1 > rssi8 && rssi8 > -56) {

              widget.x = 150;
              widget.y = 225;
              x = 150;
              y = 225;

              if (-50 > rssi3 && rssi3 > -95 && -1 <= rssi4 && rssi4 > -56 && -56 > rssi8 && rssi8 > -95) {
              // print("2");

              widget.x = 75;
              widget.y = 225;
              x = 75;
              y = 225;

            } else if (-50 > rssi3 && rssi3 > -95 && -56 > rssi4 && rssi4 > -95 && -1 > rssi8 && rssi8 > -56) {
                // print("2");

                widget.x = 225;
                widget.y = 225;
                x = 225;
                y = 225;

              }

            } else if (-57 > rssi3 && rssi3 > -65 && -57 > rssi4 && rssi4 > -65 && -57 > rssi8 && rssi8 > -65) {
              // print("2");

              widget.x = 170;
              widget.y = 150;
              x = 170;
              y = 150;

            } else {
              // print("2");

              widget.x = 150;
              widget.y = 150;
              x = 150;
              y = 150;

            }







            /*

            if (-1 <= rssi3 && rssi3 <= -60 && -75 <= rssi4 && rssi4 <= -80 && -85 < rssi8 && rssi8 < -100) {
              // print("1");

              widget.x = 35;
              widget.y = 35;
              x = 35;
              y = 35;

            } else if (-1 < rssi3 && rssi3 < -48 && -80 <= rssi4 && rssi4 <= -86 && -80 < rssi8 && rssi8 < -86) {
              // print("2");

              widget.x = 105;
              widget.y = 35;
              x = 105;
              y = 35;

            } else if (-47 <= rssi3 && rssi3 < -57 && -85 <= rssi4 && rssi4 <= -100 && -75 < rssi8 && rssi8 < -80) {
              //  print("3 ters");

              widget.x = 190;
              widget.y = 35;
              x = 190;
              y = 35;

            } else if (-52 < rssi3 && rssi3 < -63 && -62 <= rssi4 && rssi4 <= -72 && -79 < rssi8 && rssi8 < -88) {
              //print("5");

              widget.x = 35;
              widget.y = 105;
              x = 35;
              y = 105;

            } else if (-48 < rssi3 && rssi3 < -63 && -68 <= rssi4 && rssi4 <= -75 && -68 < rssi8 && rssi8 < -75) {
              // print("6");

              widget.x = 105;
              widget.y = 105;
              x = 105;
              y = 105;

            } else if (-48 < rssi3 && rssi3 < -63 && -68 <= rssi4 && rssi4 <= -75 && -80 < rssi8 && rssi8 < -92) {
              // print("7 ters");

              widget.x = 190;
              widget.y = 105;
              x = 190;
              y = 105;

            } else if (-63 < rssi3 && rssi3 < -70 && -57 <= rssi4 && rssi4 <= -65 && -63 < rssi8 && rssi8 < -70) {
              //  print("9");

              widget.x = 35;
              widget.y = 190;
              x = 35;
              y = 190;

            } else if (-55 < rssi3 && rssi3 < -60 && -55 <= rssi4 && rssi4 <= -60 && -55 < rssi8 && rssi8 < -60) {
              // print("10");

              widget.x = 105;
              widget.y = 190;
              x = 105;
              y = 190;

            } else if (-53 < rssi3 && rssi3 < -65 && -65 <= rssi4 && rssi4 <= -79 && -45 < rssi8 && rssi8 < -60) {
              //print("11 ters");

              widget.x = 190;
              widget.y = 190;
              x = 190;
              y = 190;

            } else if (-55 < rssi3 && rssi3 < -60 && -1 <= rssi4 && rssi4 <= -48 && -55 < rssi8 && rssi8 < -60) {
              //print("13");

              widget.x = 35;
              widget.y = 260;
              x = 35;
              y = 260;

            } else if (-59 < rssi3 && rssi3 < -67 && -49 <= rssi4 && rssi4 <= -58 && -49 < rssi8 && rssi8 < -58) {
              //print("14");

              widget.x = 105;
              widget.y = 260;
              x = 35;
              y = 260;

            } else if (-55 < rssi3 && rssi3 < -60 && -55 <= rssi4 && rssi4 <= -60 && -1 < rssi8 && rssi8 < -48) {
              //print("15 ters");

              widget.x = 190;
              widget.y = 260;
              x = 190;
              y = 260;
            }
*/
            /*if (0.22 <= d1 &&
                d1 <= 1.18 &&
                0.15 <= d2 &&
                d2 <= 2.6 &&
                2.0 <= d3 &&
                d3 <= 2.82) {
              // print("1");

              widget.x = 35;
              widget.y = 35;
              x = 35;
              y = 35;
            } else if (0.0 <= d1 &&
                d1 < 0.7 &&
                1.58 < d2 &&
                d2 < 2.23 &&
                1.80 < d3 &&
                d3 < 2.5) {
              // print("2");

              widget.x = 105;
              widget.y = 35;
              x = 105;
              y = 35;
            } else if (0.0 <= d1 &&
                d1 < 0.7 &&
                1.35 < d3 &&
                d3 < 2.23 &&
                1.55 < d2 &&
                d2 < 2.53) {
              //  print("3 ters");

              widget.x = 190;
              widget.y = 35;
              x = 190;
              y = 35;
            } else if (0.22 <= d1 &&
                d1 <= 1.18 &&
                0.15 <= d3 &&
                d3 <= 2.6 &&
                2.12 <= d2 &&
                d2 <= 2.82) {
              // print("4 ters");

              widget.x = 260;
              widget.y = 35;
              x = 260;
              y = 35;
            } else if (0.7 <= d1 &&
                d1 <= 1.41 &&
                1.0 <= d2 &&
                d2 <= 1.58 &&
                1.8 <= d3 &&
                d3 <= 2.5) {
              //print("5");

              widget.x = 35;
              widget.y = 105;
              x = 35;
              y = 105;
            } else if (0.5 <= d1 &&
                d1 <= 1.18 &&
                1.18 <= d2 &&
                d2 <= 1.8 &&
                1.41 <= d3 &&
                d3 <= 2.12) {
              // print("6");

              widget.x = 105;
              widget.y = 105;
              x = 105;
              y = 105;
            } else if (0.5 <= d1 &&
                d1 <= 1.18 &&
                1.18 <= d3 &&
                d3 <= 1.8 &&
                1.41 <= d2 &&
                d2 <= 2.12) {
              // print("7 ters");

              widget.x = 190;
              widget.y = 105;
              x = 190;
              y = 105;
            } else if (0.7 <= d1 &&
                d1 <= 1.41 &&
                1.0 <= d3 &&
                d3 <= 1.58 &&
                1.8 <= d2 &&
                d2 <= 2.5) {
              // print("8 ters");

              widget.x = 260;
              widget.y = 105;
              x = 260;
              y = 105;
            } else if (1.18 <= d1 &&
                d1 <= 1.8 &&
                0.5 <= d2 &&
                d2 <= 1.18 &&
                1.58 <= d3 &&
                d3 <= 2.23) {
              //  print("9");

              widget.x = 35;
              widget.y = 190;
              x = 35;
              y = 190;
            } else if (1.0 <= d1 &&
                d1 <= 1.58 &&
                0.7 <= d2 &&
                d2 <= 1.41 &&
                1.18 <= d3 &&
                d3 <= 1.8) {
              // print("10");

              widget.x = 105;
              widget.y = 190;
              x = 105;
              y = 190;
            } else if (1.0 <= d1 &&
                d1 <= 1.58 &&
                0.7 <= d3 &&
                d3 <= 1.41 &&
                1.18 <= d2 &&
                d2 <= 1.8) {
              //print("11 ters");

              widget.x = 190;
              widget.y = 190;
              x = 190;
              y = 190;
            } else if (1.18 <= d1 &&
                d1 <= 1.8 &&
                0.5 <= d3 &&
                d3 <= 1.18 &&
                1.58 <= d2 &&
                d2 <= 2.23) {
              //print("12 ters");

              widget.x = 260;
              widget.y = 190;
              x = 260;
              y = 190;
            } else if (1.58 <= d1 &&
                d1 <= 2.23 &&
                0.0 <= d2 &&
                d2 <= 0.7 &&
                1.5 <= d3 &&
                d3 <= 2.61) {
              //print("13");

              widget.x = 35;
              widget.y = 260;
              x = 35;
              y = 260;
            } else if (1.5 <= d1 &&
                d1 <= 2.61 &&
                0.5 <= d2 &&
                d2 <= 1.18 &&
                1.0 <= d3 &&
                d3 <= 1.58) {
              //print("14");

              widget.x = 105;
              widget.y = 260;
              x = 35;
              y = 260;
            } else if (1.5 <= d1 &&
                d1 <= 2.61 &&
                0.5 <= d3 &&
                d3 <= 1.18 &&
                1.0 <= d2 &&
                d2 <= 1.58) {
              //print("14 ters");

              widget.x = 190;
              widget.y = 260;
              x = 190;
              y = 260;
            } else if (1.58 <= d1 &&
                d1 <= 2.23 &&
                0.0 <= d3 &&
                d3 <= 0.7 &&
                1.5 <= d2 &&
                d2 <= 2.61) {
              //print("13");

              widget.x = 260;
              widget.y = 260;

              x = 260;
              y = 260;
            }*/

            //   5 kök5   1.18
            //   kök5   0.22
            //    kök 425    2.61
            //    15kök2   2.12
            //   5kök2  0.7
            //   kök250   1.58
            //    10kök5   2.23
            //   15'2 20'2   2.5
            //    10'2  15'2   1.80
            //  10 kök2   1.41

            //Position? position = trilateration.calculatePosition(d1,d2,d3);

            //widget.x = position!.x;
            //widget.y = position.y;

            /*
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

                */

            //x = widget.x;
            //y = widget.y;

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
    if (values.isEmpty) {
      return 0;
    }
    int length = values.length;
    if (length % 2 == 0) {
      return (values[length ~/ 2 - 1] + values[length ~/ 2]) ~/ 2;
    } else {
      return values[length ~/ 2];
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
                          Text(
                            '\nd1: ${d1}\nd2: ${d2}\nd3: ${d3}\n\nx: ${x}\ny: ${y}',
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
