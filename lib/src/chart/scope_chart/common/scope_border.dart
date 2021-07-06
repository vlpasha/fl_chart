import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ScopeBorderData with EquatableMixin {
  final bool showBorder;
  Border border;

  ScopeBorderData({
    this.showBorder = true,
    Border? border,
  }) : border = border ??
            Border.all(
              color: Colors.black,
              width: 1.0,
              style: BorderStyle.solid,
            );

  @override
  List<Object?> get props => [showBorder, border];

  ScopeBorderData copyWith(bool? showBorder, Border? border) => ScopeBorderData(
        showBorder: showBorder ?? this.showBorder,
        border: border ?? this.border,
      );
}
