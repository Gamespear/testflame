import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:testflame/adventure.dart';
import 'package:testflame/compenents/collision_block.dart';
import 'package:testflame/compenents/finish.dart';
import 'package:testflame/compenents/heart.dart';
import 'package:testflame/compenents/player.dart';
import 'package:testflame/compenents/saw.dart';
import 'package:testflame/compenents/treasure.dart';

class Level extends World with HasGameRef<Adventure>{

  final String levelName; 
  final Player player;


  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async{
    
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(32));

    add(level);
    level.priority = -1;
    priority = -1;


    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }


  //Spawning the objects on the spot where you have put for example: the class name 'Player' in Tiles. 
  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    priority = 0;    
    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer!.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Treasure':
            final treasure = Treasure(
              treasure: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          add(treasure);
          break;
          case 'Saw':
          final isVertical = spawnPoint.properties.getValue('isVertical');
          final offNeg = spawnPoint.properties.getValue('offNeg');
          final offPos = spawnPoint.properties.getValue('offPos');
          final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          add(saw);
          break;
          case 'Finish':
          final finish = Finish(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),            
          );
          add(finish);
          break;
         default:
        }       
      }
    }

  }


  //Collisions of the all the objects that you have selected as object layer named Collisions in Tiles. 
  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if(collisionsLayer != null){
      for(final collision in collisionsLayer.objects){
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock( 
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
             final block = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
             );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }


}
