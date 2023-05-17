import 'dart:ui';
import 'package:path_parsing/path_parsing.dart';

class SvgPathConverter extends PathProxy {
  final List<Offset> _pathOffsets = [];

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _pathOffsets.add(Offset(x1, y1));
  }

  @override
  void lineTo(double x, double y) {
    _pathOffsets.add(Offset(x, y));
  }

  @override
  void moveTo(double x, double y) {
    _pathOffsets.add(Offset(x, y));
  }

  @override
  void close() {}

  List<Offset> convert({required String svgPath}) {
    _pathOffsets.clear();
    writeSvgPathDataToPath(svgPath, this);

    return _pathOffsets;
  }
}
