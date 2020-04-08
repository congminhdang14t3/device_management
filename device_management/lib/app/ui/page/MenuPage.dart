import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';

import 'DeviceInfoPage.dart';
import 'DevicePage.dart';

void main() => runApp(MenuPage());

class MenuPage extends StatelessWidget {
  static const String PATH = '/';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        cursorColor: Colors.red,
        primarySwatch: Colors.red,
      ),
      home: SimpleHiddenDrawer(
        menu: Menu(),
        screenSelectedBuilder: (position, controller) {
          Widget screenCurrent;

          switch (position) {
            case 0:
              screenCurrent = DevicePage();
              break;
            case 1:
              screenCurrent = DeviceInfoPage();
              break;
          }
          return Scaffold(body: screenCurrent);
        },
      ),
    );
  }
}

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.blue, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.topRight,
      )),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                SimpleHiddenDrawerProvider.of(context)
                    .setSelectedMenuPosition(0);
              },
              child: Text("Home Page"),
            ),
            RaisedButton(
                onPressed: () {
                  SimpleHiddenDrawerProvider.of(context)
                      .setSelectedMenuPosition(1);
                },
                child: Text("Device Infomation"))
          ],
        ),
      ),
    );
  }
}
