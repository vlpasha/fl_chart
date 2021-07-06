import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';

class ScopeAxisGrid with EquatableMixin {
  final bool showGrid;
  final GetDrawingGridLine getDrawingLine;
  final CheckToShowGrid checkToShowLine;

  const ScopeAxisGrid({
    this.showGrid = true,
    this.getDrawingLine = defaultGridLine,
    this.checkToShowLine = showAllGrids,
  });

  ScopeAxisGrid copyWith({
    bool? showGrid,
    GetDrawingGridLine? getDrawingLine,
    CheckToShowGrid? checkToShowLine,
  }) =>
      ScopeAxisGrid(
        showGrid: showGrid ?? this.showGrid,
        getDrawingLine: getDrawingLine ?? this.getDrawingLine,
        checkToShowLine: checkToShowLine ?? this.checkToShowLine,
      );

  @override
  List<Object?> get props => [
        showGrid,
        getDrawingLine,
        checkToShowLine,
      ];
}

class ScopeAxisTitle with EquatableMixin {
  final bool showTitle;
  final bool colorize;
  final String titleText;
  final double reservedSize;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double margin;

  const ScopeAxisTitle({
    this.showTitle = false,
    this.colorize = false,
    this.titleText = '',
    this.reservedSize = 14,
    TextStyle? textStyle,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.center,
    this.margin = 4,
  }) : textStyle = textStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 11,
            );

  ScopeAxisTitle copyWith({
    bool? showTitle,
    String? titleText,
    double? reservedSize,
    TextStyle? textStyle,
    TextDirection? textDirection,
    TextAlign? textAlign,
    double? margin,
  }) =>
      ScopeAxisTitle(
        showTitle: showTitle ?? this.showTitle,
        titleText: titleText ?? this.titleText,
        reservedSize: reservedSize ?? this.reservedSize,
        textStyle: textStyle ?? this.textStyle,
        textDirection: textDirection ?? this.textDirection,
        textAlign: textAlign ?? this.textAlign,
        margin: margin ?? this.margin,
      );

  TextPainter getTextPainter(
    double textScale,
    double? minWidth,
  ) {
    final span = TextSpan(style: textStyle, text: titleText);
    final tp = TextPainter(
      text: span,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScale,
    );
    tp.layout(minWidth: minWidth ?? 0.0);
    return tp;
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        showTitle,
        titleText,
        reservedSize,
        textStyle,
        textAlign,
        margin,
      ];
}

class ScopeAxisTitles with EquatableMixin {
  final bool showTitles;
  final bool colorize;
  final GetTitleFunction getTitles;
  final double reservedSize;
  final TextStyle textStyle;
  final TextDirection textDirection;
  final double margin;
  final double rotateAngle;
  final double padding;

  const ScopeAxisTitles({
    this.showTitles = true,
    this.colorize = false,
    this.getTitles = defaultGetTitle,
    this.reservedSize = 22,
    TextStyle? textStyle,
    this.textDirection = TextDirection.ltr,
    this.margin = 6,
    this.rotateAngle = 0.0,
    this.padding = 4.0,
  }) : textStyle = textStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 11,
            );

  ScopeAxisTitles copyWith({
    bool? showTitles,
    GetTitleFunction? getTitles,
    double? reservedSize,
    TextStyle? textStyle,
    TextDirection? textDirection,
    double? margin,
    double? rotateAngle,
  }) =>
      ScopeAxisTitles(
        showTitles: showTitles ?? this.showTitles,
        getTitles: getTitles ?? this.getTitles,
        reservedSize: reservedSize ?? this.reservedSize,
        textStyle: textStyle ?? this.textStyle,
        textDirection: textDirection ?? this.textDirection,
        margin: margin ?? this.margin,
        rotateAngle: rotateAngle ?? this.rotateAngle,
      );

  TextPainter getTextPainter(double value, double textScale) {
    final span = TextSpan(style: textStyle, text: getTitles(value));
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: textDirection,
      textScaleFactor: textScale,
    );
    tp.layout();
    return tp;
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        showTitles,
        getTitles,
        reservedSize,
        textStyle,
        margin,
        rotateAngle,
      ];
}

class ScopeAxisData {
  final bool showAxis;
  final double width;
  final ScopeAxisTitle title;
  final ScopeAxisTitles titles;
  final ScopeAxisGrid grid;
  final double? interval;
  final double? min;
  final double? max;

  const ScopeAxisData({
    this.showAxis = true,
    this.width = 2.0,
    this.titles = const ScopeAxisTitles(reservedSize: 16),
    this.grid = const ScopeAxisGrid(),
    this.title = const ScopeAxisTitle(),
    this.interval,
    this.min,
    this.max,
  });

  ScopeAxisData copyWith({
    bool? showAxis,
    ScopeAxisTitles? titles,
    ScopeAxisGrid? grid,
    ScopeAxisTitle? title,
    double? interval,
    double? min,
    double? max,
  }) =>
      ScopeAxisData(
        showAxis: showAxis ?? this.showAxis,
        titles: this.titles.copyWith(
              showTitles: titles?.showTitles,
              textStyle: titles?.textStyle,
              getTitles: titles?.getTitles,
              margin: titles?.margin,
              reservedSize: titles?.reservedSize,
              rotateAngle: titles?.rotateAngle,
              textDirection: titles?.textDirection,
            ),
        grid: this.grid.copyWith(
              showGrid: grid?.showGrid,
              checkToShowLine: grid?.checkToShowLine,
              getDrawingLine: grid?.getDrawingLine,
            ),
        title: this.title.copyWith(
            showTitle: title?.showTitle,
            titleText: title?.titleText,
            reservedSize: title?.reservedSize,
            textStyle: title?.textStyle,
            textDirection: title?.textDirection,
            textAlign: title?.textAlign,
            margin: title?.margin),
        interval: interval ?? this.interval,
        min: min ?? this.min,
        max: max ?? this.max,
      );
}
