import 'dart:convert';

import 'package:flutter_beacon/flutter_beacon.dart';

class Beacon {

  final String proximityUUID;

  final String? macAddress;

  final int major;

  final int minor;

  final int rssi;

  final int? txPower;

  final double accuracy;

  final Proximity? _proximity;

  const Beacon({
    required this.proximityUUID,
    this.macAddress,
    required this.major,
    required this.minor,
    int? rssi,
    this.txPower,
    required this.accuracy,
    Proximity? proximity,
  })  : this.rssi = rssi ?? -1,
        this._proximity = proximity;

  Beacon.fromJson(dynamic json)
      : this(
    proximityUUID: json['proximityUUID'],
    macAddress: json['macAddress'],
    major: json['major'],
    minor: json['minor'],
    rssi: _parseInt(json['rssi']),
    txPower: _parseInt(json['txPower']),
    accuracy: _parseDouble(json['accuracy']),
    proximity: _parseProximity(json['proximity']),
  );

  static double _parseDouble(dynamic data) {
    if (data is num) {
      return data.toDouble();
    } else if (data is String) {
      return double.tryParse(data) ?? 0.0;
    }

    return 0.0;
  }

  static int? _parseInt(dynamic data) {
    if (data is num) {
      return data.toInt();
    } else if (data is String) {
      return int.tryParse(data) ?? 0;
    }

    return null;
  }

  static dynamic _parseProximity(dynamic proximity) {
    if (proximity == 'unknown') {
      return Proximity.unknown;
    }

    if (proximity == 'immediate') {
      return Proximity.immediate;
    }

    if (proximity == 'near') {
      return Proximity.near;
    }

    if (proximity == 'far') {
      return Proximity.far;
    }

    return null;
  }

  /// Parsing array of [Map] into [List] of [Beacon].
  static List<Beacon> beaconFromArray(dynamic beacons) {
    if (beacons is List) {
      return beacons.map((json) {
        return Beacon.fromJson(json);
      }).toList();
    }

    return [];
  }

  /// Parsing [List] of [Beacon] into array of [Map].
  static dynamic beaconArrayToJson(List<Beacon> beacons) {
    return beacons.map((beacon) {
      return beacon.toJson;
    }).toList();
  }

  /// Serialize current instance object into [Map].
  dynamic get toJson {
    final map = <String, dynamic>{
      'proximityUUID': proximityUUID,
      'major': major,
      'minor': minor,
      'rssi': rssi,
      'accuracy': accuracy,
      'proximity': proximity.toString().split('.').last
    };

    if (txPower != null) {
      map['txPower'] = txPower;
    }

    if (macAddress != null) {
      map['macAddress'] = macAddress;
    }

    return map;
  }

  /// Return [Proximity] of beacon.
  ///
  /// iOS will always set proximity by default, but Android is not
  /// so we manage it by filtering the accuracy like bellow :
  /// - `accuracy == 0.0` : [Proximity.unknown]
  /// - `accuracy > 0 && accuracy <= 0.5` : [Proximity.immediate]
  /// - `accuracy > 0.5 && accuracy < 3.0` : [Proximity.near]
  /// - `accuracy > 3.0` : [Proximity.far]
  Proximity get proximity {
    if (_proximity != null) {
      return _proximity!;
    }

    if (accuracy == 0.0) {
      return Proximity.unknown;
    }

    if (accuracy <= 0.5) {
      return Proximity.immediate;
    }

    if (accuracy < 3.0) {
      return Proximity.near;
    }

    return Proximity.far;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Beacon &&
              runtimeType == other.runtimeType &&
              proximityUUID == other.proximityUUID &&
              major == other.major &&
              minor == other.minor &&
              (macAddress != null ? macAddress == other.macAddress : true);

  @override
  int get hashCode {
    int hashCode = proximityUUID.hashCode ^ major.hashCode ^ minor.hashCode;
    if (macAddress != null) {
      hashCode = hashCode ^ macAddress.hashCode;
    }

    return hashCode;
  }

  @override
  String toString() {
    return json.encode(toJson);
  }
}