class_name SpawnPath2D
extends Path2D

var path_follow: PathFollow2D;
var viewport_buffer := 200.0;

@export var min_spawn_velocity := 50.0;
@export var max_spawn_velocity := 100.0;

func _enter_tree() -> void:
	var screen_size := get_viewport_rect().size;

	var path_curve := Curve2D.new();
	path_curve.add_point(
		Vector2(-viewport_buffer, -viewport_buffer)
	);
	path_curve.add_point(
		Vector2(screen_size.x + viewport_buffer, -viewport_buffer)
	);
	path_curve.add_point(
		Vector2(screen_size.x + viewport_buffer, screen_size.y + viewport_buffer)
	);
	path_curve.add_point(
		Vector2(-viewport_buffer, screen_size.y + viewport_buffer)
	);
	curve = path_curve;

	path_follow = PathFollow2D.new();
	add_child(path_follow);

func _calculate_screen_quadrant(global_pos: Vector2) -> int:
	var screen_size := get_viewport_rect().size;
	var x_quad := 0;
	var y_quad := 0;
	if (global_pos.x > screen_size.x / 2):
		x_quad = 1;
	if (global_pos.y > screen_size.y / 2):
		y_quad = 2;
	
	return x_quad + y_quad;

## Get random rotation that faces internally dependending on what quadrant is provided
func _get_screen_quadrant_rotation(quadrant: int) -> float:
	match(quadrant):
		# Top left
		0:
			return randf_range(2.5 * PI, 2.0 * PI);
		# Top right
		1:
			return randf_range(0.5 * PI, 1.0*PI); 
		# Bottom left
		2:
			return randf_range(1.5 * PI, 2.0 * PI);
		# Bottom right
		3:
			return randf_range(1.0 * PI, 1.5 * PI);	

	return 0.0

func set_start_position_velocity(
	character: SpawnableCharacter2D,
	hitboxes_to_ignore: Array[Hurtbox2D] = []
) -> void:
	path_follow.progress_ratio = randf();
	var starting_position := path_follow.global_position;
	var starting_rotation := _get_screen_quadrant_rotation(
		_calculate_screen_quadrant(starting_position)
	);
	var starting_velocity := Vector2(randf_range(min_spawn_velocity, max_spawn_velocity), 0.0).rotated(starting_rotation);

	character.global_position = starting_position;
	character.global_rotation = starting_rotation;
	character.velocity = starting_velocity;

	if (character.is_position_overlapping(hitboxes_to_ignore)):
		return set_start_position_velocity(character, hitboxes_to_ignore);
