import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// class ScopeChannelModel {
//   final bool show;
//   final Color color;
//   final double width;
//   ScopeChannelModel({
//     this.show = true,
//     @required this.color,
//     this.width = 2.0,
//   });
// }

// class ScopeChannel extends ScopeChannelModel {
//   List<FlSpot> spots;
//   ScopeChannel({bool show, Color color, double width, List<FlSpot> spots})
//       : spots = spots ?? [FlSpot(0, 0)],
//         super(show: show, color: color, width: width);
// }

// class RealTimeScope extends StatefulWidget {
//   final int timeWindow;
//   final List<ScopeChannelModel> channelsData;
//   final Stream<ScopeChannelsValue> dataStream;
//   final int _channelsCount;
//   final double minY;
//   final double maxY;
//   RealTimeScope({
//     Key key,
//     @required List<ScopeChannelModel> channels,
//     @required this.timeWindow,
//     @required this.dataStream,
//     this.minY,
//     this.maxY,
//   })  : _channelsCount = channels.length,
//         channelsData = channels,
//         super(key: key);

//   @override
//   State<RealTimeScope> createState() => _RealTimeScopeState();
// }

// class _RealTimeScopeState extends State<RealTimeScope> with SingleTickerProviderStateMixin {
//   AnimationController _animationController;
//   StreamSubscription<ScopeChannelsValue> _subscr;
//   List<ScopeChannel> _channels;
//   bool _timestampCompensated = false;
//   int _timestampDelta = 0;
//   int _startTime;
//   final _axesData = ScopeAxesData(
//     vertical: ScopeAxis(
//       showAxis: true,
//       grid: ScopeGrid(),
//       title: ScopeAxisTitle(showTitle: false, titleText: 'Left Title'),
//       titles: ScopeTitles(
//         showTitles: true,
//         reservedSize: 50,
//         getTitles: (value) => value.toStringAsFixed(1),
//       ),
//     ),
//     horizontal: ScopeAxis(
//       showAxis: true,
//       interval: 1000,
//       grid: ScopeGrid(),
//       title: ScopeAxisTitle(showTitle: false, titleText: 'Bottom Title'),
//       titles: ScopeTitles(
//         showTitles: true,
//         getTitles: (value) {
//           var seconds = ((value ~/ 1000) % 60),
//               minutes = ((value ~/ (1000 * 60)) % 60),
//               hours = ((value ~/ (1000 * 60 * 60)) % 24);
//           return '${value < 0 ? "-" : ""}'
//               '${hours.toString().padLeft(2, '0')}:'
//               '${minutes.toString().padLeft(2, '0')}:'
//               '${seconds.toString().padLeft(2, '0')}';
//         },
//       ),
//     ),
//   );
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _channels = widget.channelsData
//         .map(
//           (item) => ScopeChannel(
//             show: item.show,
//             color: item.color,
//             width: item.width,
//             spots: [],
//           ),
//         )
//         .toList();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     )..repeat();
//     _startTime = DateTime.now().millisecondsSinceEpoch;
//     _subscr = widget.dataStream.listen((event) => _subscr.pause(_buildData(event)));
//   }

//   Future<void> _buildData(ScopeChannelsValue event) {
//     if (event.values.length != widget._channelsCount) {
//       throw Exception('Values sount must match channles count');
//     }
//     if (_timestampCompensated != true) {
//       _timestampDelta = DateTime.now().millisecondsSinceEpoch - event.timestamp;
//       _timestampCompensated = true;
//     }
//     for (var i = 0; i < widget._channelsCount; i++) {
//       if (_channels[i].spots.isNotEmpty &&
//           _channels[i].spots.last.x - _channels[i].spots.first.x > widget.timeWindow) {
//         _channels[i].spots.removeAt(0);
//       }
//       _channels[i].spots.add(FlSpot(
//             (event.timestamp + _timestampDelta - _startTime).toDouble(),
//             event.values[i],
//           ));
//     }
//     return Future<void>.value();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (_, __) {
//         final now = DateTime.now().millisecondsSinceEpoch - _startTime;
//         return Padding(
//           padding: const EdgeInsets.all(8),
//           child: ScopeChart(
//             data: ScopeChartData(
//               axesData: _axesData,
//               clipData: FlClipData.all(),
//               minY: widget.minY,
//               maxY: widget.maxY,
//               minX: (now - widget.timeWindow).toDouble(),
//               maxX: now.toDouble(),
//               channelsData: _channels[0].spots.isNotEmpty
//                   ? _channels
//                       .map(
//                         (item) => ScopeChannelData(
//                           barWidth: item.width,
//                           color: item.color,
//                           show: item.show,
//                           spots: item.spots,
//                         ),
//                       )
//                       .toList()
//                   : [],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class LineChartSample1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Expanded(child: DynamicScopeSample()),
            Expanded(child: StaticScopeSample()),
          ]);
}

class DynamicScopeSample extends StatefulWidget {
  @override
  _DynamicScopeSampleState createState() => _DynamicScopeSampleState();
}

class _DynamicScopeSampleState extends State<DynamicScopeSample> {
  Random rnd = Random();
  int timeStep = 30;
  double radians = 0.0;
  bool stop = false;
  int axisIndex = 0;

