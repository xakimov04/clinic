import 'package:flutter/material.dart';

extension SpacingExtension on num {
  // SizedBox helpers
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
  SizedBox get square => SizedBox(height: toDouble(), width: toDouble());

  // Padding helpers
  EdgeInsetsGeometry get v => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsetsGeometry get horizontal =>
      EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsetsGeometry get a => EdgeInsets.all(toDouble());
  EdgeInsetsGeometry get t => EdgeInsets.only(top: toDouble());
  EdgeInsetsGeometry get b => EdgeInsets.only(bottom: toDouble());
  EdgeInsetsGeometry get l => EdgeInsets.only(left: toDouble());
  EdgeInsetsGeometry get r => EdgeInsets.only(right: toDouble());

  // Padding widgets
  Padding get padV => Padding(padding: v);
  Padding get padA => Padding(padding: a);
  Padding get padT => Padding(padding: t);
  Padding get padB => Padding(padding: b);
  Padding get padL => Padding(padding: l);
  Padding get padR => Padding(padding: r);

  // Margin helpers for Container
  Widget padWith(Widget child) => Padding(padding: a, child: child);
  Widget padVertical(Widget child) => Padding(padding: v, child: child);
  Widget padTop(Widget child) => Padding(padding: t, child: child);
  Widget padBottom(Widget child) => Padding(padding: b, child: child);
  Widget padLeft(Widget child) => Padding(padding: l, child: child);
  Widget padRight(Widget child) => Padding(padding: r, child: child);

  // Radius helpers
  BorderRadius get circular => BorderRadius.circular(toDouble());
  BorderRadius get verticalTop =>
      BorderRadius.vertical(top: Radius.circular(toDouble()));
  BorderRadius get verticalBottom =>
      BorderRadius.vertical(bottom: Radius.circular(toDouble()));
  BorderRadius get horizontalLeft =>
      BorderRadius.horizontal(left: Radius.circular(toDouble()));
  BorderRadius get horizontalRight =>
      BorderRadius.horizontal(right: Radius.circular(toDouble()));

  // Shadow helpers
  BoxShadow shadow({
    Color? color,
    double? blurRadius,
    Offset? offset,
    double? spreadRadius,
  }) =>
      BoxShadow(
        color: color ?? Colors.black.withOpacity(0.1),
        blurRadius: blurRadius ?? toDouble(),
        spreadRadius: spreadRadius ?? 0,
        offset: offset ?? Offset(0, toDouble() / 2),
      );

  // Duration helpers
  Duration get ms => Duration(milliseconds: toInt());
  Duration get sec => Duration(seconds: toInt());
  Duration get min => Duration(minutes: toInt());
  Duration get hr => Duration(hours: toInt());

  // Animation curve with duration
  Curve get ease => Curves.easeInOut;
  Curve get easeIn => Curves.easeIn;
  Curve get easeOut => Curves.easeOut;
}
