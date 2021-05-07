import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RealTimeChartPoint {
  final double value;
  final double timestamp;
  RealTimeChartPoint(this.value, this.timestamp);
}

class RealTimeChart extends StatefulWidget {
  static List<FlSpot> toSpots(List<RealTimeChartPoint> data) => data
      .map((item) => FlSpot(
            item.timestamp,
            item.value,
          ))
      .toList();

  final Stream<List<List<FlSpot>>> dataStream;
  RealTimeChart({
    Key key,
    @required this.dataStream,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RealTimeChartState();
}

class _RealTimeChartState extends State<RealTimeChart> {
  StreamSubscription _subscr;
  List<FlSpot> _spots0 = [FlSpot(0, 0)];
  List<FlSpot> _spots1 = [FlSpot(0, 0)];
  List<FlSpot> _spots2 = [FlSpot(0, 0)];
  double _minX;
  double _maxX;

  @override
  void initState() {
    _subscr = widget.dataStream.listen((event) => setState(() {
          _minX = event.isNotEmpty ? event[0].first.x : 0;
          _maxX = event.isNotEmpty ? event[0].last.x : 0;
          _spots0 = event[0];
          _spots1 = event[1];
          _spots2 = event[2];
        }));
    super.initState();
  }

  @override
  void dispose() {
    _subscr.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20, right: 20),
        child: ScopeChart(
          data: ScopeChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
            ),
            axisTitleData: FlAxisTitleData(
              leftTitle: AxisTitle(showTitle: true, titleText: ''),
              bottomTitle: AxisTitle(showTitle: true, titleText: 'mSec'),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (value) => value.toStringAsFixed(0),
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTitles: (value) => value.toStringAsFixed(0),
              ),
            ),
            minX: _minX,
            maxX: _maxX,
            minY: -1000,
            maxY: 1000,
            lineBarsData: [
              ScopeChartBarData(
                spots: _spots0,
                isCurved: false,
                color: Colors.red,
              ),
              ScopeChartBarData(
                spots: _spots1,
                isCurved: false,
                color: Colors.blue,
              ),
              ScopeChartBarData(
                spots: _spots2,
                isCurved: false,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  @override
  _LineChartSample1State createState() => _LineChartSample1State();
}

class _LineChartSample1State extends State<LineChartSample1> {
  List<RealTimeChartPoint> points0 = [];
  List<RealTimeChartPoint> points1 = [];
  List<RealTimeChartPoint> points2 = [];
  var rnd = Random();
  double radians = 0.0;

  int startTime = 0;
  final StreamController<List<List<FlSpot>>> _stream = StreamController();

  final maxPoints = 200;

  void _addPoint(List<RealTimeChartPoint> points, double offset) {
    var sv = sin((radians * pi + offset));

    if (points.length == maxPoints) {
      points.removeAt(0);
    }
    points.add(RealTimeChartPoint(sv * 1000, startTime.toDouble()));
  }

  @override
  void initState() {
    for (var i = 0; i < maxPoints; i++) {
      points0.add(RealTimeChartPoint(0, startTime.toDouble()));
      points1.add(RealTimeChartPoint(0, startTime.toDouble()));
      points2.add(RealTimeChartPoint(0, startTime.toDouble()));
      startTime++;
    }
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      _addPoint(points0, 0);
      _addPoint(points1, 1);
      _addPoint(points2, 2);
      startTime++;
      radians += 0.05;
      if (radians >= 2.0) {
        radians = 0.0;
      }
      _stream.add([
        RealTimeChart.toSpots(points0),
        RealTimeChart.toSpots(points1),
        RealTimeChart.toSpots(points2)
      ]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RealTimeChart(dataStream: _stream.stream);
  }
}
