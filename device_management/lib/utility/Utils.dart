import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class Utils {
  static void showLoading(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        child: Dialog(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Container(
                        margin: EdgeInsets.only(top: 8), child: Text('Loading'))
                  ],
                ))));
  }

  static Future<void> showAlertDialog(
      BuildContext context, String content, Function delete) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: const Text('Yes'),
              onPressed: (){
                delete.call();
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  static Future<Map<String, dynamic>> initPlatformState() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
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

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'model': build.model,
      'id': build.androidId,
      'release': build.version.release,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'model': data.name,
      'id': data.identifierForVendor,
      'release:': data.utsname.release,
    };
  }
}
