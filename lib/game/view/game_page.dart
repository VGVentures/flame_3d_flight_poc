import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart' hide Route;
import 'package:flame_3d_flight_poc/game/game.dart';
import 'package:flame_3d_flight_poc/gen/assets.gen.dart';
import 'package:flame_3d_flight_poc/l10n/l10n.dart';
import 'package:flame_3d_flight_poc/loading/cubit/cubit.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const GamePage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final audioCache = context.read<PreloadCubit>().audio;
        return AudioCubit(
          audioPlayer: AudioPlayer()..audioCache = audioCache,
          backgroundMusic: Bgm(audioCache: audioCache),
        );
      },
      child: const Scaffold(body: GameView()),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, this.game});

  final FlameGame? game;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  FlameGame? _game;

  late final Bgm bgm;

  @override
  void initState() {
    super.initState();
    bgm = context.read<AudioCubit>().bgm;
    unawaited(bgm.play(Assets.audio.background));
  }

  @override
  void dispose() {
    unawaited(bgm.pause());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 4);

    _game ??=
        widget.game ??
        Flame3dFlightPoc(
          l10n: context.l10n,
          effectPlayer: context.read<AudioCubit>().effectPlayer,
          textStyle: textStyle,
          images: context.read<PreloadCubit>().images,
        );
    return Stack(
      children: [
        Positioned.fill(child: GameWidget(game: _game!)),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: BlocBuilder<AudioCubit, AudioState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () => context.read<AudioCubit>().toggleVolume(),
                );
              },
            ),
          ),
        ),
        if (_game is Flame3dFlightPoc)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _DPadControls(game: _game! as Flame3dFlightPoc),
              ),
            ),
          ),
        if (_game is Flame3dFlightPoc)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _PitchControls(game: _game! as Flame3dFlightPoc),
              ),
            ),
          ),
        if (_game is Flame3dFlightPoc)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _AltitudeControls(game: _game! as Flame3dFlightPoc),
              ),
            ),
          ),
      ],
    );
  }
}

class _DPadControls extends StatelessWidget {
  const _DPadControls({required this.game});

  final Flame3dFlightPoc game;

  @override
  Widget build(BuildContext context) {
    const size = 48.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: size),
            _ArrowButton(
              icon: Icons.keyboard_arrow_up,
              onStart: () => game.startMove(MoveDirection.forward),
              onStop: () => game.stopMove(MoveDirection.forward),
            ),
            const SizedBox(width: size),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowButton(
              icon: Icons.keyboard_arrow_left,
              onStart: () => game.startMove(MoveDirection.left),
              onStop: () => game.stopMove(MoveDirection.left),
            ),
            const SizedBox(width: size),
            _ArrowButton(
              icon: Icons.keyboard_arrow_right,
              onStart: () => game.startMove(MoveDirection.right),
              onStop: () => game.stopMove(MoveDirection.right),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: size),
            _ArrowButton(
              icon: Icons.keyboard_arrow_down,
              onStart: () => game.startMove(MoveDirection.backward),
              onStop: () => game.stopMove(MoveDirection.backward),
            ),
            const SizedBox(width: size),
          ],
        ),
      ],
    );
  }
}

class _AltitudeControls extends StatelessWidget {
  const _AltitudeControls({required this.game});

  final Flame3dFlightPoc game;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowButton(
          icon: Icons.add,
          onStart: () => game.startMove(MoveDirection.up),
          onStop: () => game.stopMove(MoveDirection.up),
        ),
        const SizedBox(height: 8),
        _ArrowButton(
          icon: Icons.remove,
          onStart: () => game.startMove(MoveDirection.down),
          onStop: () => game.stopMove(MoveDirection.down),
        ),
      ],
    );
  }
}

class _PitchControls extends StatelessWidget {
  const _PitchControls({required this.game});

  final Flame3dFlightPoc game;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowButton(
          icon: Icons.keyboard_arrow_up,
          onStart: () => game.startMove(MoveDirection.pitchUp),
          onStop: () => game.stopMove(MoveDirection.pitchUp),
        ),
        const SizedBox(height: 8),
        _ArrowButton(
          icon: Icons.keyboard_arrow_down,
          onStart: () => game.startMove(MoveDirection.pitchDown),
          onStop: () => game.stopMove(MoveDirection.pitchDown),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onStart,
    required this.onStop,
  });

  final IconData icon;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onStart(),
      onTapUp: (_) => onStop(),
      onTapCancel: onStop,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color.fromARGB(51, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
