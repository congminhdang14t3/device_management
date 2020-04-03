import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_management/app/bloc/DeviceBloc.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/utility/Utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:device_management/app/bloc/HomeBloc.dart';
import 'package:device_management/app/model/core/AppProvider.dart';
import 'package:device_management/app/model/pojo/AppContent.dart';
import 'package:device_management/app/ui/page/AppDetailPage.dart';
import 'package:device_management/generated/i18n.dart';
import 'package:device_management/utility/widget/StreamListItem.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'dart:math' as math;
import 'DeviceDeitalPage.dart';

class DevicePage extends StatefulWidget {
  static const String PATH = '/';

  DevicePage({Key key}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String text = 'loading...';
  DeviceBloc bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        print(visible);
      },
    );
  }

  @override
  void didChangeDependencies() {
    if (null == bloc) {
      bloc = DeviceBloc(AppProvider.getApplication(context));
      bloc.isShowLoading.listen((bool isLoading) {
        if (isLoading) {
          Utils.showLoading(context);
        } else {
          Navigator.pop(context);
        }
      });
      bloc.loadListDevices();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final menuIcon = IconButton(
        padding: EdgeInsets.only(left: 5.0),
        icon: Icon(Icons.menu, size: 45, color: Colors.red),
        onPressed: () {
          print('menuIcon');
        });
    final searchBox = Padding(
        padding: EdgeInsets.only(left: 10.0, right: 60),
        child: TextField(
            onChanged: (value) {},
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
            )));
    final rowOption = Padding(
        padding: EdgeInsets.only(left: 10, right: 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(width: 3, color: Colors.red)),
                width: 130,
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                        Image.asset(
                          'assets/devices.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('All Devices'),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(width: 1, color: Colors.grey)),
                width: 130,
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                        Image.asset(
                          'assets/available.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Available'),
                  ],
                ),
              ),
            )
          ],
        ));

    final swipeImages = new Swiper(
      itemBuilder: (BuildContext context, int index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2,
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(child: Center(child: Text("Iphone 11 Pro Max"))),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    index % 2 == 0 ? Icons.check_circle : Icons.account_circle,
                    color: index % 2 == 0 ? Colors.green : Colors.orange,
                  ),
                )
              ]),
              Expanded(
                child: CachedNetworkImage(
                    imageUrl:
                        'https://cdn.tmobile.com/content/dam/t-mobile/en-p/cell-phones/apple/Apple-iPhone-11-Pro/Midnight-Green/Apple-iPhone-11-Pro-Midnight-Green-frontimage.jpg',
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    fadeOutDuration: new Duration(seconds: 1),
                    fadeInDuration: new Duration(seconds: 1)),
              )
            ],
          ),
        );
      },
      itemCount: 4,
      viewportFraction: 0.6,
      scale: 0.8,
      autoplay: true,
      pagination: SwiperPagination(
          alignment: Alignment.bottomLeft,
          builder: FractionPaginationBuilder(color: Colors.blue,fontSize: 30)),
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
                child: Stack(
                  children: <Widget>[
                    CustomPaint(
                      painter: ShapesPainter(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                menuIcon,
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Device\n\t\t\tManagement",
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 35),
                            searchBox,
                            SizedBox(height: 30),
                            rowOption,
                            SizedBox(height: 30),
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 350,
                              child: swipeImages,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(top: 125),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(50)),
                          child: IconButton(
                              icon:
                                  Icon(Icons.photo_camera, color: Colors.white),
                              onPressed: () {}),
                        ))
                  ],
                ))));
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
