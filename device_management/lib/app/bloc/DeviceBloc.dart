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
  final _isAllDevices = BehaviorSubject<bool>();
  final _isShowKeyBoard = BehaviorSubject<bool>();
  final _searchText = BehaviorSubject<String>();
  final _getListDevices = BehaviorSubject<List<Device>>();

  Stream<bool> get isShowLoading => _isShowLoading.stream;

  Stream<bool> get isAllDevices => _isAllDevices.stream;

  Stream<String> get searchText => _searchText.stream;

  Stream<List<Device>> get getListDevices => _getListDevices.stream;

  Stream<bool> get isShowKeyBoard => _isShowKeyBoard.stream;

  DeviceBloc(this._application) {
    _init();
  }

  _init() {
    _searchText
        .debounceTime(const Duration(milliseconds: 1000))
        .listen((String searchText) {
      _searchWords = searchText;
      createList();
    });
  }

  String _searchWords = '';
  bool _isDevices = true;
  List<Device> _list = [];

  bool check = true;

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
      createList();
    });
  }

  void keyBoardEvent(bool isShow) {
    _isShowKeyBoard.add(isShow);
  }

  void searchDevice(String search) {
    _searchText.add(search.toLowerCase());
  }

  void chooseOptions(bool check) {
    if (check != _isDevices) {
      _isDevices = check;
      createList();
      _isAllDevices.add(check);
//      print('AAA: ' + check.toString());
    }
  }

  void createList() {
    _getListDevices.add(_list
        .where((element) =>
            (_isDevices ? true : element.isAvailable()) &&
            (element.nameDevice.toLowerCase().contains(_searchWords)))
        .toList());
  }

  Future<void> addDivice() async {
    List<String> images = [
      'https://cdn.tgdd.vn/Products/Images/42/218363/huawei-nova-7i-pink-600x600-400x400.jpg',
      'https://cdn.tgdd.vn/Products/Images/42/198985/huawei-p30-lite-1-400x400.jpg',
      'https://cdn.tgdd.vn/Products/Images/42/209795/huawei-nova-5t-400x460-400x460.png'
    ];
    Device device = Device("Huawei Pro 30", "12345678910", "10.1.0",
        "Lan Huynh", "lan.huynh@codecomplete.jp", "03/04/2020", images);
    return await FirebaseDatabase.instance
        .reference()
        .child('devices/list')
        .push()
        .set(device.toJson());
  }
}
