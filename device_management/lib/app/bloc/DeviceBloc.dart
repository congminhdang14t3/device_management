import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:device_management/app/model/core/AppStoreApplication.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/utility/Utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter/services.dart';

class DeviceBloc {
  final AppStoreApplication _application;
  CompositeSubscription _compositeSubscription = CompositeSubscription();

  final _isShowLoading = BehaviorSubject<bool>();
  final _isAllDevices = BehaviorSubject<bool>();
  final _isShowKeyBoard = BehaviorSubject<bool>();
  final _searchText = BehaviorSubject<String>();
  final _getListDevices = BehaviorSubject<dynamic>();

  Stream<bool> get isShowLoading => _isShowLoading.stream;

  Stream<bool> get isAllDevices => _isAllDevices.stream;

  Stream<String> get searchText => _searchText.stream;

  Stream<dynamic> get getListDevices => _getListDevices.stream;

  Stream<bool> get isShowKeyBoard => _isShowKeyBoard.stream;

  DeviceBloc(this._application) {
    _init();
  }

  _init() {
    _searchText
        .debounceTime(const Duration(milliseconds: 1000))
        .listen((String searchText) {
      _searchWords = searchText;
      createList(0);
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

  void loadListDevices() async {
    _isShowLoading.add(true);
//    await Future.delayed(Duration(seconds: 1));

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
            linkImages
                .substring(1, linkImages.length - 1)
                .split(",")
                .where((element) => element.contains('http')).toList());
        d.id = key;
        _list.add(d);
        print(d.toString());
      }
      createList(0);
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
      createList(0);
      _isAllDevices.add(check);
//      print('AAA: ' + check.toString());
    }
  }

  void createList(int index) {
    _getListDevices.add({
      'list': _list
          .where((element) =>
              (_isDevices ? true : element.isAvailable()) &&
              (element.nameDevice.toLowerCase().contains(_searchWords)))
          .toList(),
      'index': index
    });
  }

  void changeImage(int i1, int i2) {
    if (i2 == 0) return;
    Device device = _list[i1];

    List<String> list = device.listImages;
    //swap 2 values
    String temp = list[0];
    list[0] = list[i2];
    list[i2] = temp;
    device.listImages = list;
    _list[i1] = device;

    createList(i1);
  }

  void scan(Function function) async {
    String barcode;

    try {
      barcode = await BarcodeScanner.scan();
      handleScanner(barcode, function);
      return;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        barcode = 'The user did not grant the camera permission!';
      } else {
        barcode = 'Unknown error: $e';
      }
    } on FormatException {
      barcode =
          'null (User returned using the "back"-button before scanning anything. Result)';
    } catch (e) {
      barcode = 'Unknown error: $e';
    }
    function.call(barcode);
  }

  void handleScanner(String scan, Function function) {
//    print(scan);
    Map<String, dynamic> map = jsonDecode(scan);

    String name = map['name'];
    String email = map['email'];
    updateScan(name, email, function);
  }

  void updateScan(String name, String email, Function function) {
    Utils.initPlatformState().then((value) {
      String deviceId = value['id'];
      print("ID: " + deviceId);
      try {
        Device device = _list
            .singleWhere((element) => element.serialNumber.contains(deviceId));
        if (device.emailHolder.length == 0) {
          device.emailHolder = email;
          device.nameHolder = name;
          device.dateTime =
              DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
          FirebaseDatabase.instance
              .reference()
              .child('devices/list')
              .child(device.id)
              .set(device.toJson())
              .then(
                  (value) => function.call('Hi, $name. Check-in successful!'));
        } else {
          //have holder
          if (device.emailHolder.contains(email)) {
            //check-out
            device.emailHolder = '';
            device.nameHolder = '';
            FirebaseDatabase.instance
                .reference()
                .child('devices/list')
                .child(device.id)
                .set(device.toJson())
                .then((value) =>
                    function.call('Hi, $name. Check-out successful!'));
          } else {
            //have anothor holder
            function.call('Device is hold by ' + device.nameHolder);
          }
        }
      } catch (e) {
        function.call('Device isn\'t added');
      }
    });
  }
}
