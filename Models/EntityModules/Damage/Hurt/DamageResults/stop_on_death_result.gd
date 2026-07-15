class_name StopOnDeathDamageResult
extends DamageResult

func on_damage(_damage_dealt: float, _dmgr: Node, _hit_position: Vector2, _hit_angle: float) -> bool:
	if (damageable.health_stats.current_health <= 0.0):
		return false;
	return true;
