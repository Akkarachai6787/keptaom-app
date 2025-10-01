import 'package:flutter/material.dart';
import 'dart:math';

Color hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

String getRandomCategoryColorHex(bool isIncome, List<String?> usedColors) {
  final random = Random();

  final coolTones = [
    const Color.fromARGB(255, 161, 0, 242),
    const Color.fromARGB(255, 47, 102, 144),
    const Color.fromARGB(255, 20, 116, 111),
    const Color.fromARGB(255, 57, 73, 171),
    const Color.fromARGB(255, 106, 0, 244),
    const Color.fromARGB(255, 0, 151, 167),
    const Color.fromARGB(255, 2, 119, 189),
  ];

  final warmTones = [
    const Color.fromARGB(255, 251, 111, 146),
    const Color.fromARGB(255, 250, 163, 0),
    const Color.fromARGB(255, 239, 108, 0),
    const Color.fromARGB(255, 194, 56, 14),
    const Color.fromARGB(255, 216, 27, 96),
    const Color.fromARGB(255, 255, 143, 0),
    const Color.fromARGB(255, 201, 24, 74),
  ];

  final palette = isIncome ? coolTones : warmTones;

  final availableColors = palette.where((c) {
    final hex = '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    return !usedColors.contains(hex);
  }).toList();

  final chosenColor = availableColors.isNotEmpty
      ? availableColors[random.nextInt(availableColors.length)]
      : palette[random.nextInt(palette.length)];

  final argb = chosenColor.toARGB32();
  final rgb = argb & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
