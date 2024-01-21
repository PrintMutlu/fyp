import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPage extends StatefulWidget {
  final List<int> rssiValues;

  ChartPage({Key? key, required this.rssiValues}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {


  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = widget.rssiValues.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();
    return Center(
      child: Container(
        width: 350,
        height: 350,
        child: LineChart(
          LineChartData(
            titlesData: const FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),

            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Color(0xff37434d),
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Color(0xff37434d),
                  strokeWidth: 1,
                );
              }
            ),

            borderData: FlBorderData(
              show: true,
              border: const Border(
                top: BorderSide(color: Color(0xff37434d), width: 0),
                bottom: BorderSide(color: Color(0xff37434d), width: 0),
                left: BorderSide(color: Color(0xff37434d), width: 0),
                right: BorderSide(color: Color(0xff37434d), width: 0),
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                belowBarData: BarAreaData(show: false),
                dotData: const FlDotData(show: true),
                color: Colors.blue,
                barWidth: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}