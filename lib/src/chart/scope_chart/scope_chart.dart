import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';

import 'common/scope_axis.dart';
import 'common/scope_border.dart';
import 'common/scope_channel.dart';
import 'common/scope_cursor.dart';
import 'common/scope_legend.dart';
import 'common/scope_zoom_area.dart';
import 'scope_chart_data.dart';
import 'scope_chart_renderer.dart';

typedef ValueCallback = Future<void> Function(
  ScopeChartDynamicChannel channel,
  ScopeChartChannelValue value,
);

class ScopeChartChannelValue {
  final double value;
  final int timestamp;
  final bool sync;
  ScopeChartChannelValue({
    required this.value,
    required this.timestamp,
    this.sync = false,
  });
}

abstract class ScopeChartChannel {
  final String id;
  final bool show;
  final Color color;
  final double width;
  final ScopeAxisData axis;
  ScopeChartChannel({
    required this.id,
    required this.color,
    double? width,
    bool? show,
    ScopeAxisData? axis,
  })  : width = width ?? 2.0,
        show = show ?? true,
        axis = axis ?? const ScopeAxisData();
}

class ScopeChartDynamicChannel extends ScopeChartChannel {
  final Stream<ScopeChartChannelValue> valuesStream;
  StreamSubscription<ScopeChartChannelValue>? _subscr;

  ScopeChartDynamicChannel({
    required String id,
    required Color color,
    required this.valuesStream,
    double? width,
    bool? show,
    ScopeAxisData? axis,
  }) : super(
          color: color,
          id: id,
          axis: axis,
          show: show,
          width: width,
        );

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

class ScopeChartStaticChannel extends ScopeChartChannel {
  final Iterable<ScopeChartChannelValue> values;

  ScopeChartStaticChannel({
    required String id,
    required Color color,
    required this.values,
    double? width,
    bool? show,
    ScopeAxisData? axis,
  }) : super(
          color: color,
          id: id,
          axis: axis,
          show: show,
          width: width,
        );

  ListQueue<FlSpot> get spots => ListQueue.from(
      values.map((item) => FlSpot(item.timestamp.toDouble(), item.value)));

  ListQueue<FlSpot> getSpotsRange(int start, int end) => ListQueue.from(values
      .where((item) => item.timestamp > start && item.timestamp < end)
      .map((item) => FlSpot(item.timestamp.toDouble(), item.value)));

  int get minTime => values
      .reduce((value, element) =>
          element.timestamp < value.timestamp ? element : value)
      .timestamp;
  int get maxTime => values
      .reduce((value, element) =>
          element.timestamp > value.timestamp ? element : value)
      .timestamp;
}

class ScopeChart extends StatefulWidget {
  final GlobalKey? painterKey;
  final EdgeInsets padding;
  final int timeWindow;
  final Iterable<ScopeChartChannel> channels;
  final bool realTime;
  final ScopeAxisData? timeAxis;
  final ScopeBorderData? borderData;
  final ScopeLegendData? legendData;
  final ScopeCursorData? cursorData;
  final ScopeZoomAreaData? zoomAreaData;
  final double? cursorValue;

  final bool stopped;
  final bool reset;
  final int channelAxisIndex;
  final Stream<bool>? resetStream;

  final ScopeGestureCallback? onGestureStart;
  final ScopeGestureCallback? onGestureUpdate;
  final ScopeGestureCallback? onGestureEnd;

  final ScopeGestureCallback? onMouseScroll;
  final ScopeGestureCallback? onTap;
  final ScopeGestureCallback? onScaleStart;
  final ScopeGestureCallback? onScaleUpdate;
  final ScopeGestureCallback? onScaleEnd;
  final ScopeGestureCallback? onHorizontalDragStart;
  final ScopeGestureCallback? onHorizontalDragUpdate;
  final ScopeGestureCallback? onHorizontalDragEnd;
  const ScopeChart({
    Key? key,
    this.painterKey,
    this.padding = const EdgeInsets.all(0),
    this.timeWindow = 1000,
    this.channels = const [],
    this.realTime = true,
    this.timeAxis,
    this.zoomAreaData,
    this.cursorData,
    this.borderData,
    this.legendData,
    this.stopped = false,
    this.channelAxisIndex = 0,
    this.cursorValue,
    this.reset = false,
    this.resetStream,
    this.onGestureStart,
    this.onGestureUpdate,
    this.onGestureEnd,
    this.onTap,
    this.onMouseScroll,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  }) : super(key: key);
  @override
  State<ScopeChart> createState() => _ScopeChartState();
}

class _ScopeChartState extends State<ScopeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  StreamSubscription<bool>? _resetSyncSubscr;
  int _startTime = 0;
  int _elapsedTime = 0;
  int _startTimestamp = 0;
  ScopePointerEvent? _lastEvent;

