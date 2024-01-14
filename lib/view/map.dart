/*import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'app_scanning.dart';

class Map extends StatefulWidget {
  TabScanning bec = TabScanning();

  double x = 0, y = 0;

  Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {



  late final List<double> xValues;
  late final List<double> yValues;


  double xx = 0, yy = 0;

  Offset location = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {

        widget.x = widget.bec.x;
        yy = widget.bec.y;

        location = Offset(xx,yy);
      });
    });

  }

  void updateLocation() {

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Sayfası'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${xx}'),
            SizedBox(height: 10,),
            Text('${widget.y}'),
            SizedBox(height: 20,),

            Container(
              width: 300, // Kare genişliği
              height: 300, // Kare yüksekliği
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.black, // Kenar rengini burada belirle
                  width: 2.0, // Kenar kalınlığını isteğine göre ayarla
                ),
              ),

              child: Stack(
                children: [
                  Positioned(
                    left: 150, // Kare genişliğinin yarısı
                    top: 150, // Kare yüksekliğinin yarısı
                    child: CustomPaint(
                      painter: DotPainter(location),
                    ),
                  ),
                  const Positioned(
                    left: 137,
                    top: 0,
                    child: Icon(
                      Icons.bluetooth_audio, // İstediğiniz ikon
                      size: 26, // İkonun boyutu
                      color: Colors.blue, // İkonun rengi
                    ),
                  ),
                  /*const Positioned(
                    left: 275,
                    top: 0,
                    child: Icon(
                      Icons.bluetooth_audio, // İstediğiniz ikon
                      size: 25, // İkonun boyutu
                      color: Colors.blue, // İkonun rengi
                    ),
                  ),*/
                  const Positioned(
                    left: 0,
                    top: 274,
                    child: Icon(
                      Icons.bluetooth_audio, // İstediğiniz ikon
                      size: 26, // İkonun boyutu
                      color: Colors.blue, // İkonun rengi
                    ),
                  ),
                  const Positioned(
                    left: 274,
                    top: 274,
                    child: Icon(
                      Icons.bluetooth_audio, // İstediğiniz ikon
                      size: 26, // İkonun boyutu
                      color: Colors.blue, // İkonun rengi
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
}*/