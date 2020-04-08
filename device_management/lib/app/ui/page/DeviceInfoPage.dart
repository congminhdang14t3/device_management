import 'package:device_management/app/bloc/DeviceInfoBloc.dart';
import 'package:device_management/utility/Utils.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';

class DeviceInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DeviceInfoPageState();
  }
}

class DeviceInfoPageState extends State<DeviceInfoPage> {
  DeviceInfoBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (null == bloc) {
//      bloc = DeviceBloc(AppProvider.getApplication(context));
      bloc = DeviceInfoBloc(null);
      bloc.isShowLoading.listen((bool isLoading) {
        if (isLoading) {
          Utils.showLoading(context);
        } else {
          Navigator.pop(context);
        }
      });
      bloc.checkDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuBar = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            padding: EdgeInsets.only(left: 5.0),
            icon: Icon(Icons.menu, size: 45, color: Colors.red),
            onPressed: () {
              SimpleHiddenDrawerProvider.of(context).toggle();
            }),
        const Padding(
          padding: const EdgeInsets.all(15.0),
          child: const Text(
            "Device\n\t\t\ Infomation",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
      ],
    );
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.blue, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            )),
            padding: EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(20)),
                child: CustomPaint(
                    painter: ShapesPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        menuBar,
                        ListTile(
                          title: Text("Name Device"),
                          subtitle: Text("ZPhone 7"),
                        ),
                        ListTile(
                          title: Text("OS Version"),
                          subtitle: Text("ZPhone 7"),
                        ),
                        Expanded(child: SizedBox.shrink()),
                        ListTile(
                          title: Text("*This device had added already",
                              style: TextStyle(color: Colors.red)),
                          subtitle: RaisedButton(
                              elevation: 4.0,
                              color: Colors.green[400],
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {},
                              child: Text('Add')),
                        ),
                        ListTile(
                          title: Text("*Nothing to update so far",
                              style: TextStyle(color: Colors.red)),
                          subtitle: RaisedButton(
                              elevation: 4.0,
                              color: Colors.yellow[400],
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {},
                              child: Text('Update')),
                        ),
                        ListTile(
                          title: Text("*This device had not added",
                              style: TextStyle(color: Colors.red)),
                          subtitle: RaisedButton(
                              elevation: 4.0,
                              color: Colors.red[400],
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {},
                              child: Text('Delete')),
                        ),
                        SizedBox(height: 10)
                      ],
                    )))));
  }
}

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    double width = size.width;

    const List<Color> orangeGradients = [Colors.blue, Colors.red];

    Gradient gradient = LinearGradient(
      colors: orangeGradients,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    Rect rect = Rect.fromPoints(Offset(0, 0), Offset(width, 150));
    paint.shader = gradient.createShader(rect);

    Path path = Path();
    path.lineTo(width, 0);
    path.lineTo(width, 150);
    path.quadraticBezierTo(width / 2, 150, 0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
