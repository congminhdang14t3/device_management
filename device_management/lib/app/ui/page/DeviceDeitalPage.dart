import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:liquid_swipe/liquid_swipe.dart';

class DeviceDetailPage extends StatefulWidget {
  List<Device> list;
  static const String PATH = '/detail';

  DeviceDetailPage({Key key, this.list}) : super(key: key);

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  static final style = TextStyle(
    fontSize: 30,
    fontFamily: "Billy",
    fontWeight: FontWeight.w600,
  );

  int page = 0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.black,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  Widget _build(int index) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        color: page == index ? Colors.orange : Colors.black,
        width: 10,
        height: page == index ? 40 : 30,
      ),
    );
  }

  Widget itemDetail(index) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(index % 2 == 0
              ? 'https://cdn.tgdd.vn/Products/Images/42/188705/iphone-11-pro-black-400x400.jpg'
              : 'https://cdn.fptshop.com.vn/Uploads/Originals/2019/2/21/636863643187455627_ss-galaxy-s10-trang-1.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("AAA"),
              Container(height: 100,color: Colors.red,),
              Text("AAA"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: Stack(
        children: <Widget>[
          LiquidSwipe(
            pages: List<Container>.generate(
                widget.list.length, (index) => itemDetail(index)).toList(),
            enableLoop: true,
            onPageChangeCallback: pageChangeCallback,
            waveType: WaveType.liquidReveal,
          ),
//          Padding(
//            padding: EdgeInsets.all(20),
//            child: Column(
//              children: <Widget>[
//                Expanded(child: SizedBox()),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  crossAxisAlignment: CrossAxisAlignment.end,
//                  children: List<Widget>.generate(5, _build),
//                ),
//              ],
//            ),
//          ),
        ],
      ),
    );
  }

  pageChangeCallback(int lpage) {
    print(lpage);
    setState(() {
      page = lpage;
    });
  }
}
