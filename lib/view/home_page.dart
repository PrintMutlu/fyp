import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fyp_new/view/details_page.dart';

import 'package:get/get.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/requirement_state_controller.dart';
import '../controller/permission.dart';
import 'app_scanning.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final controller = Get.find<RequirementStateController>();
  StreamSubscription<BluetoothState>? _streamBluetooth;
  int currentIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _checkLocationPermission();
    _checkBluetoothPermission();
    super.initState();
    listeningState();
  }


  _checkLocationPermission() async {
    try {
      bool status = await PermissionService.checkLocationPermission();
      if (status) {
        print(Permission.bluetoothScan.status);
      } else {
        print(Permission.bluetoothScan.status);
        bool locationPermissionStatus = await PermissionService.requestLocationPermission(context);
        if (locationPermissionStatus) {
          showBluetoothDialog();
          // await _fetchDataFromDataBase();
        } // SystemNavigator.pop();
      }
    } catch (e) {
      print(e);
    }
  }

  _checkBluetoothPermission() async {
    try {
      bool status = await PermissionService.checkBluetoothPermission();
      if (status) {
        print('Bluetooth Permission: ${Permission.bluetoothScan.status}');
      } else {
        print('Bluetooth Permission: ${Permission.bluetoothScan.status}');
        bool bluetoothPermissionStatus =
        await PermissionService.requestBluetoothPermission(context);
        if (bluetoothPermissionStatus) {
          showBluetoothDialog();
          // await _fetchDataFromDataBase();
        } // SystemNavigator.pop();
      }
    } catch (e) {}
  }


  showLocationDialog() {
    print('location dialog');
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: const Text("UJ Wayfinder Location"),
        content: const Text(
            "App collects location data to enable scanning of beacon around you to enhance your navigation experience even when the app is close or not in use."),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Yes"),
            onPressed: () async {
              Navigator.pop(context);
              await Permission.location.request();
              // showBluetoothDialog();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                  'App collects location data to enable scanning of beacon around you to enhance your navigation experience even when the app is close or not in use.'),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Permission.location.request();
                      Navigator.pop(context);
                    },
                    child: const Text('Allow')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Deny'))
              ],
            );
          });
    }
  }

  showBluetoothDialog() {
    print('bluetooth dialog');
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: const Text("UJ Wayfinder Location"),
        content: const Text(
            'App wants your bluetooth to be turn ON to enable scanning of beacon around you to enhance your navigation experience.'),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Yes"),
            onPressed: () async {
              Navigator.pop(context);
              await Permission.bluetoothScan.request();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    } else {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                  'App wants your bluetooth to be turn ON to enable scanning of beacon around you to enhance your navigation experience.'),
              actions: [
                TextButton(
                    onPressed: () async {
                      OpenSettings.openBluetoothSetting();
                    },
                    child: const Text('Allow')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Deny'))
              ],
            );
          });
    }
  }


  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      controller.updateBluetoothState(state);
      await checkAllRequirements();
    });
  }

  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    controller.updateBluetoothState(bluetoothState);
    print('BLUETOOTH $bluetoothState');

    final authorizationStatus = await flutterBeacon.authorizationStatus;
    controller.updateAuthorizationStatus(authorizationStatus);
    print('AUTHORIZATION $authorizationStatus');

    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;
    controller.updateLocationService(locationServiceEnabled);
    print('LOCATION SERVICE $locationServiceEnabled');


    if (controller.bluetoothEnabled &&
        controller.authorizationStatusOk &&
        controller.locationServiceEnabled) {
      print('STATE READY');
      if (currentIndex == 0) {
        print('SCANNING');
        controller.startScanning();
      } else {
        print('BROADCASTING');
        controller.startBroadcasting();
      }
    } else {
      print('STATE NOT READY');
      controller.pauseScanning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null) {
        if (_streamBluetooth!.isPaused) {
          _streamBluetooth?.resume();
        }
      }
      await checkAllRequirements();
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  @override
  void dispose() {
    _streamBluetooth?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Beacon'),
        centerTitle: false,
        actions: <Widget>[
          Obx(() {
            if (!controller.locationServiceEnabled)
              return IconButton(
                tooltip: 'Not Determined',
                icon: Icon(Icons.portable_wifi_off),
                color: Colors.grey,
                onPressed: () {},
              );

            if (!controller.authorizationStatusOk)
              return IconButton(
                tooltip: 'Not Authorized',
                icon: Icon(Icons.portable_wifi_off),
                color: Colors.red,
                onPressed: () async {
                  await flutterBeacon.requestAuthorization;
                },
              );

            return IconButton(
              tooltip: 'Authorized',
              icon: Icon(Icons.wifi_tethering),
              color: Colors.blue,
              onPressed: () async {
                await flutterBeacon.requestAuthorization;
              },
            );
          }),
          Obx(() {
            return IconButton(
              tooltip: controller.locationServiceEnabled
                  ? 'Location Service ON'
                  : 'Location Service OFF',
              icon: Icon(
                controller.locationServiceEnabled
                    ? Icons.location_on
                    : Icons.location_off,
              ),
              color:
                  controller.locationServiceEnabled ? Colors.blue : Colors.red,
              onPressed: controller.locationServiceEnabled
                  ? () {}
                  : handleOpenLocationSettings,
            );
          }),
          Obx(() {
            final state = controller.bluetoothState.value;

            if (state == BluetoothState.stateOn) {
              return IconButton(
                tooltip: 'Bluetooth ON',
                icon: Icon(Icons.bluetooth_connected),
                onPressed: () {},
                color: Colors.lightBlueAccent,
              );
            }

            if (state == BluetoothState.stateOff) {
              return IconButton(
                tooltip: 'Bluetooth OFF',
                icon: Icon(Icons.bluetooth),
                onPressed: handleOpenBluetooth,
                color: Colors.red,
              );
            }

            return IconButton(
              icon: Icon(Icons.bluetooth_disabled),
              tooltip: 'Bluetooth State Unknown',
              onPressed: () {},
              color: Colors.grey,
            );
          }),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          TabScanning(),
          MapPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (currentIndex == 0) {
            controller.startScanning();
          } else {
            controller.pauseScanning();
            controller.startBroadcasting();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Beacons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_audio),
            label: 'Scan',
          ),
        ],
      ),
    );
  }

  handleOpenLocationSettings() async {
    if (Platform.isAndroid) {
      await flutterBeacon.openLocationSettings;
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location Services Off'),
            content: Text(
              'Please enable Location Services on Settings > Privacy > Location Services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  handleOpenBluetooth() async {
    if (Platform.isAndroid) {
      try {
        await flutterBeacon.openBluetoothSettings;
      } on PlatformException catch (e) {
        print(e);
      }
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bluetooth is Off'),
            content: Text('Please enable Bluetooth on Settings > Bluetooth.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
