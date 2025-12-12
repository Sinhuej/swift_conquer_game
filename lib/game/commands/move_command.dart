import 'game_command.dart';

class MoveCommand extends GameCommand {
  final int unitId;
  final double x;
  final double y;

  MoveCommand(this.unitId, this.x, this.y);

  @override
  void execute() {
    // Hook into MovementSystem later
  }
}
