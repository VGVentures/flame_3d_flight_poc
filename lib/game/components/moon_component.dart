import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/parser.dart';
import 'package:flame_3d_flight_poc/game/game.dart';

class MoonComponent extends ModelComponent
    with HasGameReference<Flame3dFlightPoc> {
  MoonComponent({required super.model, super.scale, super.position});

  static Future<MoonComponent> spawn({
    double scale = 1,
    Vector3? position,
  }) async {
    return MoonComponent(
      model: await ModelParser.parse('objects/moon.glb'),
      scale: Vector3.all(scale),
      position: position ?? Vector3.zero(),
    );
  }
}
