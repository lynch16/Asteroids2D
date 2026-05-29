class_name StopOnDeathDamageResult
extends DamageResult

@export var health_stats: HealthStats;

func on_damage(_damage_dealt: float, _dmgr: Node, _hit_position: Vector2, _hit_angle: float) -> bool:
	if (health_stats.current_health <= 0.0):
		return false;
	return true;
