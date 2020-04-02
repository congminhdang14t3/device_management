import 'dart:async';
import 'dart:convert';

import 'package:device_management/app/model/core/AppStoreApplication.dart';
import 'package:device_management/app/model/pojo/AppContent.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class DeviceBloc {
  final AppStoreApplication _application;
  CompositeSubscription _compositeSubscription = CompositeSubscription();

  final _isShowLoading = BehaviorSubject<bool>();

  final _getListDevices = BehaviorSubject<List<Device>>();

  Stream<bool> get isShowLoading => _isShowLoading.stream;

  Stream<List<Device>> get getListDevices => _getListDevices.stream;

  DeviceBloc(this._application);

  List<Device> _list = [];

  bool check = true;
  void dispose() {
    _compositeSubscription.clear();
    _isShowLoading.close();
    _getListDevices.close();
  }

  void loadListDevices() async {
//    _isShowLoading.add(true);
    if (check) {
      await addDivice();
      check = false;
    }
    FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .onValue
        .listen((event) {
//      _isShowLoading.add(false);
      Map<dynamic, dynamic> decoded = event.snapshot.value;
      _list.clear();
      for (var key in decoded.keys) {
        Device d = Device(
          decoded[key]['nameDevice'],
          decoded[key]['serialName'],
          decoded[key]['osVersion'],
          decoded[key]['person'],
          decoded[key]['dateTime'],
        ); // prints FF0000
        _list.add(d);
      }
      _getListDevices.add(_list);
    });
  }

  Future<void> addDivice() async {
    Device device = Device("Flutter", "hahaha", "9.0", "Minh", "toDay");
    return await FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .push()
        .set(device.toJson());
  }
}
