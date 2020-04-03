import 'package:flutter/material.dart';

class Device {
  String nameDevice;
  String serialNumber;
  String osVersion;
  String nameHolder;
  String emailHolder;
  String dateTime;
  List<String> listImages;

  Device(this.nameDevice, this.serialNumber, this.osVersion, this.nameHolder,
      this.emailHolder, this.dateTime, this.listImages);

  factory Device.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  @override
  String toString() {
    return 'Device{nameDevice: $nameDevice, serialNumber: $serialNumber, osVersion: $osVersion, nameHolder: $nameHolder, emailHolder: $emailHolder, dateTime: $dateTime, listImages: $listImages}';
  }

  bool isAvailable() {
    return emailHolder.length == 0;
  }
}

_$EntryFromJson(json) {
  return Device(
    json['nameDevice'],
    json['serialNumber'],
    json['osVersion'],
    json['nameHolder'],
    json['emailHolder'],
    json['dateTime'],
    json['listImages'].toString().split(","),
  );
}

_$EntryToJson(Device device) {
  return {
    'nameDevice': device.nameDevice,
    'serialNumber': device.serialNumber,
    'osVersion': device.osVersion,
    'nameHolder': device.nameHolder,
    'emailHolder': device.emailHolder,
    'dateTime': device.dateTime,
    'listImages': device.listImages.toString(),
  };
}
