import 'dart:math' as math;
import 'dart:ui';

class Particle {
  Particle({
    required this.position,
    required this.basePosition,
    required this.density,
  });

  Offset position;
  final Offset basePosition;
  final double density;

  void update() {
    final dx = basePosition.dx - position.dx;
    final dy = basePosition.dy - position.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final forceDirectionX = dx / distance;
    final forceDirectionY = dy / distance;

    const maxDistance = 280;
    final force = (maxDistance - distance) / maxDistance;
    final directionX = forceDirectionX * force * density;
    final directionY = forceDirectionY * force * density;

    // Apply slow movement when close to the base position
    if (distance < 30) {
      position += Offset(directionX * 0.01, directionY * 0.01);
    } else if (distance < maxDistance) {
      position += Offset(directionX * 2.5, directionY * 2.5);
    } else {
      double currentPositionX = position.dx;
      double currentPositionY = position.dy;
      if (position.dx != basePosition.dx) {
        final dx = position.dx - basePosition.dx;
        currentPositionX -= (dx / 10);
      }

      if (position.dy != basePosition.dy) {
        final dy = position.dy - basePosition.dy;
        currentPositionY -= (dy / 10);
      }
      position = Offset(currentPositionX, currentPositionY);
    }
  }
}
