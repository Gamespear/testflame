import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:testflame/adventure.dart';

class Heart extends SpriteComponent with HasGameRef<Adventure>{

  Heart({required Vector2 position}) : super (position: position, size: Vector2.all(32), priority: 10,);

  @override
  FutureOr<void> onLoad() async{
    sprite = await gameRef.loadSprite('12-Live and Coins/heart.png');
    return super.onLoad();
  }

  


}