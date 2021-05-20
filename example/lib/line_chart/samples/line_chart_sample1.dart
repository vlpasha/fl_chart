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

class LineChartSample1 extends StatelessWidget {
  @override
  Widget build(context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [Expanded(child: ScopeChartSample()), Expanded(child: LineChartSample())],
      );
}

class ScopeChartSample extends StatefulWidget {
  @override
  _ScopeChartSampleState createState() => _ScopeChartSampleState();
}

class _ScopeChartSampleState extends State<ScopeChartSample> {
  var rnd = Random();
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
    _channels = [
      ScopeChartChannel(
        id: '0',
        show: true,
        color: Colors.red,
        valuesStream: _streams[0].stream,
        axis: const ScopeAxis(
          title: ScopeAxisTitle(showTitle: true, titleText: 'sin'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartChannel(
        id: '1',
        show: true,
        color: Colors.green,
        valuesStream: _streams[1].stream,
        axis: const ScopeAxis(
          title: ScopeAxisTitle(showTitle: true, titleText: 'atan'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartChannel(
        id: '2',
        show: true,
        color: Colors.blue,
        valuesStream: _streams[2].stream,
        axis: const ScopeAxis(
          title: ScopeAxisTitle(showTitle: true, titleText: 'cos'),
          titles: ScopeAxisTitles(reservedSize: 50),
        ),
      ),
      ScopeChartChannel(
        id: '3',
        show: true,
        color: Colors.blue,
        valuesStream: _streams[3].stream,
        axis: const ScopeAxis(
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
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: () {
          setState(() => stop = !stop);
        },
        onTap: () {
          setState(() => axisIndex < (_channels.length - 1) ? axisIndex++ : axisIndex = 0);
        },
        child: ScopeChart(
          timeWindow: const Duration(seconds: 5).inMilliseconds,
          channels: _channels,
          channelAxisIndex: axisIndex,
          stopped: stop,
          // timeAxis: const ScopeAxis(),
        ));
  }
}

class LineChartSample extends StatefulWidget {
  LineChartSample({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<FlSpot> _cos(int cunt, double phase) {
    var radians = 0.0;
    var values = <FlSpot>[];
    for (var i = 0; i < cunt; i++) {
      values.add(FlSpot(i.toDouble(), cos(radians * pi + phase)));
      radians += 0.05;
      if (radians > 2.0) radians = 0;
    }
    return values;
  }

  List<FlSpot> _sin(int cunt, double phase) {
    var radians = 0.0;
    var values = <FlSpot>[];
    for (var i = 0; i < cunt; i++) {
      values.add(FlSpot(i.toDouble(), sin(radians * pi + phase)));
      radians += 0.05;
      if (radians > 2.0) radians = 0;
    }
    return values;
  }

  @override
  Widget build(context) => LineChart(LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => value.toStringAsFixed(0),
          ),
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitles: (value) => value.toStringAsFixed(0),
          ),
        ),
        lineTouchData: LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [..._cos(100, 0), FlSpot.nullSpot, ..._cos(100, 1)],
            isCurved: false,
            isStepLineChart: false,
            colors: [Colors.red],
            barWidth: 2,
            isStrokeCapRound: false,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [..._sin(100, 0)],
            isCurved: false,
            isStepLineChart: false,
            colors: [Colors.green],
            barWidth: 2,
            isStrokeCapRound: false,
            dotData: FlDotData(show: false),
          ),
        ],
      ));
}
