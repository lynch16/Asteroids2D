class_name ApplyDamageResult
extends DamageResult

func on_damage(dmg: float, _damager_node: Node, _hit_position: Vector2) -> bool: 
	damageable.combat_stats.take_damage(dmg);
	return true;
