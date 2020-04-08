import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:device_management/app/model/core/AppStoreApplication.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/utility/log/Log.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import 'dart:io';
import 'package:flutter/services.dart';

class DeviceInfoBloc {
  final AppStoreApplication _application;
  CompositeSubscription _compositeSubscription = CompositeSubscription();

  final _isShowLoading = BehaviorSubject<bool>();
  final _getListDevices = BehaviorSubject<dynamic>();

  Stream<bool> get isShowLoading => _isShowLoading.stream;

  Stream<dynamic> get getListDevices => _getListDevices.stream;

  DeviceInfoBloc(this._application) {
    _init();
  }

  _init() {}

  List<Device> _list = [];
  bool check = true;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  void dispose() {
    _compositeSubscription.clear();
    _isShowLoading.close();
    _getListDevices.close();
  }

  void loadListDevices() {
    _isShowLoading.add(true);
    FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .onValue
        .listen((event) {
      if (check) {
        _isShowLoading.add(false);
        check = !check;
      }
      Map<dynamic, dynamic> decoded = event.snapshot.value;
      _list.clear();
      for (var key in decoded.keys) {
        String linkImages = decoded[key]['listImages'].toString();
        Device d = Device(
          decoded[key]['nameDevice'],
          decoded[key]['serialNumber'],
          decoded[key]['osVersion'],
          decoded[key]['nameHolder'],
          decoded[key]['emailHolder'],
          decoded[key]['dateTime'],
          linkImages.substring(1, linkImages.length - 1).split(","),
        ); // prints FF0000
        _list.add(d);
//        print(d.toString());
      }
    });
  }

  void checkDevice() {
    _isShowLoading.add(true);

    StreamSubscription subscription = Observable.fromFuture(initPlatformState())
        .zipWith(Observable.fromFuture(getDevices()),
            (Map<String, dynamic> device, DataSnapshot listDevices) {
      return CombineResponse(device, listDevices);
    }).listen((CombineResponse response) {
      List<Device> _list = [];
      Map<dynamic, dynamic> decoded = response.snapshotDevices.value;
      for (var key in decoded.keys) {
        String linkImages = decoded[key]['listImages'].toString();
        Device d = Device(
          decoded[key]['nameDevice'],
          decoded[key]['serialNumber'],
          decoded[key]['osVersion'],
          decoded[key]['nameHolder'],
          decoded[key]['emailHolder'],
          decoded[key]['dateTime'],
          linkImages.substring(1, linkImages.length - 1).split(","),
        ); // prints FF0000
        _list.add(d);
      }
//      print(_list.toString());
      List<String> deviceInfos = [];
      for (var key in response.mapDevice.keys) {
        deviceInfos.add(response.mapDevice[key]);
      }
      Device device = Device(
          deviceInfos[0], deviceInfos[1], deviceInfos[2], '', '', '', []);
//      print("AAAAA:: " + device.toString());
      _isShowLoading.add(false);
    }, onError: (e, s) {
      Log.info(e);
    });
    _compositeSubscription.add(subscription);
  }

  Future<DataSnapshot> getDevices() async {
    return await FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .once();
  }

  Future<Map<String, dynamic>> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        return _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        return _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      return <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }
    return <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'model': build.model,
      'androidId': build.androidId,
      'version.release': build.version.release,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'identifierForVendor': data.identifierForVendor,
      'utsname.release:': data.utsname.release,
    };
  }
}

class CombineResponse {
  Map<String, dynamic> mapDevice;
  DataSnapshot snapshotDevices;

  CombineResponse(this.mapDevice, this.snapshotDevices);
}
