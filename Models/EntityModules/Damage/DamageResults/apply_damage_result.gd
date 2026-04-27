class_name ApplyDamageResult
extends DamageResult

func on_damage(dmg: float, _damager_node: Node) -> bool: 
	damageable.combat_stats.take_damage(dmg);
	return true;
