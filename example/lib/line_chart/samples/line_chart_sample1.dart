import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScopeChannelsValue {
  final List<double> values;
  final int timestamp;
  ScopeChannelsValue({this.values, this.timestamp});
}

class ChannelData {
  final bool show;
  final Color color;
  final double width;
  ChannelData({
    this.show = true,
    @required this.color,
    this.width = 2.0,
  });
}

class ScopeChannel extends ChannelData {
  List<FlSpot> spots;
  ScopeChannel({bool show, Color color, double width, List<FlSpot> spots})
      : spots = spots ?? [FlSpot(0, 0)],
        super(show: show, color: color, width: width);
}

class RealTimeScope extends StatelessWidget {
  final int maxSpots;
  final int timeStep;
  final List<ChannelData> channelsData;
  final Stream<ScopeChannelsValue> dataStream;
  final int _channelsCount;
  final double minY;
  final double maxY;
  RealTimeScope({
    Key key,
    @required List<ChannelData> channels,
    @required this.maxSpots,
    @required this.timeStep,
    @required this.dataStream,
    @required this.minY,
    @required this.maxY,
  })  : _channelsCount = channels.length,
        channelsData = channels,
        super(key: key);

  String _timestamp(int timestamp) {
    var time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}.${time.millisecond.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    var _startTime = DateTime.now().millisecondsSinceEpoch;
    var _channels = channelsData
        .map(
          (item) => ScopeChannel(
            show: item.show,
            color: item.color,
            width: item.width,
            spots: List.generate(maxSpots,
                (index) => FlSpot((_startTime - (maxSpots - index) * timeStep).toDouble(), 0),
                growable: true),
          ),
        )
        .toList();
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20, right: 20),
        child: StreamBuilder<ScopeChannelsValue>(
          stream: dataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.values.length != _channelsCount) {
                throw Exception('Values sount must match channles count');
              }
              var data = snapshot.data;
              for (var i = 0; i < _channelsCount; i++) {
                if (_channels[i].spots.length == maxSpots) {
                  _channels[i].spots.removeAt(0);
                }
                _channels[i].spots.add(FlSpot(
                      data.timestamp.toDouble(),
                      data.values[i],
                    ));
              }
            }
            return ScopeChart(
              data: ScopeChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 0.5),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) => _timestamp(value.toInt()),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    interval: 0.5,
                    getTitles: (value) => value.toStringAsFixed(1),
                  ),
                ),
                minY: minY,
                maxY: maxY,
                lineBarsData: snapshot.connectionState == ConnectionState.active
                    ? _channels
                        .map(
                          (item) => ScopeChartBarData(
                            barWidth: item.width,
                            color: item.color,
                            show: item.show,
                            spots: item.spots,
                          ),
                        )
                        .toList()
                    : [],
              ),
            );
          },
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
  var rnd = Random();
  double radians = 0.0;

  int startTime = 0;
  final StreamController<ScopeChannelsValue> _stream = StreamController();

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      _stream.add(ScopeChannelsValue(
        values: [
          sin((radians * pi + 0)),
          sin((radians * pi + 1)),
          sin((radians * pi + 2)),
        ],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
      radians += 0.05;
      if (radians >= 2.0) {
        radians = 0.0;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RealTimeScope(
      maxSpots: 200,
      timeStep: 30,
      dataStream: _stream.stream,
      maxY: 1,
      minY: -1,
      channels: [
        ChannelData(color: Colors.red),
        ChannelData(color: Colors.green),
        ChannelData(color: Colors.blue),
      ],
    );
  }
}
