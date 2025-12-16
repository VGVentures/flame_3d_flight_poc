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

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    const earthRadius = 10.0;
    final earth = EarthComponent(radius: earthRadius);
    final moon = await MoonComponent.spawn(
      scale: 0.5,
      position: earth.position + Vector3(20, 20, 0),
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

    const cameraRadius = earthRadius + 0.05;
    final cameraPosition = Vector3(0, cameraRadius, 0);
    final cameraTargetPosition = Vector3(0.1, cameraRadius, 0.1);

    final camera = CameraComponent3D(
      world: world,
      position: cameraPosition,
      target: cameraTargetPosition,
    );

    this.camera = camera;
  }
}
