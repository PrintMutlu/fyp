import 'package:flutter/material.dart';
import 'map.dart';
class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Map()),
            );
          },
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Gölge rengi ve opaklık
                  spreadRadius: 1.0, // Yayılma yarıçapı
                  blurRadius: 5.0, // Bulanıklık yarıçapı
                  offset: Offset(0, 3), // Gölgeyi yer değiştirme (x, y)
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Konumu Başlat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
