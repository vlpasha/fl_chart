import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScopeChannelsValue {
  final List<double> values;
  final int timestamp;
  ScopeChannelsValue({this.values, this.timestamp});
}

class ScopeChannelModel {
  final bool show;
  final Color color;
  final double width;
  ScopeChannelModel({
    this.show = true,
    @required this.color,
    this.width = 2.0,
  });
}

class ScopeChannel extends ScopeChannelModel {
  List<FlSpot> spots;
  ScopeChannel({bool show, Color color, double width, List<FlSpot> spots})
      : spots = spots ?? [FlSpot(0, 0)],
        super(show: show, color: color, width: width);
}

class RealTimeScope extends StatefulWidget {
  final int maxSpots;
  final List<ScopeChannelModel> channelsData;
  final Stream<ScopeChannelsValue> dataStream;
  final int _channelsCount;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  RealTimeScope({
    Key key,
    @required List<ScopeChannelModel> channels,
    @required this.maxSpots,
    @required this.dataStream,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
  })  : _channelsCount = channels.length,
        channelsData = channels,
        super(key: key);

  @override
  State<RealTimeScope> createState() => _RealTimeScopeState();
}

class _RealTimeScopeState extends State<RealTimeScope> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  StreamSubscription<ScopeChannelsValue> _subscr;
  List<ScopeChannel> _channels;
  final _axesData = ScopeAxesData(
    vertical: ScopeAxis(
      showAxis: true,
      grid: ScopeGrid(),
      title: ScopeAxisTitle(showTitle: false, titleText: 'Left Title'),
      titles: ScopeTitles(
        showTitles: true,
        reservedSize: 50,
        getTitles: (value) => value.toStringAsFixed(1),
      ),
    ),
    horizontal: ScopeAxis(
      showAxis: true,
      interval: 1000,
      grid: ScopeGrid(),
      title: ScopeAxisTitle(showTitle: false, titleText: 'Bottom Title'),
      titles: ScopeTitles(
        showTitles: true,
        getTitles: (value) {
          var seconds = ((value ~/ 1000) % 60),
              minutes = ((value ~/ (1000 * 60)) % 60),
              hours = ((value ~/ (1000 * 60 * 60)) % 24);
          return '${hours.toString().padLeft(2, '0')}:'
              '${minutes.toString().padLeft(2, '0')}:'
              '${seconds.toString().padLeft(2, '0')}';
        },
      ),
    ),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _channels = widget.channelsData
        .map(
          (item) => ScopeChannel(
            show: item.show,
            color: item.color,
            width: item.width,
            spots: [],
          ),
        )
        .toList();

    _subscr = widget.dataStream.listen((event) => _subscr.pause(_buildData(event)));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
  }

  Future<void> _buildData(ScopeChannelsValue event) {
    if (event.values.length != widget._channelsCount) {
      throw Exception('Values sount must match channles count');
    }
    for (var i = 0; i < widget._channelsCount; i++) {
      if (_channels[i].spots.length == widget.maxSpots) {
        _channels[i].spots.removeAt(0);
      }
      _channels[i].spots.add(FlSpot(
            event.timestamp.toDouble(),
            event.values[i],
          ));
    }
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ScopeChart(
            data: ScopeChartData(
              axesData: _axesData,
              clipData: FlClipData.none(),
              minY: widget.minY,
              maxY: widget.maxY,
              minX: _channels[0].spots.isNotEmpty ? _channels[0].spots.first.x : widget.minX ?? 0,
              maxX: _channels[0].spots.isNotEmpty && _channels[0].spots.last.x > widget.maxX ?? 0
                  ? _channels[0].spots.last.x
                  : widget.maxX ?? 0,
              lineBarsData: _channels[0].spots.isNotEmpty
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
          ),
        );
      },
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  @override
  _LineChartSample1State createState() => _LineChartSample1State();
}

class _LineChartSample1State extends State<LineChartSample1> {
  var rnd = Random();
  int timeStep = 60;
  int spotsCount = 200;
  double radians = 0.0;

  int startTime = 0;
  final StreamController<ScopeChannelsValue> _stream = StreamController();

  @override
  void initState() {
    var _startTime = 0;
    // DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(Duration(milliseconds: timeStep), (timer) {
      _stream.add(ScopeChannelsValue(
        values: [
          sin((radians * pi)) * 1000,
          cos((radians * pi)) * 500,
          atan((radians * pi)) * 100,
        ],
        timestamp: _startTime,
      ));
      _startTime += timeStep;
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
      maxSpots: spotsCount,
      dataStream: _stream.stream,
      minX: 0,
      maxX: (timeStep * spotsCount).toDouble(),
      maxY: 1100,
      minY: -1100,
      channels: [
        ScopeChannelModel(color: Colors.red),
        ScopeChannelModel(color: Colors.green),
        ScopeChannelModel(color: Colors.blue),
      ],
    );
  }
}
