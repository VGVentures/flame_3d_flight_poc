import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_flight_poc/game/game.dart';

class MilkyWayComponent extends MeshComponent
    with HasGameReference<Flame3dFlightPoc> {
  MilkyWayComponent() : super(mesh: _buildInwardSphereMesh(radius: 800));

  static Mesh _buildInwardSphereMesh({
    required double radius,
    int segments = 128,
  }) {
    final vertices = <Vertex>[];
    for (var i = 0; i <= segments; i++) {
      final theta = i * (2 * math.pi) / segments;
      for (var j = 0; j <= segments; j++) {
        final phi = j * math.pi / segments;

        final sinPhi = math.sin(phi);
        final cosPhi = math.cos(phi);
        final sinTheta = math.sin(theta);
        final cosTheta = math.cos(theta);

        final x = radius * sinPhi * cosTheta;
        final y = radius * cosPhi;
        final z = radius * sinPhi * sinTheta;

        vertices.add(
          Vertex(
            position: Vector3(x, y, z),
            texCoord: Vector2(theta / (2 * math.pi), phi / math.pi),
            // Inward normals so the PBR shader sees the texture from inside
            normal: Vector3(-sinPhi * cosTheta, -cosPhi, -sinPhi * sinTheta),
          ),
        );
      }
    }

    final indices = <int>[];
    for (var i = 0; i < segments; i++) {
      for (var j = 0; j < segments; j++) {
        final first = i * (segments + 1) + j;
        final second = first + segments + 1;

        indices
          ..add(first)
          ..add(second)
          ..add(first + 1)
          ..add(second)
          ..add(second + 1)
          ..add(first + 1);
      }
    }

    return Mesh()..addSurface(Surface(vertices: vertices, indices: indices));
  }

  @override
  FutureOr<void> onLoad() async {
    final milkyWayTexture = await Flame.images.loadTexture(
      '2k_stars_milky_way.bmp',
    );
    mesh.updateSurfaces((surfaces) {
      // albedoColor compensates for the 20× ambient multiplier in the new
      // PBR shader: 0.031 × 0.96 × 20 ≈ 0.6, matching the old shader's output.
      surfaces[0].material = SpatialMaterial(
        albedoTexture: milkyWayTexture,
        albedoColor: const Color(0xFF080808),
        metallic: 0,
      );
    });
  }
}
