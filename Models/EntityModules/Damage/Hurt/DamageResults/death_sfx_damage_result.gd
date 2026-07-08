class_name DeathSfxDamageResult 
extends SfxDamageResult

func on_damage(damage_dealt: float, dmgr: Node, hit_position: Vector2, hit_angle: float) -> bool:
	if (damageable.health_stats.current_health <= 0.0):
		return super(damage_dealt, dmgr, hit_position, hit_angle);

	return true;