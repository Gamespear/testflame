import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:testflame/adventure.dart';

class Restart extends PositionComponent with HasGameRef<Adventure> implements TapCallbacks{

  Restart();

  @override
  void onTapDown(TapDownEvent event) {
    print("restarting");
    game.resetGame(); // Call resetGame on the parent game reference
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    // No-op (not needed for this button)
  }

@override
  void onTapCancel(TapCancelEvent event) {
    // TODO: implement onTapCancel
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    // No-op (not needed for this button)
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, 100, 50); // Button dimensions
    final paint = Paint()..color = const Color(0xFF0000FF);
    canvas.drawRect(rect, paint);

    // Draw button label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Restart',
        style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2));
  }
}