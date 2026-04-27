class_name DealDamage
extends Node

@export var combat_stats: CombatStats;
var hit_log: HitLog;

func _init(
	p_combat_stats: CombatStats,
	p_hit_log: HitLog = null
) -> void:
	combat_stats = p_combat_stats;
	hit_log = p_hit_log;

func damage(node: Node) -> void:
	var damageable := Damageable.get_damageable(node);
	if (damageable):
		if (hit_log != null):
			if (hit_log.has_hit(damageable)):
				return;
			else:
				hit_log.log_hit(damageable);

		damageable.on_damage(combat_stats.get_damage(), owner);
