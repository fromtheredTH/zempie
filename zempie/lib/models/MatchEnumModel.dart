
import 'dart:ui';

import 'package:flutter/material.dart';

class MatchEnumModel {
  late int idx;
  late String enumValue;
  late String koName;
  late String enName;
  late Color color;

  MatchEnumModel(int idx, String enumValue, String koName, String enName, Color color) {
    this.idx = idx;
    this.enumValue = enumValue;
    this.koName = koName;
    this.enName = enName;
    this.color = color;
  }

}