  final _timeAxis = ScopeAxisData(
    interval: 1000,
    grid: const ScopeAxisGrid(),
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

  Future<void> _onData(
    ScopeChartDynamicChannel channel,
    ScopeChartChannelValue event,
  ) {
    var _channel = _channels[channel.id];
    if (_channel == null) {
      channel.cancel();
    } else if (widget.stopped != true) {
      if (_timeSync != true ||
          event.timestamp <= _startTimestamp ||
          event.sync) {
        _channel.spots
            .removeWhere((element) => element.x > event.timestamp.toDouble());

        _startTimestamp = event.timestamp;
        _startTime = DateTime.now().millisecondsSinceEpoch;
        _timeSync = true;
      }

      if (_channel.spots.isNotEmpty &&
          ((_channel.spots.last.x - _channel.spots.first.x) >
              widget.timeWindow)) {
        _channel.spots.removeFirst();
      }

      _channel.spots.addLast(FlSpot((event.timestamp).toDouble(), event.value));

      _channel.calculateMaxAxisValues();
    }

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
        if (!widget.realTime && channel is ScopeChartDynamicChannel) {
          throw Exception(
              'Dynamic channels not allowed when scope is not in real time mode');
        }
        if (widget.realTime && channel is ScopeChartStaticChannel) {
          throw Exception(
              'Static channels not allowed when scope is in real time mode');
        }

        if (channel is ScopeChartStaticChannel) {
          _channels[channel.id] = ScopeChannelData(
            id: channel.id,
            show: channel.show,
            width: channel.width,
            color: channel.color,
            isCurved: false,
            spots: channel.spots,
            axis: channel.axis,
          );
        } else if (channel is ScopeChartDynamicChannel) {
          _channels[channel.id] = ScopeChannelData(
            id: channel.id,
            show: channel.show,
            width: channel.width,
            color: channel.color,
            isCurved: false,
            spots: ListQueue(),
            axis: channel.axis,
          );
          channel.listen(_onData);
        } else {
          throw Exception('Unknown channel type');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _resetSyncSubscr = widget.resetStream?.listen((event) => setState(() {
          _timeSync = false;
          _startTime = 0;
          _startTimestamp = 0;
          _elapsedTime = 0;
        }));
  }

  @override
  void didUpdateWidget(ScopeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final oldChannel in oldWidget.channels) {
      if (oldChannel is ScopeChartDynamicChannel) {
        oldChannel.cancel();
      }
    }

    if (widget.realTime) {
      for (final newChannel in widget.channels) {
        if (newChannel is! ScopeChartDynamicChannel) {
          throw Exception(
              'Static channels not allowed when scope is in real time mode');
        }
        newChannel.listen(_onData);
      }
    }

    _resetSyncSubscr?.cancel();
    _resetSyncSubscr = widget.resetStream?.listen(
      (event) => setState(
        () {
          _timeSync = false;
          _startTime = 0;
          _startTimestamp = 0;
          _elapsedTime = 0;
        },
      ),
    );

    if (oldWidget.reset == false && widget.reset == true) {
      _timeSync = false;
      _startTime = 0;
      _startTimestamp = 0;
      _elapsedTime = 0;
    }
  }

  @override
  void dispose() {
    for (var channel in widget.channels) {
      if (channel is ScopeChartDynamicChannel) {
        channel.cancel();
      }
    }
    _animationController.dispose();
    _resetSyncSubscr?.cancel();
    super.dispose();
  }

  Widget _realTimeScope(context) {
    final _textScale = MediaQuery.of(context).textScaleFactor;

    if (widget.stopped) {
      _animationController.stop();
    } else if (!_animationController.isAnimating) {
      _animationController.repeat();
    }

    final activeChannelId = widget.channelAxisIndex < widget.channels.length
        ? widget.channels.elementAt(widget.channelAxisIndex).id
        : null;
    final activeChannel =
        activeChannelId != null ? _channels[activeChannelId] : null;

    return RepaintBoundary(
        child: AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        var now = 0;
        if (widget.stopped != true) {
          _elapsedTime = DateTime.now().millisecondsSinceEpoch - _startTime;
        }

        if (_timeSync != false) {
          if (_elapsedTime < widget.timeWindow) {
            now = _startTimestamp;
          } else {
            now = _startTimestamp + _elapsedTime - widget.timeWindow;
          }
        }

        return ScopeChartLeaf(
          data: ScopeChartData(
            stopped: widget.stopped,
            activeChannel: activeChannel,
            borderData: widget.borderData,
            zoomAreaData: widget.zoomAreaData,
            timeAxis: _timeAxis.copyWith(
              showAxis: widget.timeAxis?.showAxis,
              interval: widget.timeAxis?.interval,
              grid: widget.timeAxis?.grid,
              title: widget.timeAxis?.title,
              titles: widget.timeAxis?.titles,
              min: now.toDouble(),
              max: (now + widget.timeWindow).toDouble(),
            ),
            channelsData: _channels.values,
            clipData: FlClipData.all(),
          ),
        );
      },
    ));
  }

  Widget _staticScope(BuildContext context) {
    final activeChannelId = widget.channelAxisIndex < widget.channels.length
        ? widget.channels.elementAt(widget.channelAxisIndex).id
        : null;
    final activeChannel =
        activeChannelId != null ? _channels[activeChannelId] : null;

    return RepaintBoundary(
      child: ScopeChartLeaf(
        onMouseScroll: widget.onMouseScroll != null
            ? (event) => widget.onMouseScroll!(pointerEvent: event)
            : null,
        onPointerUp: (event) {},
        onPointerDown: (event) => _lastEvent = event,
        data: ScopeChartData(
          stopped: widget.stopped,
          activeChannel: activeChannel,
          borderData: widget.borderData,
          zoomAreaData: widget.zoomAreaData,
          timeAxis: _timeAxis.copyWith(
            showAxis: widget.timeAxis?.showAxis,
            interval: widget.timeAxis?.interval,
            grid: widget.timeAxis?.grid,
            title: widget.timeAxis?.title,
            titles: widget.timeAxis?.titles,
            min: widget.timeAxis?.min,
            max: widget.timeAxis?.max,
          ),
          channelsData: _channels.values,
          clipData: FlClipData.all(),
          cursorData: widget.cursorData,
          cursorValue: widget.cursorValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateChannels();

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.start,
        onTap: widget.onTap != null
            ? () {
                widget.onTap!(pointerEvent: _lastEvent);
                _lastEvent = null;
              }
            : () => _lastEvent = null,
        onScaleStart: widget.onScaleStart != null
            ? (details) =>
                widget.onScaleStart!(pointerEvent: _lastEvent, details: details)
            : null,
        onScaleUpdate: widget.onScaleUpdate != null
            ? (details) => widget.onScaleUpdate!(
                pointerEvent: _lastEvent, details: details)
            : null,
        onScaleEnd: widget.onScaleEnd != null
            ? (details) {
                widget.onScaleEnd!(pointerEvent: _lastEvent, details: details);
                _lastEvent = null;
              }
            : (_) => _lastEvent = null,
        onHorizontalDragStart: widget.onHorizontalDragStart != null
            ? (details) => widget.onHorizontalDragStart!(
                pointerEvent: _lastEvent, details: details)
            : null,
        onHorizontalDragUpdate: widget.onHorizontalDragUpdate != null
            ? (details) => widget.onHorizontalDragUpdate!(
                pointerEvent: _lastEvent, details: details)
            : null,
        onHorizontalDragEnd: widget.onHorizontalDragEnd != null
            ? (details) {
                widget.onHorizontalDragEnd!(
                    pointerEvent: _lastEvent, details: details);
                _lastEvent = null;
              }
            : (_) => _lastEvent = null,
        child: Padding(
          padding: widget.padding,
          child:
              widget.realTime ? _realTimeScope(context) : _staticScope(context),
        ));
  }
}
