/*import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
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



  @override
  void initState() {
    super.initState();

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
              _beacons.clear();
              _regionBeacons.values.forEach((list) {
                _beacons.addAll(list);
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
        _beacons.clear();
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
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _beacons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: _beacons.map(
                (beacon) {
              return ListTile(
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
                    )
                  ],
                ),
              );
            },
          ),
        ).toList(),
      ),
    );
  }

}
















// details_page.dart




class DetailsPage extends StatefulWidget {
  final Beacon beacon;
  final int minorValue;
  DetailsPage({required this.beacon, required this.minorValue});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Beacon _currentBeacon;


  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();



  @override
  void initState() {
    super.initState();

    List<Beacon> defaultBeacons = [
      Beacon(
        proximityUUID: '1AA10000-0A46-215F-E97E-5A966A7DEDC3',
        major: 1,
        minor: widget.minorValue,
        accuracy: 0.0,
      ),
    ];

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
      appBar: AppBar(
        title: Text('Beacon Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 340,
              height: 320,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1.0,
                    blurRadius: 5.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text('iBeacon', style: TextStyle(color: Colors.white, fontSize: 20))
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('${_currentBeacon.proximityUUID}')
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('Major: ${_currentBeacon.major}'),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('Minor: ${_currentBeacon.minor}'),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('Accuracy: ${_currentBeacon.accuracy}m'),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('RSSI: ${_currentBeacon.rssi}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
