class_name RockThrower
extends Path2D

@export var min_throw_velocity := 50.0;
@export var max_throw_velocity := 100.0;

@onready var rock_throw_timer: Timer = get_node("RockThrowTimer");
@onready var rock_spawn_location: PathFollow2D = get_node("RockSpawnLocation");

signal on_throw_rock;

func _ready() -> void:
	rock_throw_timer.timeout.connect(_on_rock_throw_timer_timeout);

func start() -> void:
	rock_throw_timer.start();

func stop() -> void:
	rock_throw_timer.stop();

func throw_rock() -> void:
	var rock := AsteroidManager.spawn_asteroid();
	_set_rock_start_position(rock);
	on_throw_rock.emit();
	
func _on_rock_throw_timer_timeout() -> void:
	throw_rock();
	
func set_rock_throw_interval(new_interval: float) -> void:
	rock_throw_timer.wait_time = new_interval;

func _calculate_screen_quadrant(global_pos: Vector2) -> int:
	var screen_size := get_viewport_rect().size;
	var x_quad := 0;
	var y_quad := 0;
	if (global_pos.x > screen_size.x / 2):
		x_quad = 1;
	if (global_pos.y > screen_size.y / 2):
		y_quad = 2;
	
	return x_quad + y_quad;

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

	return 0.0;

func _set_rock_start_position(rock: Asteroid) -> void:
	rock_spawn_location.progress_ratio = randf();
	var starting_position := rock_spawn_location.global_position;
	var starting_rotation := _get_screen_quadrant_rotation(
		_calculate_screen_quadrant(starting_position)
	);
	var starting_velocity := Vector2(randf_range(min_throw_velocity, max_throw_velocity), 0.0).rotated(starting_rotation);

	rock.global_position = starting_position;
	rock.global_rotation = starting_rotation;
	rock.velocity = starting_velocity;

	if (rock.is_position_overlapping()):
		print("RECAST");
		return _set_rock_start_position(rock);
