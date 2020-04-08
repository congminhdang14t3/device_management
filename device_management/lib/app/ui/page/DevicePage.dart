import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_management/app/bloc/DeviceBloc.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:device_management/utility/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'DeviceDeitalPage.dart';

class DevicePage extends StatefulWidget {
  static const String PATH = '/';

  DevicePage({Key key}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  TextEditingController _controller;
  DeviceBloc bloc;
  bool _isShowKeyBoard;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _isShowKeyBoard = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (null == bloc) {
//      bloc = DeviceBloc(AppProvider.getApplication(context));
      bloc = DeviceBloc(null);
      bloc.isShowLoading.listen((bool isLoading) {
        if (isLoading) {
          Utils.showLoading(context);
        } else {
          Navigator.pop(context);
        }
      });
      bloc.loadListDevices();
    }

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        bloc.keyBoardEvent(visible);
        setState(() {
          _isShowKeyBoard = visible;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuBar = StreamBuilder(
      initialData: false,
      stream: bloc.isShowKeyBoard,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return SizedBox.shrink();
        }
        return Row(
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
                "Device\n\t\t\t Management",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ],
        );
      },
    );
    final searchBox = Padding(
        padding: EdgeInsets.only(left: 10.0, right: 55),
        child: StreamBuilder(
            stream: bloc.searchText,
            builder: (context, snapshot) {
              String searchText = snapshot.data;
              return TextField(
                  controller: _controller,
                  onChanged: bloc.searchDevice,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: null != searchText && searchText.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              bloc.searchDevice('');
                              _controller.clear();
                            })
                        : null,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  ));
            }));
    final rowOption = Padding(
        padding: EdgeInsets.only(left: 10, right: 55),
        child: StreamBuilder(
            initialData: true,
            stream: bloc.isAllDevices,
            builder: (context, snapshot) {
              bool isAllDevices = snapshot.data;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () => bloc.chooseOptions(true),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          border: isAllDevices
                              ? Border.all(width: 3, color: Colors.red)
                              : Border.all(width: 1, color: Colors.grey)),
                      width: 135,
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
                    onTap: () => bloc.chooseOptions(false),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          border: isAllDevices
                              ? Border.all(width: 1, color: Colors.grey)
                              : Border.all(width: 3, color: Colors.red)),
                      width: 135,
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
              );
            }));

    final swipeImages = StreamBuilder(
      stream: bloc.getListDevices,
      builder: (context, snapshot) {
        Map<String, dynamic> map = snapshot.data;
        if (map == null) {
          return Center(child: Text('List Empty.'));
        }
        List<Device> listDevices = map['list'];
        int index = map['index'];
        String time = map['time'];
//        print('index: '+index.toString());
        if (listDevices != null && listDevices.isNotEmpty) {
          return Swiper(
            index: index,
            itemCount: listDevices.length,
//            key: GlobalKey(),
            viewportFraction: 0.6,
            scale: 0.8,
//            autoplay: true,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                child: Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      Expanded(
                          child: Center(
                              child: Text(listDevices[index].nameDevice))),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                          listDevices[index].isAvailable()
                              ? Icons.check_circle
                              : Icons.account_circle,
                          color: listDevices[index].isAvailable()
                              ? Colors.green
                              : Colors.orange,
                        ),
                      )
                    ]),
                    Expanded(
                      child: CachedNetworkImage(
                          imageUrl: listDevices[index].listImages[0].trim(),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                          fadeOutDuration: new Duration(seconds: 1),
                          fadeInDuration: new Duration(seconds: 1)),
                    )
                  ],
                ),
              );
            },
            onTap: (index) async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DeviceDetailPage(
                          device: listDevices[index], indexImage: index)));

              bloc.changeImage(result['i1'], result['i2']);
            },
            pagination: SwiperPagination(
                margin: EdgeInsets.all(0),
                alignment:
                    _isShowKeyBoard ? Alignment.topLeft : Alignment.bottomLeft,
                builder: FractionPaginationBuilder(
                    color: Colors.blue, fontSize: 30)),
          );
        }
        return Center(child: Text('List Empty.'));
      },
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
                            menuBar,
                            SizedBox(height: 35),
                            searchBox,
                            SizedBox(height: 30),
                            rowOption,
                            SizedBox(height: 50),
                            SizedBox(
//                              height: MediaQuery.of(context).size.height - 350,
                              height: 280,
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
