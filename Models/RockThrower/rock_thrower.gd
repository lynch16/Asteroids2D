extends Path2D

@export var min_throw_velocity := 50.0;
@export var max_throw_velocity := 100.0;

@onready var rock_throw_timer: Timer = get_node("RockThrowTimer");
@onready var rock_spawn_location: PathFollow2D = get_node("RockSpawnLocation");

func _ready() -> void:
	rock_throw_timer.timeout.connect(_on_rock_throw_timer_timeout);

func start() -> void:
	rock_throw_timer.start();
	
func throw_rock() -> void:
	var rock := AsteroidManager.spawn_asteroid();
	rock_spawn_location.progress_ratio = randf();
	
	# TODO: This positioning should be contained within spawn_asteroid
	rock.global_position = rock_spawn_location.global_position;
	
	# Start perpendicular then randomize the direction
	var direction := rock_spawn_location.rotation + PI/2;
	direction += randf_range(0, PI)
	rock.global_rotation = direction;
	
	var velocity := Vector2(randf_range(min_throw_velocity, max_throw_velocity), 0.0);
	rock.linear_velocity = velocity.rotated(direction);
	
func _on_rock_throw_timer_timeout() -> void:
	throw_rock();
	
