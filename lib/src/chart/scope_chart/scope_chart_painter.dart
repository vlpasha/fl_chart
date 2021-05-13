import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../base/axis_chart/axis_chart_data.dart';
import '../../extensions/canvas_extension.dart';
import '../../extensions/paint_extension.dart';
import '../../utils/canvas_wrapper.dart';
import '../../../fl_chart.dart';
import '../../utils/utils.dart' as utils;
import 'scope_chart_data.dart';

class ScopePaintHolder {
  final ScopeChartData data;
  final double textScale;
  ScopePaintHolder(this.data, this.textScale);
}

class ScopeChartPainter {
  late Paint _borderPaint;
  late Paint _backgroundPaint;
  late Paint _axesPaint;
  late Paint _barPaint;

  ScopeChartPainter() : super() {
    _borderPaint = Paint()..style = PaintingStyle.stroke;
    _backgroundPaint = Paint()..style = PaintingStyle.fill;
    _axesPaint = Paint()..style = PaintingStyle.stroke;
    _barPaint = Paint()..style = PaintingStyle.stroke;
  }

  void paint(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    final data = holder.data;
    if (data.clipData.any) {
      canvasWrapper.saveLayer(
        Rect.fromLTWH(0, -40, canvasWrapper.size.width + 40, canvasWrapper.size.height + 40),
        Paint(),
      );

      _clipToBorder(canvasWrapper, holder);
    }

    for (var i = 0; i < data.lineBarsData.length; i++) {
      final barData = data.lineBarsData[i];
      if (!barData.show) continue;
      _drawBarLine(canvasWrapper, barData, holder);
    }

    if (data.clipData.any) {
      canvasWrapper.restore();
    }

    _drawBackground(canvasWrapper, holder);
    _drawViewBorder(canvasWrapper, holder);
    _drawAxes(canvasWrapper, holder);
  }

  void _clipToBorder(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    final data = holder.data;
    final size = canvasWrapper.size;
    final clip = data.clipData;
    final usableSize = _getChartUsableDrawSize(size, holder);
    final border = data.borderData.showBorder ? data.borderData.border : null;

    var left = 0.0;
    var top = 0.0;
    var right = size.width;
    var bottom = size.height;

    if (clip.left) {
      final borderWidth = border?.left.width ?? 0;
      left = _getLeftOffsetDrawSize(holder) - (borderWidth / 2);
    }
    if (clip.top) {
      final borderWidth = border?.top.width ?? 0;
      top = -(borderWidth / 2);
    }
    if (clip.right) {
      final borderWidth = border?.right.width ?? 0;
      right = _getLeftOffsetDrawSize(holder) + usableSize.width + (borderWidth / 2);
    }
    if (clip.bottom) {
      final borderWidth = border?.bottom.width ?? 0;
      bottom = usableSize.height + (borderWidth / 2);
    }

    canvasWrapper.clipRect(Rect.fromLTRB(left, top, right, bottom));
  }

  void _drawBackground(
    CanvasWrapper canvasWrapper,
    ScopePaintHolder holder,
  ) {
    final data = holder.data;
    if (data.backgroundColor.opacity == 0.0) {
      return;
    }

    final viewSize = canvasWrapper.size;
    final usableViewSize = _getChartUsableDrawSize(viewSize, holder);
    _backgroundPaint.color = data.backgroundColor;
    canvasWrapper.drawRect(
      Rect.fromLTWH(
        _getLeftOffsetDrawSize(holder),
        0.0,
        usableViewSize.width,
        usableViewSize.height,
      ),
      _backgroundPaint,
    );
  }

