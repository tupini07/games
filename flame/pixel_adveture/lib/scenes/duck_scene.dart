import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/extensions/random_extensions.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/widgets/custom_overlay.dart';
import 'package:pixel_adventure/widgets/enum_dropdown.dart';
import 'package:pixel_adventure/widgets/simple_slider.dart';

class PebbleComponent extends RectangleComponent {
  late final double floorY;
  final double _fallSpeed = 100;

  PebbleComponent({required super.position, required this.floorY}) {
    size = Vector2.all(5);

    paint = Paint()
      ..color = Random().sample([
        const Color.fromARGB(255, 235, 194, 81),
        const Color.fromARGB(255, 247, 171, 84),
        const Color.fromARGB(255, 247, 130, 84),
        const Color.fromARGB(255, 247, 103, 84),
      ]);
  }

  void wasEaten() {
    removeFromParent();
  }

  @override
  void update(double dt) {
    if (position.y < floorY) {
      position += Vector2(0, _fallSpeed * dt);
    }
    if (position.y > floorY) {
      position = Vector2(position.x, floorY);
    }

    super.update(dt);
  }
}

enum DuckyState { idle, running, crouching, flying }

class Ducky extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation crouchingAnimation;
  late final SpriteAnimation flyingAnimation;

  final Timer _eatTimer = Timer(0.2, autoStart: false);

  final List<PebbleComponent> _knownPebbles = [];
  PebbleComponent? _pebbleBeingTracked;
  bool _flipped = false;

  Ducky() {
    debugMode = false;

    anchor = Anchor.center;
    var posY = game.size.y * 0.8;
    position = Vector2(game.size.x * 0.5, posY);
  }

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    game.overlays.addEntry(
      "duck_data_widget",
      (context, game) => CustomOverlay(
        children: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              game.overlays.remove("duck_data_widget");
              debugMode = false;
            },
          ),
          const Text('Adjust animation speed:'),
          SimpleSlider(
            label: "Step time",
            initialValue: 0.5,
            onChanged: (newValue) {
              if (newValue > 0) {
                animation?.stepTime = newValue;
              }
            },
          ),
          const Text('Select animation:'),
          EnumDropdown<DuckyState>(
            items: DuckyState.values,
            display: (value) => value.toString(),
            onChanged: (newValue) {
              current = newValue;
            },
          ),
        ],
      ),
    );
    return super.onLoad();
  }

  void _loadAllAnimations() async {
    idleAnimation = SpriteAnimation.spriteList([
      Sprite(game.images.fromCache("duck/Idle 001.png")),
      Sprite(game.images.fromCache("duck/Idle 002.png")),
    ], stepTime: 0.63);

    runningAnimation = SpriteAnimation.spriteList([
      Sprite(game.images.fromCache("duck/Running 001.png")),
      Sprite(game.images.fromCache("duck/Running 002.png")),
    ], stepTime: 0.05);

    crouchingAnimation = SpriteAnimation.spriteList([
      Sprite(game.images.fromCache("duck/Crouching 001.png")),
    ], stepTime: 0.05);

    flyingAnimation = SpriteAnimation.spriteList([
      Sprite(game.images.fromCache("duck/Jumping 001.png")),
      Sprite(game.images.fromCache("duck/Idle 002.png")),
    ], stepTime: 0.05);

    animations = {
      DuckyState.idle: idleAnimation,
      DuckyState.running: runningAnimation,
      DuckyState.crouching: crouchingAnimation,
      DuckyState.flying: flyingAnimation,
    };

    current = DuckyState.idle;
  }

  bool _tryTrackNewPebble() {
    if (_knownPebbles.isEmpty) {
      return false;
    }

    var closestPebble = _knownPebbles.first;
    var closestDistance = (position - closestPebble.position).length;

    for (var pebble in _knownPebbles) {
      var distance = (position - pebble.position).length;
      if (distance < closestDistance) {
        closestPebble = pebble;
        closestDistance = distance;
      }
    }

    _pebbleBeingTracked = closestPebble;

    // pop the pebble from the list
    _knownPebbles.remove(closestPebble);

    if (closestPebble.position.x < position.x && !_flipped) {
      _flipped = true;
      flipHorizontallyAroundCenter();
    } else if (closestPebble.position.x > position.x && _flipped) {
      _flipped = false;
      flipHorizontallyAroundCenter();
    }

    return true;
  }

  void trackPebble(PebbleComponent pebble) {
    _knownPebbles.add(pebble);

    if (_pebbleBeingTracked == null) {
      if (_tryTrackNewPebble()) {
        current = DuckyState.running;
      } else {
        current = DuckyState.idle;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _eatTimer.update(dt);

    if (_pebbleBeingTracked != null) {
      // move towards pebble only in X
      var distanceX = _pebbleBeingTracked!.position.x - position.x;

      // only move if distance is big enough
      if (distanceX.abs() > 1.2) {
        var direction = distanceX.sign;
        var speed = 200;
        if (_knownPebbles.length > 10) {
          speed = 500;
        }

        position += Vector2(direction * speed * dt, 0);
      }

      var distance = (_pebbleBeingTracked!.position - position).length;

      var isPebbleAbove = _pebbleBeingTracked!.position.y < position.y;
      var isPebbleHere = distance.abs() < 5;
      var isPebbleCloseInX = distanceX.abs() < 1;
      var isPebbleClose = distance.abs() < 50;
      var isPebbleBelow = _pebbleBeingTracked!.position.y > position.y;

      if (isPebbleBelow && isPebbleCloseInX) {
        current = DuckyState.crouching;
      } else if (isPebbleAbove && !isPebbleHere && isPebbleCloseInX) {
        current = DuckyState.flying;
      }

      if (isPebbleHere || (isPebbleClose && isPebbleBelow)) {
        if (!_eatTimer.isRunning()) {
          _eatTimer.onTick = () {
            if (_eatTimer.finished) {
              _pebbleBeingTracked!.wasEaten();
              _pebbleBeingTracked = null;
              if (_tryTrackNewPebble()) {
                current = DuckyState.running;
              } else {
                current = DuckyState.idle;
              }
            }
          };
          _eatTimer.start();
        }

        // TODO maybe crouch animation to eat the pebble here?
      }
    }
  }
}

class DuckScene extends Component
    with KeyboardHandler, TapCallbacks, HasGameRef<PixelAdventure> {
  late final String duckQuackSound = "effects/duck_quack.mp3";
  final _duck = Ducky();

  @override
  void onMount() async {
    await FlameAudio.audioCache.load(duckQuackSound);

    var rec = RectangleComponent(
      position: Vector2(0, _duck.position.y),
      size: Vector2(game.size.x, 100), //game.size.y * 0.2),
      paint: Paint()..color = const Color.fromARGB(255, 218, 208, 208),
    );

    await add(rec);
    await add(_duck);

    rec
      ..position = Vector2(0, _duck.position.y + _duck.size.y * 0.3)
      ..size = Vector2(game.size.x, game.size.y - rec.position.y);

    super.onMount();
  }

  @override
  void onRemove() async {
    await FlameAudio.audioCache.clear(duckQuackSound);
    super.onRemove();
  }

  @override
  void onTapDown(TapDownEvent event) async {
    await FlameAudio.play(duckQuackSound);

    var pebble = PebbleComponent(
        position: event.localPosition,
        floorY: _duck.position.y + _duck.size.y * 0.48);
    add(pebble);

    _duck.trackPebble(pebble);

    super.onTapDown(event);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      game.router.pop();
    }

    if (event.isKeyPressed(LogicalKeyboardKey.f7)) {
      _duck.debugMode = !_duck.debugMode;

      if (_duck.debugMode) {
        game.overlays.add("duck_data_widget");
      } else {
        game.overlays.remove("duck_data_widget");
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;
}
