import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_management/app/model/pojo/Device.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class DeviceDetailPage extends StatefulWidget {
  static const String PATH = '/detail';
  final Device device;
  final int indexImage;

  DeviceDetailPage({this.device, this.indexImage});

  @override
  DeviceDetailPageState createState() => DeviceDetailPageState();
}

class DeviceDetailPageState extends State<DeviceDetailPage> {
  int page = 0;
  final colors = [Colors.red, Colors.cyan, Colors.yellow];

  Container itemDevice(int index) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Container(
                    constraints: BoxConstraints.expand(),
                    alignment: Alignment.center,
                    child: CachedNetworkImage(
                        height: 310,
                        imageUrl: widget.device.listImages[index].trim())),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                    widget.device.listImages.length, _buildDot),
              ),
              SizedBox(
                height: 160,
              )
            ],
          ),
          Container(color: colors[index].withOpacity(0.1)),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          border: Border.all(
              color: index == page ? colors[index] : Colors.grey,
              width: index == page ? 3 : 1),
          borderRadius: BorderRadius.circular(20.0)),
      child: CachedNetworkImage(
          width: 70,
          height: 40,
          imageUrl: widget.device.listImages[index].trim()),
    );
  }

  Widget _detailWidget() {
    return Container(
      constraints: BoxConstraints.expand(height: 150),
      child: DraggableScrollableSheet(
        initialChildSize: 1 / 3,
        minChildSize: 1 / 3,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: Colors.red[300]),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5),
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints.expand(height: 40),
                    alignment: Alignment.center,
                    child: Text(
                      widget.device.nameDevice,
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Container(height: 2, color: Colors.white),
                  Container(
                    constraints: BoxConstraints.expand(height: 48),
                    child: Row(
                      children: <Widget>[
                        Text("OS version - ", style: TextStyle(fontSize: 20)),
                        Text(widget.device.osVersion,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                color: Colors.yellow))
                      ],
                    ),
                  ),
                  Container(height: 2, color: Colors.white),
                  Container(
                    constraints: BoxConstraints.expand(height: 48),
                    child: Row(
                      children: <Widget>[
                        Text("Holder - ", style: TextStyle(fontSize: 20)),
                        Text(
                            widget.device.isAvailable()
                                ? "Availabe"
                                : widget.device.nameHolder +
                                    " - " +
                                    widget.device.dateTime,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                color: Colors.yellow))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, {'i1': widget.indexImage, 'i2': page});
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.device.listImages;
//    print('AAA: ' + images.toString());
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          body: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 0,
                ),
                Expanded(
                  child: LiquidSwipe(
                    pages: List.generate(
                        images.length, (index) => itemDevice(index)).toList(),
                    enableLoop: true,
                    enableSlideIcon: true,
                    positionSlideIcon: 0.2,
                    slideIconWidget: Icon(Icons.arrow_back_ios),
                    onPageChangeCallback: pageChangeCallback,
                  ),
                )
              ],
            ),
            Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.bottomRight,
                constraints: BoxConstraints.expand(height: 80),
                child: IconButton(
                    icon: Icon(Icons.clear, size: 35),
                    onPressed: () => Navigator.pop(
                        context, {'i1': widget.indexImage, 'i2': page})))
          ],
        ),
        _detailWidget()
      ])),
    );
  }

  pageChangeCallback(int lpage) {
    print(lpage);
    setState(() {
      page = lpage;
    });
  }
}
