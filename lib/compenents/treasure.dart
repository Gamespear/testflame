import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:testflame/adventure.dart';
import 'package:testflame/compenents/custom_hitbox.dart';

class Treasure extends SpriteAnimationComponent with HasGameRef<Adventure>, CollisionCallbacks{

  final String treasure;
  Treasure({this.treasure = 'Big Diamond', position, size,}) : super(position: position, size: size,);


  bool collected = false;


  final double stepTime = 0.05;
  final hitbox = CustomHitbox(
    offsetX: 10, 
    offsetY: 5, 
    width: 20, 
    height: 22,
    );


@override
  FutureOr<void> onLoad() {
    //debugMode = true;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('12-Live and Coins/$treasure Idle (18x14).png'), 
        SpriteAnimationData.sequenced( 
          amount: 10, 
          stepTime: stepTime, 
          textureSize: Vector2(18, 14),
      )
    );
    return super.onLoad();
  }




  // when colliding with player then dissapear the treasure
  void collidingWithPlayer(){
    if(!collected){
      collected = true;
      if(game.playSounds) FlameAudio.play('diamond.wav',volume: game.soundVolume);
      removeFromParent();

    }

  }
}