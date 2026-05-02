class_name SpawnShapeCast2D
extends ShapeCast2D

var safe_collision_time := 5.0;

func will_position_collide(
	velocity: Vector2,
	ignored_colliders: Array[Hurtbox2D],
	free_on_no_collision: bool = true
) -> bool:
	target_position = velocity * safe_collision_time;
	for collider in ignored_colliders:
		add_exception(collider);

	force_shapecast_update();

	if (free_on_no_collision && !is_colliding()):
		queue_free();

	return is_colliding();