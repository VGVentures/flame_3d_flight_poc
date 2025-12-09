import 'package:flame_3d_flight_poc/app/app.dart';
import 'package:flame_3d_flight_poc/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
