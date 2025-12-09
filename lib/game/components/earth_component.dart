import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/parser.dart';
import 'package:flame_3d_flight_poc/game/game.dart';

class EarthComponent extends ModelComponent
    with HasGameReference<Flame3dFlightPoc> {
  EarthComponent({required super.model, super.scale});

  static Future<EarthComponent> spawn({double scale = 1}) async {
    return EarthComponent(
      model: await ModelParser.parse('objects/earth.glb'),
      scale: Vector3.all(scale)
    );
  }
}
