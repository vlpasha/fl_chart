import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EcuFpeActuatorTempPoint {
  final int temp;
  final Duration duration;
  EcuFpeActuatorTempPoint(this.temp, this.duration);
}

class ActTempHistoryChart extends StatelessWidget {
  List<FlSpot> _spots;
  final List<Color> _colors = [
    Colors.blue,
    Colors.yellow,
    Colors.yellow,
    Colors.red,
  ];
  List<double> _stops;
  double _minX;
  double _maxX;
  double _minY;
  double _maxY;

  final double tempLow = 135.0;
  final double tempHigh = 150.0;

  ActTempHistoryChart({
    Key key,
    @required List<EcuFpeActuatorTempPoint> data,
  }) : super(key: key) {
    _spots = data
        .map((item) => FlSpot(
              item.temp.toDouble(),
              item.duration.inMinutes.toDouble(),
            ))
        .toList();
    _spots.sort((a, b) => a.x.compareTo(b.x));
    _minX = _spots.first.x;
    _maxX = _spots.last.x;
    _stops = _calcStops(tempLow, tempHigh, _minX, _maxX);
  }

  List<double> _calcStops(double low, double high, double min, double max) {
    var lowToMedStop = (low - min) / (max - min);
    var medTohighStop = (high - min) / (max - min);
    return [lowToMedStop, lowToMedStop, medTohighStop, medTohighStop];
  }

  String _getLeftAxisTitles(double value) {
    if (value > 9999 && value <= 999999) {
      final tick = value / 1000;
      final round = tick.truncateToDouble() == tick ? 0 : 2;
      return '${tick.toStringAsFixed(round)}K';
    } else if (value > 999999) {
      final tick = value / 1000000;
      final round = tick.truncateToDouble() == tick ? 0 : 2;
      return '${tick.toStringAsFixed(round)}M';
    }

    return value.toStringAsFixed(0);
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
      ),
      axisTitleData: FlAxisTitleData(
        leftTitle: AxisTitle(showTitle: true, titleText: 'Minutes'),
        bottomTitle: AxisTitle(showTitle: true, titleText: '°C'),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (value) => value.toStringAsFixed(0),
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: _getLeftAxisTitles,
        ),
      ),
      minX: _minX,
      maxX: _maxX,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: _spots,
          isCurved: false,
          isStepLineChart: true,
          colorStops: _stops,
          colors: _colors,
          barWidth: 1,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradientColorStops: _stops,
            colors: _colors,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20, right: 20),
        child: LineChart(_mainData()),
      ),
    );
  }
}

class LineChartSample2 extends StatefulWidget {
  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<EcuFpeActuatorTempPoint> points = [];

  @override
  void initState() {
    var rnd = Random();
    for (var i = -50; i <= 200; i += 5) {
      points.add(EcuFpeActuatorTempPoint(i, Duration(days: 0)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ActTempHistoryChart(data: points);
  }
}
