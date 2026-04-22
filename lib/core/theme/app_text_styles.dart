import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const heading1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const heading2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const titleMd  = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const titleSm  = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const bodyMd   = TextStyle(fontSize: 14);
  static const bodySm   = TextStyle(fontSize: 13);
  static const caption  = TextStyle(fontSize: 12);
  static const label    = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static const button   = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
}