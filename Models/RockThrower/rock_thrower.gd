extends Path2D

@export var min_throw_velocity := 50.0;
@export var max_throw_velocity := 100.0;

func _ready() -> void:
	$RockThrowTimer.timeout.connect(_on_rock_throw_timer_timeout);

func start() -> void:
	$RockThrowTimer.start();
	
func _on_rock_throw_timer_timeout() -> void:
	var rock := AsteroidManager.spawn_asteroid();
	var rock_spawn_location: PathFollow2D = $RockSpawnLocation;
	rock_spawn_location.progress_ratio = randf();
	
	rock.global_position = rock_spawn_location.global_position;
	
	# Start perpendicular then randomize the direction
	var direction := rock_spawn_location.rotation + PI/2;
	direction += randf_range(-PI/4, PI/4)
	rock.rotation = direction;
	
	var velocity := Vector2(randf_range(min_throw_velocity, max_throw_velocity), 0.0);
	rock.linear_velocity = velocity.rotated(direction);
	
