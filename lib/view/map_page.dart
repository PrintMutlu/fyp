import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/location_provider.dart';
import 'app_scanning.dart';

class MapPage extends StatefulWidget {


  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  bool isWidgetCreated =false;

  late double x;
  late double y;
  Offset location = const Offset(0, 0);
  TabScanning bec = TabScanning();

  /*@override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      isWidgetCreated = true;
      if (isWidgetCreated) {

      setState(() {
        //x = bec.x;
        //y = bec.y;
        //x = Provider.of<LocationProvider>(context).x;
        //y = Provider.of<LocationProvider>(context).y;

        //location = Offset(x, y);
      }
      );}

      });

  }*/



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${Provider
                .of<LocationProvider>(context)
                .x}'),
            const SizedBox(height: 10,),
            Text('${Provider
                .of<LocationProvider>(context)
                .y}'),
            const SizedBox(height: 20,),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),

              child: Stack(
                children: [
                  Positioned(
                    left: 150,
                    top: 150,
                    child: CustomPaint(
                      painter: DotPainter(Offset(Provider
                          .of<LocationProvider>(context)
                          .x, Provider
                          .of<LocationProvider>(context)
                          .y)),
                    ),
                  ),
                  const Positioned(
                    left: 137,
                    top: 0,
                    child: Icon(
                      Icons.bluetooth_audio,
                      size: 26,
                      color: Colors.blue,
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    top: 274,
                    child: Icon(
                      Icons.bluetooth_audio,
                      size: 26,
                      color: Colors.blue,
                    ),
                  ),
                  const Positioned(
                    left: 274,
                    top: 274,
                    child: Icon(
                      Icons.bluetooth_audio,
                      size: 26,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DotPainter extends CustomPainter {

  final Offset location;

  DotPainter(this.location);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    canvas.drawCircle(location, 10.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}