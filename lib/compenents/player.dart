import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/widgets.dart';
import 'package:testflame/adventure.dart';
import 'package:testflame/compenents/collision_block.dart';
import 'package:testflame/compenents/custom_hitbox.dart';
import 'package:testflame/compenents/finish.dart';
import 'package:testflame/compenents/level.dart';
import 'package:testflame/compenents/saw.dart';
import 'package:testflame/compenents/treasure.dart';
import 'package:testflame/compenents/utils.dart';
import 'package:flame/text.dart';

enum PlayerState{idle, running, jumping, falling, hit, appearing, dissapearing}

class Player extends SpriteAnimationGroupComponent with HasGameRef<Adventure>, KeyboardHandler, CollisionCallbacks{

  String charactor;
  Player({position, this.charactor = 'Virtual Guy'}) : super(position: position);
  

  late final SpriteAnimation idleAnimation; 
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation dissapearingAnimation;

  int lives = 2; 


  final double stepTime = 0.05;
  final double gravity = 9.8; 
  final double jumpForce = 500; 
  final double terminalVelocity = 300; 


  bool isGround = false;
  bool hasJumped = false; 
  bool gotHit = false;
  bool reachedFinish = false;
  bool dead = false;

  double horizontalMovement = 0; 
  double speed = 100; 

  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];

  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4, 
    width: 14,
    height: 28,
    );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();
   // debugMode = true;

   startingPosition = Vector2(position.x, position.y);

   // Player Hitbox/collision
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));


    return super.onLoad();
  }

  @override
  void update(double dt) {

    //if the player is not hit by a trap
    if (!gotHit && !reachedFinish && !dead) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollision();
    _applyGravity(dt);
    _checkVerticalCollisions();
    }
    super.update(dt);
  }

  // keyboard input of the player
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    // if isLeftKeyPressed is true than -1 otherwise 0
    horizontalMovement += isLeftKeyPressed ? -1.5 : 0; 
    // if isRightKeyPressed is true than 1 otherwise 0
    horizontalMovement += isRightKeyPressed ? 1.5 : 0; 
    
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  // Collision with Player and other objects
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {

    if (!reachedFinish) {
      if(other is Treasure) {
        other.collidingWithPlayer();
        game.addScore();
      }

      if(other is Saw){
        
        _respawn();
        gameRef.removeHeart();
        print("hit invisible");
        
      } 

      if(other is Finish && !reachedFinish) _reachedFinish();
      
    }
    super.onCollision(intersectionPoints, other);
  }

 

  // Loading animations
  void _loadAllAnimation(){

    // The idle animation 
    idleAnimation = _spriteAnimation('Idle', 11);
    // The run animation 
    runAnimation = _spriteAnimation('Run', 12);
    // The jump animation
    jumpAnimation = _spriteAnimation('Jump', 1);
    // The fall animation
    fallAnimation = _spriteAnimation('Fall', 1);
    // the hit animation
    hitAnimation = _spriteAnimation('Hit', 7);
    // the appearing animation
    appearingAnimation = _specialSpriteAnimation('Appearing', 7 );
    // the dissappearing animation
    dissapearingAnimation = _specialSpriteAnimation('Desappearing', 7 );


    // list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpAnimation,
      PlayerState.falling: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.dissapearing: dissapearingAnimation,
    };

    // Set current animation 
    current = PlayerState.idle;
  }

  // Cleaner code to not have multiple of the same code. but remember that not all images have the same pixel size! 
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$charactor/$state (32x32).png'), 
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(32),
        ),
      );
  }

    // Cleaner code to not have multiple of the same code. but remember that not all images have the same pixel size! 
  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'), 
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(96),
        ),
        
      );
  }

  // When you need to switch playerstate animations
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }
    // Check if player is moving then playerstate is run animation.
    if(velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // Check if fall set animation to falling
    if(velocity.y > 0) playerState = PlayerState.falling;

    // Checks if player is jumping, set animation to jumping
    if(velocity.y < 0) playerState = PlayerState.jumping;


    current = playerState;
  }

  // Player movements 
  void _updatePlayerMovement(double dt){

    if (hasJumped && isGround) _playerJumped(dt);

    if(velocity.y > gravity) isGround = false;

    velocity.x = horizontalMovement * speed;
    position.x += velocity.x * dt;
  }

  // Function of player jumping
  void _playerJumped(double dt) {
    if(game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isGround = false;
  }

  // Checking if the player is collided by a object/block horizontally
  void _checkHorizontalCollision() {
    for(final block in collisionBlocks){
      if (!block.isPlatform) {
        if(checkCollision(this, block)){
          if (velocity.x > 0) {

            velocity.x = 0;
            position.x = block.x - hitbox.offsetX -  hitbox.width;
            break;
          }
          if(velocity.x < 0){
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }

    }
  }

  // Adding gravity 
  void _applyGravity(double dt) {
  
  velocity.y += gravity;
  velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
  position.y += velocity.y * dt; 

  
  }

  // Checking if the player is collided by a object/block/platform vertically
  void _checkVerticalCollisions() {
  
    for(final block in collisionBlocks){
      if(block.isPlatform){
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY; 
            isGround = true; 
            break;
          }
        }
      }else{
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY; 
            isGround = true; 
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  
  }

  // When you are hit by a trap 
  void _respawn(){
    if(game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    if (lives <= 0) {
      dead = true;
    } else{
      position = startingPosition;
      --lives;
      dead = false;
    }

  }

  // When you have reached the door
  void _reachedFinish() {
    reachedFinish = true;
    if(game.playSounds) FlameAudio.play('finish.mp3', volume: game.soundVolume);
    if(scale.x > 0){
      position = position - Vector2.all(32);

    } else if (scale.x < 0){
      position = position + Vector2(32, -32);
    }
    current = PlayerState.dissapearing;

    const reachedFinishDuration = Duration(milliseconds: 350);

    Future.delayed(reachedFinishDuration, (){
      reachedFinish = false;
      position = Vector2.all(-640);
      const waitingNextLevelDuration = Duration(seconds: 3);
      Future.delayed(waitingNextLevelDuration, (){
        game.loadNextLevel();
        priority = 1;
      });
    });

  }

}

