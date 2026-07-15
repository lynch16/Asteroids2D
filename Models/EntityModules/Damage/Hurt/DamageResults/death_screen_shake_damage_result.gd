class_name DeathScreenShakeDamageResult extends ScreenShakeDamageResult

func on_damage(_dmg: float, _damager_node: Node, _hit_position: Vector2, _hit_angle: float) -> bool:
	if (damageable.health_stats.current_health <= 0.0):
		return super(_dmg, _damager_node, _hit_position, _hit_angle);

	return true;
