import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:testflame/adventure.dart';
import 'package:testflame/compenents/player.dart';

class Finish extends SpriteAnimationComponent with HasGameRef<Adventure>, CollisionCallbacks{
  Finish({position,size}) : super(position: position, size: size);

  bool reachedFinish = false;


  @override
  FutureOr<void> onLoad() {

    add(RectangleHitbox(collisionType: CollisionType.passive));

    animation = SpriteAnimation.fromFrameData(game.images.fromCache("11-Door/Idle.png"), 
    SpriteAnimationData.sequenced(
      amount: 1, 
      stepTime: 0.05, 
      textureSize: Vector2(46, 56)),
      );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !reachedFinish) _reachedFinish();
    
    super.onCollision(intersectionPoints, other);
  }


  void _reachedFinish() {
    reachedFinish = true;


    animation = SpriteAnimation.fromFrameData(game.images.fromCache("11-Door/Opening (46x56).png"), 
    SpriteAnimationData.sequenced(
      amount: 5, 
      stepTime: 0.05, 
      textureSize: Vector2(46, 56),
      loop: false,   
      ),
  
    );

    const finishDuration = Duration(milliseconds: 800);
    Future.delayed(finishDuration, (){
      animation = SpriteAnimation.fromFrameData(game.images.fromCache("11-Door/Closiong (46x56).png"), 
      SpriteAnimationData.sequenced(
      amount: 3, 
      stepTime: 0.05, 
      textureSize: Vector2(46, 56),
      loop: false,   
      ),
  
    );
    });
  }

}
