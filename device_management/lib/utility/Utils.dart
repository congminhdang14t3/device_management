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
                        margin: EdgeInsets.only(top: 8),
                        child: Text(S.of(context).dialogLoading))
                  ],
                ))));
  }
}
