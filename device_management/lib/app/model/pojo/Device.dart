import 'package:flutter/material.dart';

class Device {
  String nameDevice;
  String serialName;
  String osVersion;
  String person;
  String dateTime;
  Color color;

  Device(this.nameDevice, this.serialName, this.osVersion, this.person,
      this.dateTime);

  factory Device.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  @override
  String toString() {
    return 'Device{nameDevice: $nameDevice, serialName: $serialName, osVersion: $osVersion, person: $person, dateTime: $dateTime}';
  }


}

_$EntryFromJson(json) {
  return Device(
    json['nameDevice'],
    json['serialName'],
    json['osVersion'],
    json['person'],
    json['dateTime'],
  );
}

_$EntryToJson(Device device) {
  return {
    'nameDevice': device.nameDevice,
    'serialName': device.serialName,
    'osVersion': device.osVersion,
    'person': device.person,
    'dateTime': device.dateTime,
  };
}
