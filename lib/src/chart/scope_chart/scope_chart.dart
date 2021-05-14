import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';

import 'scope_chart_data.dart';
import 'scope_chart_renderer.dart';

class ScopeChartChannelValue {
  final double value;
  final int timestamp;
  ScopeChartChannelValue({required this.value, required this.timestamp});
}

class ScopeChartChannel {
  final bool show;
  final Color color;
  final double width;
  final Stream<ScopeChartChannelValue> valuesStream;
  final List<FlSpot> _spots = [];

  late StreamSubscription<ScopeChartChannelValue> _subscr;

  List<FlSpot> get spots => _spots;

  ScopeChartChannel({
    required this.valuesStream,
    required this.color,
    this.width = 2.0,
    this.show = true,
  });

  void addSpot(FlSpot value) => _spots.add(value);
  void removeSpot(int index) => _spots.removeAt(index);
  void listen(
      Future<void> Function(
    ScopeChartChannel channel,
    ScopeChartChannelValue value,
  )
          onValue) {
    _subscr = valuesStream.listen((event) => _subscr.pause(onValue(this, event)));
  }

  void cancel() => _subscr.cancel();
}

class ScopeChart extends StatefulWidget {
  final int timeWindow;
  final List<ScopeChartChannel> channels;
  final ScopeAxesData? axes;
  final double? minY;
  final double? maxY;
  const ScopeChart({
    Key? key,
    int? timeWindow,
    List<ScopeChartChannel>? channels,
    ScopeAxesData? axes,
    double? minY,
    double? maxY,
  })  : timeWindow = timeWindow ?? 1000,
        channels = channels ?? const [],
        axes = axes,
        minY = minY,
        maxY = maxY,
        super(key: key);
  @override
  State<ScopeChart> createState() => _ScopeChartState();
}

class _ScopeChartState extends State<ScopeChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late int _startTime;
  final _axesData = ScopeAxesData(
    vertical: ScopeAxis(
      showAxis: true,
      grid: ScopeGrid(),
      title: ScopeAxisTitle(showTitle: false, titleText: 'Left Title'),
      titles: ScopeAxisTitles(
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
      titles: ScopeAxisTitles(
        showTitles: true,
        getTitles: (value) {
          var seconds = ((value ~/ 1000) % 60),
              minutes = ((value ~/ (1000 * 60)) % 60),
              hours = ((value ~/ (1000 * 60 * 60)) % 24);
          return '${value < 0 ? "-" : ""}'
              '${hours.toString().padLeft(2, '0')}:'
              '${minutes.toString().padLeft(2, '0')}:'
              '${seconds.toString().padLeft(2, '0')}';
        },
      ),
    ),
  );

  Future<void> _updateSpots(ScopeChartChannel channel, ScopeChartChannelValue event) {
    if (channel.spots.isNotEmpty &&
        channel.spots.length > 2 &&
        (channel.spots.last.x - channel.spots.first.x) > widget.timeWindow) {
      channel.removeSpot(0);
    }
    channel.addSpot(
      FlSpot(
        (event.timestamp - _startTime).toDouble(),
        event.value,
      ),
    );
    return Future.value(null);
  }

  @override
  void initState() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    widget.channels.forEach((channel) => channel.listen(_updateSpots));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    widget.channels.forEach((channel) => channel.cancel());
    _animationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) {
          final now = DateTime.now().millisecondsSinceEpoch - _startTime;
          return CustomPaint(
            painter: RenderScopeChart(
              ScopeChartData(
                axesData: _axesData.copyWith(
                  horizontal: widget.axes?.horizontal,
                  vertical: widget.axes?.vertical,
                ),
                channelsData: widget.channels
                    .map((e) => ScopeChannelData(
                          show: e.show,
                          barWidth: e.width,
                          color: e.color,
                          isCurved: false,
                          spots: e.spots,
                        ))
                    .toList(),
                clipData: FlClipData.all(),
                minX: (now - widget.timeWindow).toDouble(),
                maxX: now.toDouble(),
                minY: widget.minY,
                maxY: widget.maxY,
              ),
              MediaQuery.of(context).textScaleFactor,
            ),
          );
        },
      );
}
