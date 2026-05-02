class_name RockThrower
extends SpawnPath2D

@export var min_throw_velocity := 50.0;
@export var max_throw_velocity := 100.0;

@onready var rock_throw_timer: Timer = get_node("RockThrowTimer");

signal on_throw_rock;

func _ready() -> void:
	rock_throw_timer.timeout.connect(_on_rock_throw_timer_timeout);

func start() -> void:
	rock_throw_timer.start();

func stop() -> void:
	rock_throw_timer.stop();

func throw_rock() -> void:
	var rock := AsteroidManager.spawn_asteroid();
	set_start_position_velocity(rock);
	on_throw_rock.emit();
	
func _on_rock_throw_timer_timeout() -> void:
	throw_rock();
	
func set_rock_throw_interval(new_interval: float) -> void:
	rock_throw_timer.wait_time = new_interval;
