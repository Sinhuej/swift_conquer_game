import 'package:test/test.dart';
import 'package:swift_conquer_game/sim_ext/ai/ai_types.dart';
import 'package:swift_conquer_game/sim_ext/ai_wiring/ai_command_mapper.dart';

void main() {
  test('AI decision maps deterministically to command envelope', () {
    final d = AiDecision(
      tick: 120,
      agentId: 'ai-1',
      action: const AiAction('ATTACK'),
      meta: const {'mode': 'greedy'},
    );

    final c1 = AiCommandMapper.map(d).toJson();
    final c2 = AiCommandMapper.map(d).toJson();

    expect(c1, equals(c2));
    expect(c1['commandType'], equals('ATTACK_NEAREST'));
  });
}
