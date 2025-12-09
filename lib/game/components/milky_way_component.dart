import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_flight_poc/game/game.dart';

class MilkyWayComponent extends MeshComponent
    with HasGameReference<Flame3dFlightPoc> {
  MilkyWayComponent()
    : super(
        mesh: SphereMesh(
          radius: 500,
        ),
      );

  @override
  FutureOr<void> onLoad() async {
    final milkyWayTexture = await Flame.images.loadTexture(
      '2k_stars_milky_way.bmp',
    );
    mesh.updateSurfaces((surfaces) {
      surfaces[0].material = SpatialMaterial(
        albedoTexture: milkyWayTexture,
      );
    });
  }
}
