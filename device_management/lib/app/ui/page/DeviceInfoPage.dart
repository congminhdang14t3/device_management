import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_management/app/bloc/DeviceInfoBloc.dart';
import 'package:device_management/app/model/pojo/Device.dart';
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
                    child: StreamBuilder(
                        stream: bloc.deviceInfo,
                        builder: (context, snapshot) {
                          Map<String, dynamic> map = snapshot.data;
                          if (map == null) {
                            return Center(
                                child: Text('Error get device infomation'));
                          }
                          Device device = map['device'];
                          bool isAdd = map['add'];
                          String osUpdate = map['osUpdate'];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              menuBar,
                              ListTile(
                                title: Text("Name Device"),
                                subtitle: Text(device.nameDevice),
                              ),
                              ListTile(
                                title: Text("OS Version"),
                                subtitle: Text(device.osVersion),
                              ),
                              Expanded(
                                  child: (device.listImages == null ||
                                          device.listImages.isEmpty)
                                      ? SizedBox.shrink()
                                      : Container(
                                          constraints: BoxConstraints.expand(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2),
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          device.listImages[0]
                                                              .trim())),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                        )),
                              ListTile(
                                title: isAdd
                                    ? Text("*This device had added already",
                                        style: TextStyle(color: Colors.red))
                                    : SizedBox.shrink(),
                                subtitle: RaisedButton(
                                    elevation: 4.0,
                                    color: Colors.green[400],
                                    padding: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed:
                                        isAdd ? null : () => bloc.addDevice(),
                                    child: Text('Add')),
                              ),
                              ListTile(
                                title: Text(
                                    isAdd
                                        ? (osUpdate.length == 0
                                            ? "*Nothing to update so far"
                                            : "*Please update, the current OS version on server is $osUpdate")
                                        : "*Needed add device first",
                                    style: TextStyle(color: Colors.red)),
                                subtitle: RaisedButton(
                                    elevation: 4.0,
                                    color: Colors.yellow[400],
                                    padding: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: isAdd
                                        ? (osUpdate.length == 0
                                            ? null
                                            : () => bloc.updateDevice())
                                        : null,
                                    child: Text('Update')),
                              ),
                              ListTile(
                                title: isAdd
                                    ? SizedBox.shrink()
                                    : Text("*Needed add device first",
                                        style: TextStyle(color: Colors.red)),
                                subtitle: RaisedButton(
                                    elevation: 4.0,
                                    color: Colors.red[400],
                                    padding: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: isAdd
                                        ? () => Utils.showAlertDialog(context,
                                            'Are you sure to delete this device?',()=> bloc.deleteDevice())
                                        : null,
                                    child: Text('Delete')),
                              ),
                              SizedBox(height: 5.0)
                            ],
                          );
                        })))));
  }
}

Gradient gradient = LinearGradient(
  colors: orangeGradients,
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const List<Color> orangeGradients = [Colors.blue, Colors.red];

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    double width = size.width;

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
