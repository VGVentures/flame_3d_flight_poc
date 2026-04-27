import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_flight_poc/game/game.dart';

class EarthComponent extends MeshComponent
    with HasGameReference<Flame3dFlightPoc> {
  EarthComponent._({required super.mesh});

  static Future<EarthComponent> spawn({required double radius}) async {
    final heightmapImage = await Flame.images.load('earth_bump_8k.jpg');
    final heightmapData = await heightmapImage.toByteData();

    final mesh = DisplacedSphereMesh(
      radius: radius,
      heightmap: heightmapImage,
      heightmapData: heightmapData!,
      // Max safe value: Surface uses Uint16 indices (max 65535).
      // (segments+1)² must stay ≤ 65535, so segments ≤ 254.
      segments: 254,
      displacementScale: 0.15,
    );

    return EarthComponent._(mesh: mesh);
  }

  @override
  FutureOr<void> onLoad() async {
    final earthTexture = await Flame.images.loadTexture('8k_earth_daymap.jpg');
    mesh.updateSurfaces((surfaces) {
      surfaces[0].material = SpatialMaterial(albedoTexture: earthTexture);
    });
  }
}
