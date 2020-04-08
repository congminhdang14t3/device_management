import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:device_management/app/model/core/AppStoreApplication.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/utility/log/Log.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import 'dart:io';
import 'package:flutter/services.dart';

class DeviceInfoBloc {
  final AppStoreApplication _application;
  CompositeSubscription _compositeSubscription = CompositeSubscription();

  final _isShowLoading = BehaviorSubject<bool>();
  final _deviceInfo = BehaviorSubject<dynamic>();

  Stream<bool> get isShowLoading => _isShowLoading.stream;

  Stream<dynamic> get deviceInfo => _deviceInfo.stream;

  DeviceInfoBloc(this._application) {
    _init();
  }

  _init() {}
  List<Device> _listDevices = [];
  Device _device;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  void dispose() {
    _compositeSubscription.clear();
    _isShowLoading.close();
    _deviceInfo.close();
  }

  void checkDevice() {
    _isShowLoading.add(true);

    StreamSubscription subscription = Observable.fromFuture(initPlatformState())
        .zipWith(Observable.fromFuture(getDevices()),
            (Map<String, dynamic> device, DataSnapshot listDevices) {
      return CombineResponse(device, listDevices);
    }).listen((CombineResponse response) {
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
        _listDevices.add(d);
      }
//      print(_list.toString());
      List<String> deviceInfos = [];
      for (var key in response.mapDevice.keys) {
        deviceInfos.add(response.mapDevice[key]);
      }
      _device = Device(
          deviceInfos[0], deviceInfos[1], deviceInfos[2], '', '', '', []);
//      print("AAAAA:: " + device.toString());

      handle();
      _isShowLoading.add(false);
    }, onError: (e, s) {
      Log.info(e);
    });
    _compositeSubscription.add(subscription);
  }

  void handle() {
    bool isAdd = false;
    String updateOS = '';
    for (var i = 0; i < _listDevices.length; i++) {
      if (_listDevices[i].serialNumber.contains(_device.serialNumber)) {
        isAdd = true;
        _device = _listDevices[i];
        if (!_listDevices[i].osVersion.contains(_device.osVersion)) {
          updateOS = _listDevices[i].osVersion;
        }
        break;
      }
    }
    _deviceInfo.add({
      'device': _device,
      'add': isAdd,
      'osUpdate': updateOS,
    });
  }

  Future<List<String>> getImageFromServer(String nameDevice) async {
    nameDevice = nameDevice.trim().replaceAll(' ', '+').replaceAll('_', '+');
    Response response = await Dio().get(
        'https://app.zenserp.com/api/v2/search?apikey=ba085d20-70a8-11ea-acc6-bd64563d40cd&q=$nameDevice&tbm=isch&device=mobile&num=50');
    Map<String, dynamic> mapImages = response.data;
    List<String> images = [];
    for (var i = 0; i < 3; i++) {
      images.add(mapImages['image_results'][i]['sourceUrl']);
      print('AAA: ' + images[i]);
    }
    return images;
  }

  void addDevice() async {
    _isShowLoading.add(true);
    _device.listImages = await getImageFromServer(_device.nameDevice);
    FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .push()
        .set(_device.toJson())
        .then((value) {
      _listDevices.add(_device);
      handle();
      _isShowLoading.add(false);
    });
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
