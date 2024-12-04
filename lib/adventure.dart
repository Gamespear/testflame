import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:testflame/compenents/heart.dart';
import 'package:testflame/compenents/player.dart';
import 'package:testflame/compenents/level.dart';
import 'package:testflame/compenents/restart.dart';

class Adventure extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks{
  @override
  Color backgroundColor() => const Color.fromARGB(255, 63, 56, 81);

  late CameraComponent cam; 
  late TextComponent scoreText;

  //Making the player on which player you want to play
  Player player = Player(charactor: 'Virtual Guy');

  //Put in your level names
  List<String> levelNames = ['Level_1', 'Level_1'];
  int currentLevelIndex = 0;
  bool playSounds = true;
  double soundVolume = 1.0;

  List<Heart> hearts = [];
  int lives = 3;

  int score = 0;


  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    loadLevel();

    restartButton();


    return super.onLoad();
  }

  void loadNextLevel(){
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      loadLevel();
    } else {
      currentLevelIndex = 0;
      loadLevel();
    }
  }

  void loadLevel() {

    Future.delayed(const Duration(seconds: 1,), (){

      if(playSounds) FlameAudio.play('pixel-party.mp3', volume: soundVolume);


      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(world: world, width: 1280, height: 900);
      cam.viewfinder.anchor = Anchor.topLeft;

      for (var i = 0; i < lives; i++) {
        hearts.add(Heart(position: Vector2(250 + i * 40, 950)));
        add(hearts[i]);
      }

      cam.viewfinder.add(
      scoreText = TextComponent(
        text: 'Score: $score',
        position: Vector2(550, 25),
        priority: -1,
      )
    );

      addAll([cam, world]);

    });

  }

    void removeHeart() {
      if (lives == 0) {
        resetGame();
        print("Game Over");
      } else if (lives > 0 && hearts.isNotEmpty) {
        lives--;
        remove(hearts.removeLast()); // Remove the last heart visually
      } else {
        print('No hearts left');
      }


    }

    void addScore(){
    score++;
    scoreText.text = 'Score: $score';
    print(score);
    }

    void restartButton(){
      add(Restart()
    ..position = Vector2(10, 10) // Position on the screen
    ..size = Vector2(100, 50)); // Size of the button
    }

    void resetGame() {
    // Your reset logic
    children.clear(); // Remove all components
    // Clear the hearts list to avoid referencing orphaned components
    hearts.clear();
    lives = 3;
    player.lives = 2;
    score = 0;
    loadLevel(); // Reinitialize components
    restartButton();
    

  }

}
