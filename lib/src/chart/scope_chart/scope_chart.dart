import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';

import 'scope_chart_data.dart';
import 'scope_chart_renderer.dart';

typedef ValueCallback = Future<void> Function(
  ScopeChartChannel channel,
  ScopeChartChannelValue value,
);

class ScopeChartChannelValue {
  final double value;
  final int timestamp;
  ScopeChartChannelValue({
    required this.value,
    required this.timestamp,
  });
}

class ScopeChartChannel {
  final String id;
  final bool show;
  final Color color;
  final double width;
  final ScopeAxis axis;
  final Stream<ScopeChartChannelValue> valuesStream;
  // final List<FlSpot> _spots = [];

  StreamSubscription<ScopeChartChannelValue>? _subscr;

  // List<FlSpot> get spots => _spots;

  ScopeChartChannel({
    required this.id,
    required this.valuesStream,
    required this.color,
    this.width = 2.0,
    this.show = true,
    this.axis = const ScopeAxis(),
  });

  void dispose() {
    _subscr?.cancel();
  }

  void listen(ValueCallback onValue) async {
    await _subscr?.cancel();
    _subscr =
        valuesStream.listen((event) => _subscr!.pause(onValue(this, event)));
  }

  void pause(Future<void> onPause) => _subscr?.pause(onPause);

  void cancel() => _subscr?.cancel();
}

class ScopeChart extends StatefulWidget {
  final int timeWindow;
  final List<ScopeChartChannel> channels;
  final ScopeAxis? timeAxis;
  final ScopeBorderData? borderData;
  final ScopeLegendData? legendData;
  final bool stopped;
  final int channelAxisIndex;
  final Stream<bool> resetSync;
  const ScopeChart({
    Key? key,
    this.timeWindow = 1000,
    this.channels = const [],
    this.timeAxis,
    this.borderData,
    this.legendData,
    this.stopped = false,
    this.channelAxisIndex = 0,
    this.resetSync = const Stream.empty(),
  }) : super(key: key);
  @override
  State<ScopeChart> createState() => _ScopeChartState();
}

class _ScopeChartState extends State<ScopeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ValueNotifier<Iterable<ScopeChannelData>> _channelsData;

  StreamSubscription<bool>? _resetSyncSubscr;
  int _startTime = 0;
  int _elapsedTime = 0;
  int _startTimestamp = 0;

  final _timeAxis = ScopeAxis(
    interval: 1000,
    grid: const ScopeGrid(),
    title: const ScopeAxisTitle(showTitle: false, titleText: 'Bottom Title'),
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
  );
  final Map<String, ScopeChannelData> _channels = {};
  bool _timeSync = false;
  int axisIndex = 0;

  Future<void> _updateSpots(
    ScopeChartChannel channel,
    ScopeChartChannelValue event,
  ) {
    var _channel = _channels[channel.id];
    if (_channel != null && widget.stopped != true) {
      if (_timeSync != true) {
        _startTimestamp = event.timestamp;
        _startTime = DateTime.now().millisecondsSinceEpoch;
        _timeSync = true;
      }

      if (event.timestamp <= _startTimestamp) {
        _startTimestamp = event.timestamp;
        _startTime = DateTime.now().millisecondsSinceEpoch;
      }

      _channel.spots
          .removeWhere((element) => element.x > event.timestamp.toDouble());

      if (_channel.spots.isNotEmpty &&
          (_channel.spots.last.x - _channel.spots.first.x) >
              widget.timeWindow * 2) {
        _channel.spots.removeAt(0);
      }

      _channel.spots.add(FlSpot((event.timestamp).toDouble(), event.value));
      _channel.calculateMaxAxisValues();
    } else {
      channel.cancel();
    }

    if (widget.stopped != true) _channelsData.value = _channels.values;
    return Future.value(null);
  }

  void _updateChannels() {
    if (widget.channels.isEmpty) {
      _channels.clear();
    } else {
      // remove unused
      _channels.removeWhere((key, value) =>
          widget.channels.firstWhereOrNull((ch) => ch.id == key) == null);
      // add new
      for (var channel in widget.channels
          .where((ch) => _channels.containsKey(ch.id) == false)) {
        _channels[channel.id] = ScopeChannelData(
          id: channel.id,
          show: channel.show,
          width: channel.width,
          color: channel.color,
          isCurved: false,
          spots: [],
          axis: channel.axis,
        );
        channel.listen(_updateSpots);
      }
    }
    _channelsData.value = _channels.values;
  }

  @override
  void initState() {
    super.initState();
    _channelsData = ValueNotifier([]);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _resetSyncSubscr = widget.resetSync.listen((event) => setState(() {
          _timeSync = false;
          _startTime = 0;
          _startTimestamp = 0;
          _elapsedTime = 0;
        }));
  }

  @override
  void dispose() {
    for (var channel in widget.channels) {
      channel.cancel();
    }
    _animationController.stop();
    _resetSyncSubscr?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateChannels();
    if (widget.stopped != false) {
      _animationController.stop();
    } else {
      _animationController.repeat();
    }

    final activeChannel = _channels.values.isNotEmpty
        ? _channels.values.elementAt(widget.channelAxisIndex)
        : null;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        var now = 0;
        if (widget.stopped != true) {
          _elapsedTime = DateTime.now().millisecondsSinceEpoch - _startTime;
        } else {
          _timeSync = false;
        }

        if (_timeSync != false) {
          if (_elapsedTime < widget.timeWindow) {
            now = _startTimestamp;
          } else {
            now = _startTimestamp + _elapsedTime - widget.timeWindow;
          }
        }
        return CustomPaint(
          isComplex: true,
          willChange: widget.stopped != true,
          painter: RenderScopeChart(
            data: ScopeChartData(
              stopped: widget.stopped,
              activeChannel: activeChannel,
              borderData: widget.borderData,
              legendData: widget.legendData,
              timeAxis: _timeAxis.copyWith(
                showAxis: widget.timeAxis?.showAxis,
                interval: widget.timeAxis?.interval,
                grid: widget.timeAxis?.grid,
                title: widget.timeAxis?.title,
                titles: widget.timeAxis?.titles,
                min: now.toDouble(),
                max: (now + widget.timeWindow).toDouble(),
              ),
              channelsData: _channelsData,
              clipData: FlClipData.all(),
            ),
            textScale: MediaQuery.of(context).textScaleFactor,
          ),
        );
      },
    );
  }
}
