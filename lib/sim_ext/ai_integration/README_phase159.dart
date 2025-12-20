/// Phase 159: Integration notes (kept as a Dart doc file to avoid extra tooling).
///
/// Next step (tiny adapter, optional):
/// Implement CommandSink in game layer and forward CommandEnvelope to your
/// existing game/commands or simulation/intent_queue types.
///
/// This phase intentionally avoids importing game/commands to keep CI stable.
const String phase159Notes = 'AI injection bridge ready. Implement CommandSink adapter in game layer.';
