import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'scope_chart_data.dart';
import 'scope_chart_painter.dart';

/// Low level LineChart Widget.
// class ScopeChartLeaf extends LeafRenderObjectWidget {
//   const ScopeChartLeaf({Key? key, required this.data}) : super(key: key);

//   final ScopeChartData data;

//   @override
//   RenderScopeChart createRenderObject(BuildContext context) =>
//       RenderScopeChart(data, MediaQuery.of(context).textScaleFactor);

//   @override
//   void updateRenderObject(BuildContext context, RenderScopeChart renderObject) {
//     renderObject
//       ..data = data
//       ..textScale = MediaQuery.of(context).textScaleFactor;
//   }
// }

/// Renders our LineChart, also handles hitTest.
class RenderScopeChart extends CustomPainter {
  final ScopeChartData _data;
  final double _textScale;
  RenderScopeChart({
    required ScopeChartData data,
    required double textScale,
  })  : _data = data,
        _textScale = textScale,
        super(repaint: data.channelsData);

  final _painter = ScopeChartPainter();

  ScopePaintHolder get paintHolder => ScopePaintHolder(_data, _textScale);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, 0);
    _painter.paint(CanvasWrapper(canvas, size), paintHolder);
    canvas.restore();
  }
}
