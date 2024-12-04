import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testflame/adventure.dart';

void main() {
  Adventure game = Adventure();
  runApp(GameWidget(game: kDebugMode ? Adventure() : game),);
}
