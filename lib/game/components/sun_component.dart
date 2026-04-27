import 'dart:async';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class SunComponent extends MeshComponent {
  SunComponent({required double radius, required Vector3 position})
    : super(
        mesh: SphereMesh(
          radius: radius,
          material: SpatialMaterial(
            albedoColor: const Color(0xFFFFF59D),
            metallic: 0,
            roughness: 1,
          ),
        ),
        position: position,
      );

  @override
  FutureOr<void> onLoad() async {
    await add(
      LightComponent.point(
        color: const Color(0xFFFFF8E1),
        intensity: 400000,
      ),
    );
  }
}
