import 'dart:async';
import 'package:flutter/material.dart';

class Map extends StatefulWidget {
  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  List<double> xValues = [
    142,
    135,
    125,
    95,
    35,
    25,
  ]; //19
  List<double> yValues = [
    145,
    136,
    100,
    85,
    10,
    30,
  ]; //18

  double x = 142;
  double y = 145;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        x = xValues[currentIndex];
        y = yValues[currentIndex];

        currentIndex = (currentIndex + 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 80.0,
        elevation: 15,
        shadowColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Oda1",
                style: TextStyle(color: Colors.blueGrey, fontSize: 25)),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Color.fromRGBO(122, 133, 145, 0.050980392156862744),
                border: Border.all(
                  color: Color.fromRGBO(84, 91, 101, 0.8),
                  width: 0.9,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
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
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 303.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Gölge rengi ve opaklık
                    spreadRadius: 0.8, // Yayılma yarıçapı
                    blurRadius: 4.0, // Bulanıklık yarıçapı
                    offset: Offset(0, 3), // Gölgeyi yer değiştirme (x, y)
                  ),
                ],
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    Icons.bluetooth_audio,
                    size: 30,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Positioned(
                    bottom: 0,
                    child: Text(
                      'Beacon',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                  ),
                  Icon(
                    Icons.circle,
                    size: 30,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Positioned(
                    bottom: 0,
                    child: Text(
                      'Siz',
                      style: TextStyle(fontSize: 15, color: Colors.black),
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
