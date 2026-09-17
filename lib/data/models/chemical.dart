import 'package:flutter/material.dart';

class Chemical {
  final String id;
  final String name;
  final String formula;
  final String state;       // Solid / Liquid / Gas
  final Color color;
  final String? safetyInfo;

  const Chemical({
    required this.id,
    required this.name,
    required this.formula,
    required this.state,
    required this.color,
    this.safetyInfo,
  });
}