class_name AsteroidShatterDamageResult
extends DamageResult

@export var shatter_limit := 50.0;
var child_angle_spread := PI/8;
var asteroid: Asteroid;
var max_shatter_times := 2;

var shatter_score := 100;
var shatter_last_score := 200;

# Run once after damageable is initialized
func on_init(attached_object: Variant) -> void:
	var new_scale := 1.0;
	
	if (attached_object is Asteroid):
		var resolved_type: Asteroid = attached_object;
		asteroid = resolved_type;
		new_scale = 1.0/(pow(2, asteroid.child_number));
	
	# Smaller asteroid will shatter and destroy with half the force
	shatter_limit = shatter_limit * new_scale;

# Break up asteroid based on sum of force applied - could come from weapons, ship or other bodies. At min size, dequeue
func on_damage(damage_amt: float, damager_node: Node) -> bool:
	shatter_limit -= damage_amt;
	
	var is_player_damage := damager_node.is_in_group("player_weapon");
	
	if (shatter_limit <= 0):
		if (is_player_damage):
			var score := shatter_score if asteroid.child_number < max_shatter_times else shatter_last_score;
			ScoreManager._update_score(score);
		
		if (asteroid.child_number < max_shatter_times):
			var child_aster1 := AsteroidManager.spawn_asteroid(asteroid);
			var child_aster2 := AsteroidManager.spawn_asteroid(asteroid);
		
			call_deferred("_apply_parent_force_to_child", asteroid, child_aster1);
			call_deferred("_apply_parent_force_to_child", asteroid, child_aster2);
		
		on_end();
		
		return true;
	
	
	return false;
#
func _apply_parent_force_to_child(parent_aster: Asteroid, child_aster: Asteroid) -> void:
	child_aster.position = parent_aster.position;
	child_aster.global_position = parent_aster.global_position;
	child_aster.linear_velocity = parent_aster.linear_velocity;
	
	# Start perpendicular then randomize the direction
	var direction := parent_aster.rotation + PI/2;
	direction += randf_range(-PI/4, PI/4)
	child_aster.rotation = direction;

	# Launch child off in semi-random direction
	var impact_force := Vector2(
		randf_range(0, 100),
		randf_range(0, 100),
	)
	var rand_rotation := randf_range(-child_angle_spread, child_angle_spread);
	var rotated_force := impact_force.rotated((impact_force.angle() + rand_rotation)) ;
	child_aster.apply_central_impulse(rotated_force); 