  void _drawViewBorder(
    CanvasWrapper canvasWrapper,
    ScopePaintHolder holder,
  ) {
    var borderData = holder.data.borderData;
    if (borderData.showBorder != true) {
      return;
    }

    final viewSize = canvasWrapper.size;
    final chartViewSize = _getChartUsableDrawSize(viewSize, holder);

    final topLeft = Offset(_getLeftOffsetDrawSize(holder), 0.0);
    final topRight = Offset(_getLeftOffsetDrawSize(holder) + chartViewSize.width, 0.0);
    final bottomLeft = Offset(_getLeftOffsetDrawSize(holder), chartViewSize.height);
    final bottomRight =
        Offset(_getLeftOffsetDrawSize(holder) + chartViewSize.width, chartViewSize.height);

    /// Draw Top Line
    final topBorder = borderData.border.top;
    if (topBorder.width != 0.0) {
      _borderPaint.color = topBorder.color;
      _borderPaint.strokeWidth = topBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(topLeft, topRight, _borderPaint);
    }

    /// Draw Right Line
    final rightBorder = borderData.border.right;
    if (rightBorder.width != 0.0) {
      _borderPaint.color = rightBorder.color;
      _borderPaint.strokeWidth = rightBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(topRight, bottomRight, _borderPaint);
    }

    /// Draw Bottom Line
    final bottomBorder = borderData.border.bottom;
    if (bottomBorder.width != 0.0) {
      _borderPaint.color = bottomBorder.color;
      _borderPaint.strokeWidth = bottomBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(bottomRight, bottomLeft, _borderPaint);
    }

    /// Draw Left Line
    final leftBorder = borderData.border.left;
    if (leftBorder.width != 0.0) {
      _borderPaint.color = leftBorder.color;
      _borderPaint.strokeWidth = leftBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(bottomLeft, topLeft, _borderPaint);
    }
  }

