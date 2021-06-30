// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'scope_chart.dart';
import 'scope_chart_data.dart';

class ScopeInteractionDetails {
  final double timeStart;
  final double timeEnd;
  ScopeInteractionDetails({required this.timeStart, required this.timeEnd});
}

typedef ScopeInteractionCallback = void Function(
    ScopeInteractionDetails details);

class ScopeStaticViewer extends StatefulWidget {
  ScopeStaticViewer({
    Key? key,
    required int timeStart,
    required int timeEnd,
    int timeWindow = 10000,
    int minTimeWindow = 5000,
    this.channels = const [],
    this.borderData,
    this.legendData,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.axisControl = true,
    this.zoomArea,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.onInteractionEnd,
  })  : minTimeWindow = minTimeWindow.toDouble(),
        timeWindow = timeWindow.toDouble(),
        timeStart = timeStart.toDouble(),
        timeEnd = timeEnd.toDouble(),
        super(key: key);

  final double minTimeWindow;
  final double timeWindow;
  final double timeStart;
  final double timeEnd;
  final Iterable<ScopeChartChannel> channels;
  final ScopeBorderData? borderData;
  final ScopeLegendData? legendData;
  final ScopeZoomArea? zoomArea;

  final ScopeInteractionCallback? onInteractionStart;
  final ScopeInteractionCallback? onInteractionUpdate;
  final ScopeInteractionCallback? onInteractionEnd;
  final bool panEnabled;
  final bool scaleEnabled;
  final bool axisControl;

  @override
  State<ScopeStaticViewer> createState() => _ScopeStaticViewerState();
}

