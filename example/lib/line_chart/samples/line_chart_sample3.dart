// import 'dart:math';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class ScopeV2 extends StatelessWidget {
//   ScopeV2({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) => Scope(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       );
// }

// class LineChartSample3 extends StatefulWidget {
//   @override
//   _LineChartSample3State createState() => _LineChartSample3State();
// }

// class _LineChartSample3State extends State<LineChartSample3>
//     with SingleTickerProviderStateMixin {
//   AnimationController _animationController;
//   @override
//   void initState() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (_, __) => ScopeV2(),
//     );
//   }
// }
