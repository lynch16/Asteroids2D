extends Path2D

@export var asteroid_scene: PackedScene;
@export var min_throw_velocity = 150.0;
@export var max_throw_velocity = 250.0;

func _ready():
	$RockThrowTimer.timeout.connect(_on_rock_throw_timer_timeout);

func start():
	$RockThrowTimer.start();
	
func _on_rock_throw_timer_timeout():
	var rock: RigidBody2D = asteroid_scene.instantiate();
	var rock_spawn_location = $RockSpawnLocation;
	rock_spawn_location.progress_ratio = randf();
	
	rock.position = rock_spawn_location.position;
	
	# Start perpendicular then randomize the direction
	var direction = rock_spawn_location.rotation + PI/2;
	direction += randf_range(-PI/4, PI/4)
	rock.rotation = direction;
	
	print(direction) # TODO: This is causing issues for asteroids with directions less than 3. They spawn and are deleted.
	
	var velocity = Vector2(randf_range(min_throw_velocity, max_throw_velocity), 0.0);
	rock.linear_velocity = velocity.rotated(direction);
	
	add_child(rock);
	