  int startTime = 0;
  final List<StreamController<ScopeChartChannelValue>> _streams = [
    StreamController.broadcast(),
    StreamController.broadcast(),
    StreamController.broadcast(),
    StreamController.broadcast(),
  ];
  List<ScopeChartChannel> _channels;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _channels = [
      ScopeChartDynamicChannel(
        id: '0',
        show: true,
        color: Colors.red,
        valuesStream: _streams[0].stream,
        axis: const ScopeAxisData(
          title: ScopeAxisTitle(showTitle: true, titleText: 'sin'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartDynamicChannel(
        id: '1',
        show: true,
        color: Colors.green,
        valuesStream: _streams[1].stream,
        axis: const ScopeAxisData(
          title: ScopeAxisTitle(showTitle: true, titleText: 'atan'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartDynamicChannel(
        id: '2',
        show: true,
        color: Colors.blue,
        valuesStream: _streams[2].stream,
        axis: const ScopeAxisData(
          title: ScopeAxisTitle(showTitle: true, titleText: 'cos'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartDynamicChannel(
        id: '3',
        show: true,
        color: Colors.blue,
        valuesStream: _streams[3].stream,
        axis: const ScopeAxisData(
          title: ScopeAxisTitle(showTitle: true, titleText: 'zero'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartDynamicChannel(
        id: '3',
        show: true,
        color: Colors.blue,
        valuesStream: _streams[3].stream,
        axis: const ScopeAxisData(
          title: ScopeAxisTitle(showTitle: true, titleText: 'zero'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
    ];

    _timer = Timer.periodic(Duration(milliseconds: timeStep), (timer) {
      final _timestamp = DateTime.now().millisecondsSinceEpoch;
      _streams[0].add(ScopeChartChannelValue(
        value: sin((radians * pi)) * 1000,
        timestamp: _timestamp,
      ));
      _streams[1].add(ScopeChartChannelValue(
        value: atan((radians * pi)) * 100,
        timestamp: _timestamp,
      ));
      _streams[2].add(ScopeChartChannelValue(
        value: cos((radians * pi)),
        timestamp: _timestamp,
      ));
      _streams[3].add(ScopeChartChannelValue(
        value: 0,
        timestamp: _timestamp,
      ));
      radians += 0.05;
      if (radians >= 2.0) {
        radians = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScopeDynamicViewer(
        timeWindow: const Duration(seconds: 5).inMilliseconds,
        channels: _channels,
        stopped: stop,
        legendData:
            ScopeLegendData(showLegend: true, offset: const Offset(100, 10)),
        // timeAxis: const ScopeAxis(),
      );
}

class StaticScopeSample extends StatefulWidget {
  StaticScopeSample({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _StaticScopeSampleState();
}

class _StaticScopeSampleState extends State<StaticScopeSample> {
  int _min;
  int _max;
  final int _timeWindow = 10000;
  int axisIndex = 0;
  List<ScopeChartStaticChannel> _channels;

  List<ScopeChartChannelValue> _generateValues(
      int count, double min, double max, int startTime, int step) {
    var values = <ScopeChartChannelValue>[];
    var timestamp = startTime;
    final _random = Random();
    for (var i = 0; i < count; i++) {
      final coef = _random.nextDouble();
      final mul = _random.nextInt(max.toInt().abs());
      final delta = (coef * max > 0 ? mul : -mul);
      values.add(ScopeChartChannelValue(
        timestamp: timestamp,
        value: (min + delta).clamp(min, max),
      ));
      timestamp += step;
    }
    return values;
  }

  @override
  void initState() {
    super.initState();
    final _random = Random();
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final endTime = startTime + const Duration(hours: 24).inMilliseconds;
    final count = (endTime - startTime) ~/ 10;
    _min = startTime;
    _max = endTime;
    _channels = [];
    const baseColor = Color(0xFF00000);
    for (var i = 0; i < 1; i++) {
      final min = (1 - _random.nextDouble() * 2) * _random.nextInt(1000);
      final max = min + _random.nextDouble() * _random.nextInt(1000);
      _channels.add(ScopeChartStaticChannel(
        id: 'Channel $i',
        color: Colors.red,
        values: _generateValues(count, min, max, startTime, 10),
        axis: ScopeAxisData(
          grid: ScopeAxisGrid(
            showGrid: true,
            getDrawingLine: (_) => FlLine(
              color: baseColor.withOpacity(0.2),
              strokeWidth: 0.5,
            ),
          ),
          title: ScopeAxisTitle(
            showTitle: true,
            colorize: true,
            titleText: 'Channel $i',
          ),
          titles: const ScopeAxisTitles(
            colorize: true,
            reservedSize: 20,
          ),
          min: min,
          max: max,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => ScopeStaticViewer(
        timeStart: _min,
        timeEnd: _max,
        timeWindow: _timeWindow,
        channels: _channels,
        zoomAreaData: ScopeZoomAreaData(
          min: _min.toDouble(),
          max: _max.toDouble(),
          maxZoom: 10000,
          minZoom: 1000,
          minWidth: 1,
          show: true,
          height: 40,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
          color: Theme.of(context).colorScheme.primary,
          cursor:
              const ScopeCursorData(color: Colors.red, show: true, width: 1),
        ),
        cursorData: const ScopeCursorData(
          color: Colors.black,
          show: true,
          width: 2,
          titlePosition: CursorTitlePosition.top,
        ),
        panEnabled: true,
        scaleEnabled: true,
      );
}
