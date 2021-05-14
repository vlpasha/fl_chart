import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
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

class LineChartSample1 extends StatefulWidget {
  @override
  _LineChartSample1State createState() => _LineChartSample1State();
}

class _LineChartSample1State extends State<LineChartSample1> {
  var rnd = Random();
  int timeStep = 100;
  double radians = 0.0;

  int startTime = 0;
  final List<StreamController<ScopeChartChannelValue>> _streams = [
    StreamController(),
    StreamController(),
    StreamController(),
  ];

  List<ScopeChartChannel> _channels;

  @override
  void initState() {
    _channels = [
      ScopeChartChannel(
        show: true,
        color: Colors.red,
        valuesStream: _streams[0].stream,
      ),
      ScopeChartChannel(
        show: true,
        color: Colors.green,
        valuesStream: _streams[1].stream,
      ),
      ScopeChartChannel(
        show: true,
        color: Colors.blue,
        valuesStream: _streams[2].stream,
      ),
    ];

    Timer.periodic(Duration(milliseconds: timeStep), (timer) {
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
        value: cos((radians * pi)) * 500,
        timestamp: _timestamp,
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
    return ScopeChart(
      timeWindow: Duration(seconds: 10).inMilliseconds,
      channels: _channels,
      minY: -1000,
      maxY: 1000,
    );
  }
}
