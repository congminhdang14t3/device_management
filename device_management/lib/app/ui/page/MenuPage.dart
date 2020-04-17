import 'package:device_management/app/ui/widgets/MenuBackground.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
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
      home: SplashScreen.navigate(
        backgroundColor: Colors.white,
        name: 'assets/splash.flr',
        next: (context) => SimpleHiddenDrawer(
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
        until: () => Future.delayed(Duration(milliseconds: 100)),
        startAnimation: 'intro',
      ),
    );
  }
}

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int position = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height / 5),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const FlutterLogo(size: 80),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue),
                        color: Colors.blue[100]),
                  ),
                  ListTile(
                      title: Text('Home Page'),
                      leading: Icon(Icons.brightness_1,
                          color: position == 0 ? Colors.green : Colors.grey),
                      onTap: () {
                        SimpleHiddenDrawerProvider.of(context)
                            .setSelectedMenuPosition(0);
                        setState(() {
                          position = 0;
                        });
                      }),
                  ListTile(
                      title: Text('Device Infomation'),
                      leading: Icon(Icons.brightness_1,
                          color: position == 1 ? Colors.green : Colors.grey),
                      onTap: () {
                        SimpleHiddenDrawerProvider.of(context)
                            .setSelectedMenuPosition(1);
                        setState(() {
                          position = 1;
                        });
                      }),
                  ListTile(
                      title: Text('About us'),
                      leading: Icon(Icons.brightness_1,
                          color: position == 2 ? Colors.green : Colors.grey))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