  void _drawAxes(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    final data = holder.data;
    final viewSize = _getChartUsableDrawSize(canvasWrapper.size, holder);

    // Vertical Axis
    // title
    if (data.axesData.vertical.showAxis != false) {
      final axis = data.axesData.vertical;
      // draw axis title
      if (axis.title.showTitle) {
        final title = axis.title;
        final span = TextSpan(style: title.textStyle, text: title.titleText);
        final tp = TextPainter(
            text: span,
            textAlign: title.textAlign,
            textDirection: title.textDirection,
            textScaleFactor: holder.textScale);
        tp.layout(minWidth: viewSize.height);
        canvasWrapper.save();
        canvasWrapper.rotate(-math.pi * 0.5);
        canvasWrapper.drawText(
          tp,
          Offset(-viewSize.height, title.reservedSize - tp.height),
        );
        canvasWrapper.restore();
      }
      // draw axis grid and titles
      final titles = axis.titles;
      final grid = axis.grid;
      final efficientInterval = utils.getEfficientInterval(viewSize.height, data.verticalDiff);
      var interval = axis.interval != null && axis.interval! > efficientInterval
          ? axis.interval!
          : efficientInterval;

      var verticalSeek = data.minY + interval;

      final delta = data.maxY - data.minY;
      final count = delta ~/ interval;
      final lastPosition = count * verticalSeek;
      final lastPositionOverlapsWithBorder = lastPosition == data.maxY;
      final end = lastPositionOverlapsWithBorder ? data.maxY - interval : data.maxY;
      double? lastTitleY;

      while (verticalSeek < end) {
        if (grid.showGrid != false) {
          final flLine = grid.getDrawingLine(verticalSeek);
          _axesPaint.color = flLine.color;
          _axesPaint.strokeWidth = flLine.strokeWidth;
          _axesPaint.transparentIfWidthIsZero();

          final bothY = _getPixelY(verticalSeek, viewSize, holder);
          final x1 = 0 + _getLeftOffsetDrawSize(holder);
          final y1 = bothY;
          final x2 = viewSize.width + _getLeftOffsetDrawSize(holder);
          final y2 = bothY;
          canvasWrapper.drawDashedLine(
              Offset(x1, y1), Offset(x2, y2), _axesPaint, flLine.dashArray);
        }
        if (titles.showTitles != false) {
          final text = titles.getTitles(verticalSeek);
          final span = TextSpan(style: titles.getTextStyles(verticalSeek), text: text);
          final tp = TextPainter(
              text: span,
              textAlign: TextAlign.center,
              textDirection: titles.textDirection,
              textScaleFactor: holder.textScale);
          tp.layout(maxWidth: _getExtraNeededHorizontalSpace(holder));
          var x = 0 + _getLeftOffsetDrawSize(holder);
          var y = _getPixelY(verticalSeek, viewSize, holder);
          x -= tp.width + titles.margin;
          y -= tp.height / 2;
          final showTitle = _checkToShowTitle(data.minY, data.maxY, titles, interval, verticalSeek);
          final skipTitle = lastTitleY != null && lastTitleY - tp.height < y;
          if (showTitle != false && skipTitle != true) {
            lastTitleY = y;
            canvasWrapper.save();
            canvasWrapper.translate(x + tp.width / 2, y + tp.height / 2);
            canvasWrapper.rotate(utils.radians(titles.rotateAngle));
            canvasWrapper.translate(-(x + tp.width / 2), -(y + tp.height / 2));
            y -= utils.translateRotatedPosition(tp.width, titles.rotateAngle);
            canvasWrapper.drawText(tp, Offset(x, y));
            canvasWrapper.restore();
          }
          verticalSeek += interval;
        }
      }
    }

    if (data.axesData.horizontal.showAxis != false) {
      final axis = data.axesData.horizontal;
      // draw axis title
      if (axis.title.showTitle) {
        final title = axis.title;
        final span = TextSpan(style: title.textStyle, text: title.titleText);
        final tp = TextPainter(
            text: span,
            textAlign: title.textAlign,
            textDirection: title.textDirection,
            textScaleFactor: holder.textScale);
        tp.layout(minWidth: viewSize.width);
        canvasWrapper.drawText(
            tp,
            Offset(_getLeftOffsetDrawSize(holder),
                _getExtraNeededVerticalSpace(holder) - title.reservedSize + viewSize.height));
      }
      // draw grid and titles
      final titles = axis.titles;
      final grid = axis.grid;
      final efficientInterval = utils.getEfficientInterval(viewSize.width, data.horizontalDiff);
      var interval = axis.interval != null && axis.interval! > efficientInterval
          ? axis.interval!
          : efficientInterval;
      final delta = data.maxX - data.minX;
      final count = delta ~/ interval;
      final lastPosition = count * interval;
      final lastPositionOverlapsWithBorder = lastPosition == data.maxX;
      final end = lastPositionOverlapsWithBorder ? data.maxX - interval : data.maxX;
      var horizontalSeek = data.minX + (interval - (data.minX % interval));
      var lastTitleX = 0.0;

      while (horizontalSeek <= end) {
        if (grid.showGrid) {
          final flLineStyle = grid.getDrawingLine(horizontalSeek);
          _axesPaint.color = flLineStyle.color;
          _axesPaint.strokeWidth = flLineStyle.strokeWidth;
          _axesPaint.transparentIfWidthIsZero();

          final bothX = _getPixelX(horizontalSeek, viewSize, holder).roundToDouble();
          final x1 = bothX;
          final y1 = 0.0;
          final x2 = bothX;
          final y2 = viewSize.height;
          canvasWrapper.drawDashedLine(
              Offset(x1, y1), Offset(x2, y2), _axesPaint, flLineStyle.dashArray);
        }
        if (titles.showTitles) {
          final text = titles.getTitles(horizontalSeek);
          final span = TextSpan(style: titles.getTextStyles(horizontalSeek), text: text);
          final tp = TextPainter(
              text: span,
              textAlign: TextAlign.center,
              textDirection: titles.textDirection,
              textScaleFactor: holder.textScale);
          tp.layout();

          var x = _getPixelX(horizontalSeek, viewSize, holder);
          var y = viewSize.height;
          x -= tp.width / 2;
          y += titles.margin;
          final showTitle =
              _checkToShowTitle(data.minX, data.maxX, titles, interval, horizontalSeek);
          final skipTitle = lastTitleX + tp.width > x;
          if (showTitle != false && skipTitle != true) {
            lastTitleX = x;
            canvasWrapper.save();
            canvasWrapper.translate(x + tp.width / 2, y + tp.height / 2);
            canvasWrapper.rotate(utils.radians(titles.rotateAngle));
            canvasWrapper.translate(-(x + tp.width / 2), -(y + tp.height / 2));
            x += utils.translateRotatedPosition(tp.width, titles.rotateAngle);
            canvasWrapper.drawText(tp, Offset(x, y));
            canvasWrapper.restore();
          }
        }
        horizontalSeek += interval;
      }
    }
  }

