class_name ApplyDamageResult
extends DamageResult

func on_damage(dmg: float, damager_node: Node) -> bool: 
	damageable.on_damage(dmg, damager_node);
	return true;
