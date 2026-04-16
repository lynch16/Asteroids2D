class_name ApplyDamageResult
extends DamageResult

@onready var damageable: Damageable = get_parent();

func on_damage(dmg: float, _damager_node: Node) -> bool: 
	damageable.combat_stats.take_damage(dmg);
	return true;
