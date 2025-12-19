import 'package:flutter/material.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';

class Hud extends StatelessWidget {
  final WorldState world;
  final EntityId? selected;

  const Hud({super.key, required this.world, required this.selected});

  @override
  Widget build(BuildContext context) {
    final sel = selected;
    String line1 = "Entities: ${world.entityCount}";
    String line2 = "Selected: -";

    if (sel != null && world.exists(sel)) {
      final hp = world.health[sel];
      final team = world.teams[sel]?.id;
      line2 = "Selected: ${sel.value}  Team: ${team ?? '-'}  HP: ${hp?.current ?? 0}/${hp?.max ?? 0}";
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xAA000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line1),
            const SizedBox(height: 4),
            Text(line2),
            const SizedBox(height: 6),
            const Text("Tap unit to select. Tap empty space to move selected."),
          ],
        ),
      ),
    );
  }
}
