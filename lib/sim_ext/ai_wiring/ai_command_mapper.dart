import '../ai/ai_types.dart';
import 'command_envelope.dart';

/// Phase 124–127: Maps AI decisions to engine-agnostic command envelopes.
/// Later phases can translate these envelopes into real game/commands.
class AiCommandMapper {
  /// Deterministic mapping with explicit payload schema.
  static CommandEnvelope map(AiDecision d) {
    switch (d.action.type) {
      case 'ATTACK':
        return CommandEnvelope(
          tick: d.tick,
          agentId: d.agentId,
          commandType: 'ATTACK_NEAREST',
          payload: {
            'mode': d.meta['mode'] ?? 'unknown',
          },
        );
      case 'RETREAT':
        return CommandEnvelope(
          tick: d.tick,
          agentId: d.agentId,
          commandType: 'RETREAT_TO_SAFETY',
          payload: {
            'mode': d.meta['mode'] ?? 'unknown',
          },
        );
      case 'GATHER':
        return CommandEnvelope(
          tick: d.tick,
          agentId: d.agentId,
          commandType: 'GATHER_RESOURCES',
          payload: {
            'mode': d.meta['mode'] ?? 'unknown',
          },
        );
      case 'SCOUT':
        return CommandEnvelope(
          tick: d.tick,
          agentId: d.agentId,
          commandType: 'SCOUT_AREA',
          payload: {
            'mode': d.meta['mode'] ?? 'unknown',
          },
        );
      case 'IDLE':
      default:
        return CommandEnvelope(
          tick: d.tick,
          agentId: d.agentId,
          commandType: 'NOOP',
          payload: {
            'mode': d.meta['mode'] ?? 'unknown',
          },
        );
    }
  }
}