  void _drawBarLine(
    CanvasWrapper canvasWrapper,
    ScopeChartBarData barData,
    ScopePaintHolder holder,
  ) {
    final viewSize = canvasWrapper.size;
    final barList = <List<FlSpot>>[[]];

    for (var spot in barData.spots) {
      if (spot.isNotNull()) {
        barList.last.add(spot);
      } else if (barList.last.isNotEmpty) {
        barList.add([]);
      }
    }
    if (barList.last.isEmpty) {
      barList.removeLast();
    }

    for (var bar in barList) {
      final barPath = _generateBarPath(viewSize, barData, bar, holder);
      _drawBarShadow(canvasWrapper, barPath, barData);
      _drawBar(canvasWrapper, barPath, barData, holder);
    }
  }

  Path _generateBarPath(
    Size viewSize,
    ScopeChartBarData barData,
    List<FlSpot> barSpots,
    ScopePaintHolder holder, {
    Path? appendToPath,
  }) {
    return _generateNormalBarPath(
      viewSize,
      barData,
      barSpots,
      holder,
      appendToPath: appendToPath,
    );
  }

  Path _generateNormalBarPath(
    Size viewSize,
    ScopeChartBarData barData,
    List<FlSpot> barSpots,
    ScopePaintHolder holder, {
    Path? appendToPath,
  }) {
    viewSize = _getChartUsableDrawSize(viewSize, holder);
    final path = appendToPath ?? Path();
    final size = barSpots.length;

    var temp = const Offset(0.0, 0.0);

    final x = _getPixelX(barSpots[0].x, viewSize, holder);
    final y = _getPixelY(barSpots[0].y, viewSize, holder);
    if (appendToPath == null) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
    for (var i = 1; i < size; i++) {
      /// CurrentSpot
      final current = Offset(
        _getPixelX(barSpots[i].x, viewSize, holder),
        _getPixelY(barSpots[i].y, viewSize, holder),
      );

      /// previous spot
      final previous = Offset(
        _getPixelX(barSpots[i - 1].x, viewSize, holder),
        _getPixelY(barSpots[i - 1].y, viewSize, holder),
      );

      /// next point
      final next = Offset(
        _getPixelX(barSpots[i + 1 < size ? i + 1 : i].x, viewSize, holder),
        _getPixelY(barSpots[i + 1 < size ? i + 1 : i].y, viewSize, holder),
      );

      final controlPoint1 = previous + temp;

      /// if the isCurved is false, we set 0 for smoothness,
      /// it means we should not have any smoothness then we face with
      /// the sharped corners line
      final smoothness = barData.isCurved ? barData.curveSmoothness : 0.0;
      temp = ((next - previous) / 2) * smoothness;

      if (barData.preventCurveOverShooting) {
        if ((next - current).dy <= barData.preventCurveOvershootingThreshold ||
            (current - previous).dy <= barData.preventCurveOvershootingThreshold) {
          temp = Offset(temp.dx, 0);
        }

        if ((next - current).dx <= barData.preventCurveOvershootingThreshold ||
            (current - previous).dx <= barData.preventCurveOvershootingThreshold) {
          temp = Offset(0, temp.dy);
        }
      }

      final controlPoint2 = current - temp;

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  /// draw the main bar line's shadow by the [barPath]
  void _drawBarShadow(
    CanvasWrapper canvasWrapper,
    Path barPath,
    ScopeChartBarData barData,
  ) {
    if (!barData.show || barData.shadow.color.opacity == 0.0) {
      return;
    }
    _barPaint.strokeCap = StrokeCap.butt;
    _barPaint.color = barData.shadow.color;
    _barPaint.shader = null;
    _barPaint.strokeWidth = barData.barWidth;
    _barPaint.color = barData.shadow.color;
    _barPaint.maskFilter =
        MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(barData.shadow.blurRadius));
    barPath = barPath.shift(barData.shadow.offset);
    canvasWrapper.drawPath(
      barPath,
      _barPaint,
    );
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  /// draw the main bar line by the [barPath]
  void _drawBar(
    CanvasWrapper canvasWrapper,
    Path barPath,
    ScopeChartBarData barData,
    ScopePaintHolder holder,
  ) {
    if (!barData.show) {
      return;
    }
    _barPaint.strokeCap = StrokeCap.butt;
    _barPaint.color = barData.color;
    _barPaint.shader = null;
    _barPaint.maskFilter = null;
    _barPaint.strokeWidth = barData.barWidth;
    _barPaint.transparentIfWidthIsZero();
    canvasWrapper.drawPath(barPath, _barPaint);
  }

  Size _getChartUsableDrawSize(Size viewSize, ScopePaintHolder holder) {
    final usableWidth = viewSize.width - _getExtraNeededHorizontalSpace(holder);
    final usableHeight = viewSize.height - _getExtraNeededVerticalSpace(holder);
    return Size(usableWidth, usableHeight);
  }

  double _getExtraNeededHorizontalSpace(ScopePaintHolder holder) {
    final data = holder.data;
    final verticalAxis = data.axesData.vertical;
    var sum = 0.0;

    if (verticalAxis.showAxis) {
      final title = verticalAxis.title;
      if (title.showTitle) {
        sum += title.reservedSize + title.margin;
      }

      final titles = verticalAxis.titles;
      if (titles.showTitles) {
        sum += titles.reservedSize + titles.margin;
      }
    }

    return sum;
  }

  double _getExtraNeededVerticalSpace(ScopePaintHolder holder) {
    final data = holder.data;
    var sum = 0.0;
    final horizontalAxis = data.axesData.horizontal;

    if (horizontalAxis.showAxis != false) {
      final title = horizontalAxis.title;
      if (title.showTitle != false) {
        sum += title.reservedSize + title.margin;
      }

      final titles = horizontalAxis.titles;
      if (titles.showTitles != false) {
        sum += titles.reservedSize + titles.margin;
      }
    }
    return sum;
  }

  double _getLeftOffsetDrawSize(ScopePaintHolder holder) {
    final data = holder.data;
    var sum = 0.0;

    final axis = data.axesData.vertical;
    if (axis.showAxis != false) {
      final title = axis.title;
      if (title.showTitle != false) {
        sum += title.reservedSize + title.margin;
      }

      final titles = axis.titles;
      if (titles.showTitles != false) {
        sum += titles.reservedSize + titles.margin;
      }
    }
    return sum;
  }

  double _getPixelX(
    double spotX,
    Size chartUsableSize,
    ScopePaintHolder holder,
  ) {
    final data = holder.data;
    final deltaX = data.maxX - data.minX;
    if (deltaX == 0.0) {
      return _getLeftOffsetDrawSize(holder);
    }
    return (((spotX - data.minX) / deltaX) * chartUsableSize.width) +
        _getLeftOffsetDrawSize(holder);
  }

  /// With this function we can convert our [FlSpot] y
  /// to the view base axis y.
  double _getPixelY(double spotY, Size chartUsableSize, ScopePaintHolder holder) {
    final data = holder.data;
    final deltaY = data.maxY - data.minY;
    if (deltaY == 0.0) {
      return chartUsableSize.height;
    }

    var y = ((spotY - data.minY) / deltaY) * chartUsableSize.height;
    y = chartUsableSize.height - y;
    return y;
  }

  bool _checkToShowTitle(
    double minValue,
    double maxValue,
    ScopeTitles titles,
    double appliedInterval,
    double value,
  ) {
    if ((maxValue - minValue) % appliedInterval == 0) {
      return true;
    }
    return value > minValue && value < maxValue;
  }
}
