import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:device_management/app/model/core/AppStoreApplication.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/utility/Utils.dart';
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
  int _indexDevice = -1;

  void dispose() {
    _compositeSubscription.clear();
    _isShowLoading.close();
    _deviceInfo.close();
  }

  void checkDevice() async {
    _isShowLoading.add(true);
//    await Future.delayed(Duration(seconds: 1));

    StreamSubscription subscription =
        Observable.fromFuture(Utils.initPlatformState())
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
        );
        d.id = key.toString();
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

      _handle();
      _isShowLoading.add(false);
    }, onError: (e, s) {
      Log.info(e);
    });
    _compositeSubscription.add(subscription);
  }

  void _handle() {
    bool isAdd = false;
    String updateOS = '';
    for (var i = 0; i < _listDevices.length; i++) {
      if (_listDevices[i].serialNumber.contains(_device.serialNumber)) {
        isAdd = true;
        _device.listImages = _listDevices[i].listImages;
        _device.id = _listDevices[i].id;
        _indexDevice = i;
        if (!_listDevices[i].osVersion.contains(_device.osVersion)) {
          updateOS = _listDevices[i].osVersion;
        }
        break;
      }
    }
    print(_device.toString());
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

  void updateDevice() {
    _isShowLoading.add(true);
    FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .child(_device.id)
        .set(_device.toJson())
        .then((value) {
      if (_indexDevice != -1) {
        _listDevices[_indexDevice] = _device;
        _handle();
        _isShowLoading.add(false);
      }
    });
  }

//  void deleteDevice() {
//    _isShowLoading.add(true);
//    FirebaseDatabase.instance
//        .reference()
//        .child('devices/list')
//        .child(_device.id)
//        .remove()
//        .then((value) {
//      if (_indexDevice != -1) {
//        _listDevices.removeAt(_indexDevice);
//        _handle();
//        _isShowLoading.add(false);
//      }
//    });
//  }

  void addDevice() async {
    _isShowLoading.add(true);
    _device.listImages = await getImageFromServer(_device.nameDevice);
    //create key for device
    String key =
        FirebaseDatabase.instance.reference().child('devices/list').push().key;

    //add device by key
    FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .child(key)
        .set(_device.toJson())
        .then((value) {
      _listDevices.add(_device);
      _handle();
      _isShowLoading.add(false);
    });
  }

  Future<DataSnapshot> getDevices() async {
    return await FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .once();
  }
}

class CombineResponse {
  Map<String, dynamic> mapDevice;
  DataSnapshot snapshotDevices;

  CombineResponse(this.mapDevice, this.snapshotDevices);
}