class _ScopeStaticViewerState extends State<ScopeStaticViewer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late double _timeWindow;
  late double _prevTimeWindow;
  late double _currentTime;
  //Vertical drag details
  late DragStartDetails startVerticalDragDetails;
  late DragUpdateDetails updateVerticalDragDetails;

  double _scale = 1.0;
  double _pan = 0.0;
  int _axisIndex = 0;
  Animation<double>? _animation;
  _GestureType? _gestureType;

  final GlobalKey _childKey = GlobalKey();

  static const double _kDrag = 0.0000135;
  static const double _kTime = 0.5;

  void _onScale(double scale) {
    final _newTimeWindow = (_prevTimeWindow / scale)
        .roundToDouble()
        .clamp(widget.minTimeWindow, double.infinity);

    if (_newTimeWindow > _timeWindow) {
      _timeWindow += (_newTimeWindow / 50).roundToDouble();
      _currentTime -= (_newTimeWindow / 100).roundToDouble();
    } else {
      _timeWindow -= (_newTimeWindow / 50).roundToDouble();
      _currentTime += (_newTimeWindow / 100).roundToDouble();
    }

    _currentTime = _currentTime.clamp(widget.timeStart, widget.timeEnd);

    if (_currentTime + _timeWindow > widget.timeEnd) {
      _timeWindow = widget.timeEnd - _currentTime;
    }

    if (widget.onInteractionUpdate != null) {
      widget.onInteractionUpdate!(ScopeInteractionDetails(
        timeStart: _currentTime,
        timeEnd: _currentTime + _timeWindow,
      ));
    }

    setState(() {});
  }

  void _onHorizontalDrag(double distance) {
    final scopeWidth = _childKey.currentContext?.size?.width ?? 100.0;
    final interval = _timeWindow / scopeWidth;
    var newTime = (_currentTime - interval * distance)
        .clamp(widget.timeStart, widget.timeEnd);

    if ((newTime + _timeWindow) > widget.timeEnd) {
      newTime = widget.timeEnd - _timeWindow;
    }

    _currentTime = newTime.roundToDouble();

    if (widget.onInteractionUpdate != null) {
      widget.onInteractionUpdate!(ScopeInteractionDetails(
        timeStart: _currentTime,
        timeEnd: _currentTime + _timeWindow,
      ));
    }

    setState(() {});
  }

  // Handle mousewheel scroll events.
  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Ignore left and right scroll.
      if (event.scrollDelta.dy == 0.0) {
        return;
      }

      _prevTimeWindow = _timeWindow;
      // In the Flutter engine, the mousewheel scrollDelta is hardcoded to 20
      // per scroll, while a trackpad scroll can be any amount. The calculation
      // for scaleChange here was arbitrarily chosen to feel natural for both
      // trackpads and mousewheels on all platforms.
      final scaleChange = math.exp(-event.scrollDelta.dy / 100);
      _scale = scaleChange;
      _onScale(scaleChange);
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
      _animation?.removeListener(_onAnimate);
      _animation = null;
    }

    if (details.pointerCount > 1) {
      _prevTimeWindow = _timeWindow;
      _gestureType = _GestureType.scale;
    } else {
      _gestureType = _GestureType.vertical;
    }

    if (widget.onInteractionStart != null) {
      widget.onInteractionStart!(ScopeInteractionDetails(
        timeStart: _currentTime,
        timeEnd: _currentTime + _timeWindow,
      ));
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_gestureType == _GestureType.scale && (details.scale - 1).abs() > 0) {
      _scale = details.scale;
      _onScale(_scale);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_gestureType == _GestureType.vertical) {
      if (details.velocity.pixelsPerSecond.distance > kMinFlingVelocity) {
        if (details.velocity.pixelsPerSecond.dy > 0) {
          _nextAxis(widget.channels.length);
        } else {
          _prevAxis(widget.channels.length);
        }
      }
    }

    _animation?.removeListener(_onAnimate);
    _animationController.reset();
    _gestureType = null;
    _scale = 1.0;
    if (widget.onInteractionEnd != null) {
      widget.onInteractionEnd!(ScopeInteractionDetails(
        timeStart: _currentTime,
        timeEnd: _currentTime + _timeWindow,
      ));
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
      _animation?.removeListener(_onAnimate);
      _animation = null;
    }

    _gestureType = null;
    _pan = 0.0;

    if (widget.onInteractionStart != null) {
      widget.onInteractionStart!(ScopeInteractionDetails(
        timeStart: _currentTime,
        timeEnd: _currentTime + _timeWindow,
      ));
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if ((_pan - details.primaryDelta!).abs() > 0.1) {
      _gestureType = _GestureType.horizontal;
      _pan = details.primaryDelta!;
      _onHorizontalDrag(_pan);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _pan = 0.0;

    if (details.velocity.pixelsPerSecond.distance < kMinFlingVelocity ||
        (_pan > 0 && details.velocity.pixelsPerSecond.dx < 0) ||
        (_pan < 0 && details.velocity.pixelsPerSecond.dx > 0)) {
      _gestureType = null;
      if (widget.onInteractionEnd != null) {
        widget.onInteractionEnd!(ScopeInteractionDetails(
          timeStart: _currentTime,
          timeEnd: _currentTime + _timeWindow,
        ));
      }
    } else {
      final frictionSimulationX = FrictionSimulation(
        _kDrag,
        0.0,
        details.velocity.pixelsPerSecond.dx,
      );
      final tFinal = _getFinalTime(
        details.velocity.pixelsPerSecond.distance,
        _kDrag,
      );
      _animation = Tween<double>(
        begin: _pan,
        end: frictionSimulationX.finalX,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ));
      _animationController.duration =
          Duration(milliseconds: (tFinal * 1000).round());
      _animation!.addListener(_onAnimate);
      _animationController.forward();
    }
  }

  void _onAnimate() {
    if (!_animationController.isAnimating) {
      _animation?.removeListener(_onAnimate);
      _animation = null;
      _animationController.reset();
      _gestureType = null;
      _pan = 0.0;

      if (widget.onInteractionEnd != null) {
        widget.onInteractionEnd!(ScopeInteractionDetails(
          timeStart: _currentTime,
          timeEnd: _currentTime + _timeWindow,
        ));
      }
      return;
    }

    switch (_gestureType) {
      case _GestureType.horizontal:
        {
          final distance = _animation?.value != null ? _animation!.value : 0.0;
          _onHorizontalDrag(distance * _kTime);
        }
        break;
      default:
        break;
    }

    setState(() {});
  }

  void _nextAxis(int maxAxes) {
    setState(
        () => _axisIndex = _axisIndex < (maxAxes - 1) ? _axisIndex + 1 : 0);
  }

  void _prevAxis(int maxAxes) {
    setState(
        () => _axisIndex = _axisIndex > 0 ? _axisIndex - 1 : (maxAxes - 1));
  }

  double _getFinalTime(double velocity, double drag) {
    const effectivelyMotionless = 10.0;
    return math.log(effectivelyMotionless / velocity) / math.log(drag / 100);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _timeWindow = widget.timeWindow;
    _currentTime = widget.timeStart;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerSignal: _receivedPointerSignal,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.start,
          onScaleEnd: _onScaleEnd,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          // onVerticalDragStart: _onVerticalDragStart,
          // onVerticalDragUpdate: _onVerticalDragUpdate,
          // onVerticalDragEnd: _onVerticalDragEnd,
          child: Stack(fit: StackFit.expand, children: [
            ScopeChart(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 6),
              key: _childKey,
              channels: widget.channels,
              realTime: false,
              timeAxis: ScopeAxis(
                min: _currentTime,
                max: _currentTime + _timeWindow,
                grid: ScopeGrid(
                  getDrawingLine: (_) => FlLine(
                    color: Colors.red.withOpacity(0.2),
                    strokeWidth: 0.5,
                  ),
                ),
                titles: ScopeAxisTitles(
                  textStyle: Theme.of(context).textTheme.caption,
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
              borderData: widget.borderData,
              legendData: widget.legendData,
              channelAxisIndex: _axisIndex,
              zoomArea: ScopeZoomArea(
                      show: true,
                      height: 10,
                      min: widget.timeStart,
                      max: widget.timeEnd,
                      zoomStart: _currentTime,
                      zoomEnd: _currentTime + _timeWindow,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      cursorColor: Colors.blue,
                      minWidth: 1.0)
                  .copyWith(
                backgroundColor: widget.zoomArea?.backgroundColor,
                cursorColor: widget.zoomArea?.cursorColor,
                show: widget.zoomArea?.show,
                height: widget.zoomArea?.height,
              ),
            ),
            if (widget.axisControl)
              Positioned(
                bottom: 0,
                left: 0,
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(maxWidth: 24),
                      padding: EdgeInsets.zero,
                      color: Colors.blueAccent,
                      splashRadius: 12.0,
                      icon: const Icon(Icons.arrow_left),
                      iconSize: 24,
                      onPressed: () => _prevAxis(widget.channels.length),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(maxWidth: 24),
                      padding: EdgeInsets.zero,
                      color: Colors.blueAccent,
                      splashRadius: 12.0,
                      icon: const Icon(Icons.arrow_right),
                      iconSize: 24,
                      onPressed: () => _nextAxis(widget.channels.length),
                    ),
                  ],
                ),
              ),
          ]),
        ),
      );
}

enum _GestureType { scale, horizontal, vertical }
