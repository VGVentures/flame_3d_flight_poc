import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d_flight_poc/game/game.dart';
import 'package:flame_3d_flight_poc/l10n/l10n.dart';
import 'package:flutter/painting.dart';

enum MoveDirection {
  forward,
  backward,
  left,
  right,
  up,
  down,
  pitchUp,
  pitchDown,
}

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

  static const double _earthRadius = 10;
  static const double _minAltitude = _earthRadius + 0.05;
  static const double _maxAltitude = _earthRadius + 30;
  static const double _altitudeSpeed = 5; // units/s
  static const double _moveSpeed = 0.8; // radians/s — orbiting speed
  static const double _lookSpeed = 1; // radians/s — turning speed
  static const double _pitchSpeed = 1; // radians/s
  static const double _maxPitch = math.pi / 3; // ±60°

  double _cameraRadius = _minAltitude;
  double _pitchAngle = 0;

  // Unit vector from Earth center toward the camera.
  final Vector3 _cameraDir = Vector3(0, 1, 0);

  // Unit vector tangent to the sphere in the direction the camera faces.
  // Always perpendicular to _cameraDir.
  final Vector3 _cameraForward = Vector3(1 / math.sqrt2, 0, 1 / math.sqrt2);

  final Set<MoveDirection> _activeDirections = {};
  late CameraComponent3D _camera3d;

  void startMove(MoveDirection direction) => _activeDirections.add(direction);
  void stopMove(MoveDirection direction) => _activeDirections.remove(direction);

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    final earth = EarthComponent(radius: _earthRadius);
    final moon = await MoonComponent.spawn(
      scale: 0.5,
      position: earth.position + Vector3(20, 20, 0),
    );

    final world = World3D(
      children: [
        LightComponent.ambient(intensity: 20),
        MilkyWayComponent(),
        earth,
        moon,
      ],
    );

    this.world = world;

    _camera3d = CameraComponent3D(world: world);
    camera = _camera3d;
    _updateCamera();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_activeDirections.isEmpty) return;

    // Right axis: perpendicular to both cameraDir and cameraForward.
    final right = _cameraDir.cross(_cameraForward);

    if (_activeDirections.contains(MoveDirection.forward)) {
      // Orbit camera position along the sphere in the facing direction.
      _rotateVec(_cameraDir, right, _moveSpeed * dt);
      _rotateVec(_cameraForward, right, _moveSpeed * dt);
    }
    if (_activeDirections.contains(MoveDirection.backward)) {
      _rotateVec(_cameraDir, right, -_moveSpeed * dt);
      _rotateVec(_cameraForward, right, -_moveSpeed * dt);
    }
    if (_activeDirections.contains(MoveDirection.left)) {
      // Rotate heading around the up axis — camera turns in place.
      _rotateVec(_cameraForward, _cameraDir, _lookSpeed * dt);
    }
    if (_activeDirections.contains(MoveDirection.right)) {
      _rotateVec(_cameraForward, _cameraDir, -_lookSpeed * dt);
    }
    if (_activeDirections.contains(MoveDirection.up)) {
      _cameraRadius = (_cameraRadius + _altitudeSpeed * dt).clamp(
        _minAltitude,
        _maxAltitude,
      );
    }
    if (_activeDirections.contains(MoveDirection.down)) {
      _cameraRadius = (_cameraRadius - _altitudeSpeed * dt).clamp(
        _minAltitude,
        _maxAltitude,
      );
    }
    if (_activeDirections.contains(MoveDirection.pitchUp)) {
      _pitchAngle = (_pitchAngle + _pitchSpeed * dt).clamp(
        -_maxPitch,
        _maxPitch,
      );
    }
    if (_activeDirections.contains(MoveDirection.pitchDown)) {
      _pitchAngle = (_pitchAngle - _pitchSpeed * dt).clamp(
        -_maxPitch,
        _maxPitch,
      );
    }

    // Gram-Schmidt re-orthogonalization to prevent floating-point drift.
    _cameraDir.normalize();
    _cameraForward
      ..addScaled(_cameraDir, -_cameraDir.dot(_cameraForward))
      ..normalize();

    _updateCamera();
  }

  // Rodrigues' rotation formula — rotates [v] in-place around [axis]
  // by [angle] radians.
  void _rotateVec(Vector3 v, Vector3 axis, double angle) {
    final k = axis.normalized();
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final kCrossV = k.cross(v);
    final kDotV = k.dot(v);
    v
      ..scale(cosA)
      ..addScaled(kCrossV, sinA)
      ..addScaled(k, kDotV * (1 - cosA));
  }

  void _updateCamera() {
    _camera3d.position = _cameraDir * _cameraRadius;
    // Rotate look direction toward _cameraDir (up) by _pitchAngle.
    final cosP = math.cos(_pitchAngle);
    final sinP = math.sin(_pitchAngle);
    final lookDir = _cameraForward * cosP + _cameraDir * sinP;
    _camera3d.target = _camera3d.position + lookDir * 0.1;
    _camera3d.up = _cameraDir;
  }
}
