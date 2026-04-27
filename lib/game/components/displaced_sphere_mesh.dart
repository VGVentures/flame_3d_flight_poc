import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// A sphere mesh where each vertex is displaced outward along its normal
/// by an amount sampled from a grayscale elevation map.
class DisplacedSphereMesh extends Mesh {
  DisplacedSphereMesh({
    required double radius,
    required ui.Image heightmap,
    required ByteData heightmapData,
    int segments = 64,
    double displacementScale = 0.5,
    Material? material,
  }) {
    final w = heightmap.width;
    final h = heightmap.height;

    final vertices = <Vertex>[];

    for (var i = 0; i <= segments; i++) {
      final theta = i * (2 * math.pi) / segments;
      for (var j = 0; j <= segments; j++) {
        final phi = j * math.pi / segments;

        // Outward unit direction on the sphere.
        final nx = math.sin(phi) * math.cos(theta);
        final ny = math.cos(phi);
        final nz = math.sin(phi) * math.sin(theta);

        final u = i / segments;
        final v = j / segments;

        // Bilinear sample from elevation map for smooth transitions.
        final elevation = _sample(heightmapData, w, h, u, v);

        final r = radius + elevation * displacementScale;

        vertices.add(
          Vertex(
            position: Vector3(nx * r, ny * r, nz * r),
            texCoord: Vector2(u, v),
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

    addSurface(
      Surface(vertices: vertices, indices: indices, material: material),
    );
  }

  static double _sample(ByteData data, int w, int h, double u, double v) {
    final fx = u * w;
    final fy = v * h;
    final x0 = fx.floor().clamp(0, w - 1);
    final y0 = fy.floor().clamp(0, h - 1);
    final x1 = (x0 + 1).clamp(0, w - 1);
    final y1 = (y0 + 1).clamp(0, h - 1);
    final tx = fx - x0;
    final ty = fy - y0;

    double s(int x, int y) => data.getUint8((y * w + x) * 4) / 255.0;
    return s(x0, y0) * (1 - tx) * (1 - ty) +
        s(x1, y0) * tx * (1 - ty) +
        s(x0, y1) * (1 - tx) * ty +
        s(x1, y1) * tx * ty;
  }
}
