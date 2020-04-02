import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/app/ui/page/DeviceDeitalPage.dart';
import 'package:device_management/app/ui/page/DevicePage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:device_management/app/ui/page/AppDetailPage.dart';
import 'package:device_management/app/ui/page/HomePage.dart';

var rootHandlerDevice = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return DevicePage();
});

var rootHandlerDeviceDetail = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return DeviceDetailPage();
});

var rootHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HomePage();
});

var appDetailRouteHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String appId = params['appId']?.first;
  String heroTag = params['heroTag']?.first;
  String title = params['title']?.first;
  String url = params['url']?.first;
  String titleTag = params['titleTag']?.first;

  return new AppDetailPage(
      appId: num.parse(appId),
      heroTag: heroTag,
      title: title,
      url: url,
      titleTag: titleTag);
});

class AppRoutes {
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print('ROUTE WAS NOT FOUND !!!');
    });

    router.define(DevicePage.PATH, handler: rootHandlerDevice);
    router.define(DeviceDetailPage.PATH, handler: rootHandlerDeviceDetail);
//    router.define(HomePage.PATH, handler: rootHandler);
//    router.define(AppDetailPage.PATH, handler: appDetailRouteHandler);
  }
}
