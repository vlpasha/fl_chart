// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'common/scope_axis.dart';
import 'common/scope_border.dart';
import 'common/scope_legend.dart';
import 'scope_chart.dart';
import 'scope_chart_data.dart';

class ScopeDynamicViewer extends StatefulWidget {
  const ScopeDynamicViewer({
    Key? key,
    this.timeWindow = 10000,
    this.channels = const [],
    this.borderData,
    this.legendData,
    this.timeAxis,
    this.resetStream,
    this.axisControl = true,
    this.stopped = false,
    this.reset = false,
  }) : super(key: key);

  final int timeWindow;
  final Iterable<ScopeChartChannel> channels;
  final ScopeBorderData? borderData;
  final ScopeLegendData? legendData;
  final ScopeAxisData? timeAxis;
  final Stream<bool>? resetStream;
  final bool stopped;
  final bool reset;
  final bool axisControl;

  @override
  State<ScopeDynamicViewer> createState() => _ScopeDynamicViewerState();
}

class _ScopeDynamicViewerState extends State<ScopeDynamicViewer>
    with TickerProviderStateMixin {
  int _axisIndex = 0;
  bool _verticalDrag = false;
  bool _stopped = false;

  void _onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 1) {
      _verticalDrag = true;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_verticalDrag) {
      _verticalDrag = false;
      if (details.velocity.pixelsPerSecond.distance > kMinFlingVelocity) {
        if (details.velocity.pixelsPerSecond.dy > 0) {
          _nextAxis(widget.channels.length);
        } else {
          _prevAxis(widget.channels.length);
        }
      }
    }
  }

  void _nextAxis(int maxAxes) {
    setState(
        () => _axisIndex = _axisIndex < (maxAxes - 1) ? _axisIndex + 1 : 0);
  }

  void _prevAxis(int maxAxes) {
    setState(
        () => _axisIndex = _axisIndex > 0 ? _axisIndex - 1 : (maxAxes - 1));
  }

  @override
  void initState() {
    super.initState();
    _stopped = widget.stopped;
  }

  @override
  void didUpdateWidget(ScopeDynamicViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _stopped = widget.stopped;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onScaleEnd: _onScaleEnd,
        onScaleStart: _onScaleStart,
        onTap: () => setState(() => _stopped = !_stopped),
        child: Stack(fit: StackFit.expand, children: [
          ScopeChart(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 6),
            channels: widget.channels,
            timeWindow: widget.timeWindow,
            realTime: true,
            stopped: _stopped,
            resetStream: widget.resetStream,
            reset: widget.reset,
            timeAxis: widget.timeAxis,
            borderData: widget.borderData,
            legendData: widget.legendData,
            channelAxisIndex: _axisIndex,
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
      );
}
