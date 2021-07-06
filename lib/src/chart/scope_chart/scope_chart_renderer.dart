import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'common/scope_channel.dart';
import 'common/scope_legend.dart';
import 'scope_chart_data.dart';
import 'scope_chart_painter.dart';

class ScopeChartLeaf extends LeafRenderObjectWidget {
  const ScopeChartLeaf({
    Key? key,
    required this.data,
    this.onMouseScroll,
    this.onPointerDown,
    this.onPointerUp,
  }) : super(key: key);

  final ScopeChartData data;
  final ValueSetter<ScopePointerEvent>? onMouseScroll;
  final ValueSetter<ScopePointerEvent>? onPointerDown;
  final ValueSetter<ScopePointerEvent>? onPointerUp;

  @override
  ScopeChartLeafRenderer createRenderObject(BuildContext context) =>
      ScopeChartLeafRenderer(
          onMouseScroll: onMouseScroll,
          onPointerDown: onPointerDown,
          onPointerUp: onPointerUp,
          data: data,
          textScale: MediaQuery.of(context).textScaleFactor);

  @override
  void updateRenderObject(
      BuildContext context, ScopeChartLeafRenderer renderObject) {
    renderObject
      ..data = data
      ..textScale = MediaQuery.of(context).textScaleFactor
      ..onMouseScroll = onMouseScroll
      ..onPointerDown = onPointerDown
      ..onPointerUp = onPointerUp;
  }
}

class ScopeChartLeafRenderer extends RenderBox {
  ValueSetter<ScopePointerEvent>? onMouseScroll;
  ValueSetter<ScopePointerEvent>? onPointerDown;
  ValueSetter<ScopePointerEvent>? onPointerUp;
  ScopeChartData _data;
  double _textScale;
  ScopeChartLeafRenderer({
    required ScopeChartData data,
    required double textScale,
    this.onMouseScroll,
    this.onPointerDown,
    this.onPointerUp,
  })  : _data = data,
        _textScale = textScale;

  final _painter = ScopeChartPainter();
  ScopePaintHolder get paintHolder => ScopePaintHolder(_data, _textScale);

  ScopeChartData get data => _data;
  set data(ScopeChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  double get textScale => _textScale;
  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    markNeedsPaint();
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
    canvas.translate(0, 0);
    _painter.paint(CanvasWrapper(canvas, size), paintHolder);
    canvas.restore();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    final target = _painter.getTouchedElement(event);
    if (event is PointerScrollEvent && onMouseScroll != null) {
      onMouseScroll!(ScopePointerEvent(
        event: event,
        target: target,
        chartRect: _painter.chartRect,
        zoomRect: _painter.zoomRect,
      ));
    }
    if (event is PointerDownEvent && onPointerDown != null) {
      onPointerDown!(ScopePointerEvent(
        event: event,
        target: target,
        chartRect: _painter.chartRect,
        zoomRect: _painter.zoomRect,
      ));
    }
    if (event is PointerUpEvent && onPointerUp != null) {
      onPointerUp!(ScopePointerEvent(
        event: event,
        target: target,
        chartRect: _painter.chartRect,
        zoomRect: _painter.zoomRect,
      ));
    }
  }
}
