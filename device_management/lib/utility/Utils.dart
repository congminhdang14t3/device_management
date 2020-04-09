import 'package:device_management/generated/i18n.dart';
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
}
