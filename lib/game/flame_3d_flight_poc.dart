import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d_flight_poc/game/game.dart';
import 'package:flame_3d_flight_poc/l10n/l10n.dart';
import 'package:flutter/painting.dart';

class Flame3dFlightPoc extends FlameGame3D {
  Flame3dFlightPoc({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  int counter = 0;

  CounterComponent? counterComponent;

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    final earth = await EarthComponent.spawn(scale: 0.001);
    final moon = await MoonComponent.spawn(
      scale: 0.001,
      position: earth.position + Vector3(20, 0, 0),
    );

    final world = World3D(
      children: [
        LightComponent.ambient(
          intensity: 20,
        ),
        MilkyWayComponent(),
        earth,
        moon,
      ],
    );

    this.world = world;

    final camera = CameraComponent3D(
      world: world,
      position: Vector3(-18, 0, -18),
      target: Vector3.zero(),
    );

    // add a HUD component showing number of taps on unicorn
    counterComponent = CounterComponent(position: Vector2(0, 0));
    camera.viewport.add(counterComponent!);
    _positionCounterComponent(size);

    this.camera = camera;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _positionCounterComponent(size);
  }

  void _positionCounterComponent(Vector2 size) {
    counterComponent?.position = Vector2(10, size.y - 10);
  }
}
