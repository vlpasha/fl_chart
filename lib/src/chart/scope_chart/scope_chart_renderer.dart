import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'scope_chart_data.dart';
import 'scope_chart_painter.dart';

/// Low level LineChart Widget.
class ScopeChartLeaf extends LeafRenderObjectWidget {
  const ScopeChartLeaf({Key? key, required this.data, required this.targetData}) : super(key: key);

  final ScopeChartData data, targetData;

  @override
  RenderScopeChart createRenderObject(BuildContext context) =>
      RenderScopeChart(data, targetData, MediaQuery.of(context).textScaleFactor);

  @override
  void updateRenderObject(BuildContext context, RenderScopeChart renderObject) {
    renderObject
      ..data = data
      ..targetData = targetData
      ..textScale = MediaQuery.of(context).textScaleFactor;
  }
}

/// Renders our LineChart, also handles hitTest.
class RenderScopeChart extends RenderBox {
  RenderScopeChart(ScopeChartData data, ScopeChartData targetData, double textScale)
      : _data = data,
        _targetData = targetData,
        _textScale = textScale;

  ScopeChartData get data => _data;
  ScopeChartData _data;
  set data(ScopeChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  ScopeChartData get targetData => _targetData;
  ScopeChartData _targetData;
  set targetData(ScopeChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    markNeedsPaint();
  }

  double get textScale => _textScale;
  double _textScale;
  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    markNeedsPaint();
  }

  final _painter = ScopeChartPainter();

  PaintHolder<ScopeChartData> get paintHolder {
    return PaintHolder(data, targetData, textScale);
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _painter.paint(CanvasWrapper(canvas, size), paintHolder);
    canvas.restore();
  }
}
