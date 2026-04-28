class_name ParticlesDamageResult
extends DamageResult

func on_damage(dmg: float, _damager_node: Node, hit_position: Vector2, hit_angle: float) -> bool: 
	damageable.combat_stats.take_damage(dmg);
	var particles := AsteroidDamageParticles.new();
	particles.global_position = hit_position;
	particles.global_rotation = hit_angle;
	get_tree().current_scene.add_child(particles);
	return true;
