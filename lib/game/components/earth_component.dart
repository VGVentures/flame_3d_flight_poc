import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_flight_poc/game/game.dart';

class EarthComponent extends MeshComponent
    with HasGameReference<Flame3dFlightPoc> {
  EarthComponent({required double radius})
    : super(
        mesh: SphereMesh(
          radius: radius,
        ),
      );

  @override
  FutureOr<void> onLoad() async {
    final milkyWayTexture = await Flame.images.loadTexture(
      'earth2048.bmp',
    );
    mesh.updateSurfaces((surfaces) {
      surfaces[0].material = SpatialMaterial(
        albedoTexture: milkyWayTexture,
      );
    });
  }
}
