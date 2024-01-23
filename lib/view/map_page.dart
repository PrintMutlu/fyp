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
  late double x;
  late double y;
  Offset location = const Offset(0, 0);

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
            const Text("Oda", style: TextStyle(fontSize: 20),),
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
                  const Positioned(
                    left: 130,
                    top: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.bluetooth_audio,
                          size: 22,
                          color: Colors.blue,
                        ),
                        Text(
                          'Beacon 1',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    top: 260,
                    child: Column(
                      children: [
                        Icon(
                          Icons.bluetooth_audio,
                          size: 22,
                          color: Colors.blue,
                        ),
                        Text(
                          'Beacon 2',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 251,
                    top: 260,
                    child: Column(
                      children: [
                        Icon(
                          Icons.bluetooth_audio,
                          size: 22,
                          color: Colors.blue,
                        ),
                        Text(
                          'Beacon 3',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: Provider.of<LocationProvider>(context).x - 15,
                    top: Provider.of<LocationProvider>(context).y - 29,
                    child: const Column(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 30,
                          color: Colors.red,
                        ),
                        Text(
                          'Siz',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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