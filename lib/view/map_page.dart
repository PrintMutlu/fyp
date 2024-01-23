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
            /*Text('${Provider
                .of<LocationProvider>(context)
                .x}'),
            const SizedBox(height: 10,),
            Text('${Provider
                .of<LocationProvider>(context)
                .y}'),
            const SizedBox(height: 20,),*/
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
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 140,
                    top: 0,
                    child: Icon(
                      Icons.bluetooth_audio,
                      size: 22,
                      color: Colors.blue,
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    top: 272,
                    child: Icon(
                      Icons.bluetooth_audio,
                      size: 22,
                      color: Colors.blue,
                    ),
                  ),
                  const Positioned(
                    left: 272,
                    top: 272,
                    child: Icon(
                      Icons.bluetooth_audio,
                      size: 22,
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