class_name Level
extends Node2D

@export var is_active: bool = false;
@export_group("Rock Thrower Settings")
## How many rocks to seed the level with
@export var num_starting_rocks := 1; 
## How quickly to throw rocks during the game
@export var rock_throw_interval := 0.0; 
## How many rocks to throw during the game
@export var num_rocks_to_throw := 5; 
## How long to wait after the level starts to begin throwing rocks
@export var rock_thrower_start_delay := 10.0; 

@export_group("Player Spawn Settings")
## Wether to use real positioning or auto-positioning for Player start position
@export var player_spawn_in_quadrant := false; 
## Where to spawn. Only used if player_spawn_in_quadrant is true
@export var spawn_in_quadrant := 0; 
## Buffer in pixels from the edge on which to spawn a character
@export var spawn_quadrant_buffer := 200;

@onready var player: Player = %Player;
@onready var game_area: GameArea = %GameArea;
@onready var rock_thrower: RockThrower = %RockThrower;

var start_rocks_timer: Timer;
var current_rocks_thrown := 0;

signal level_loaded;
signal win_condition_met;

func _ready() -> void:
	enter();
	level_loaded.emit();

func enter() -> void:
	add_to_group("level");

	rock_thrower.on_throw_rock.connect(_on_rock_thrown);
	for i in num_starting_rocks:
		rock_thrower.throw_rock();

	if (rock_thrower_start_delay > 0.0):
		start_rocks_timer = Timer.new();
		start_rocks_timer.wait_time = rock_thrower_start_delay;
		start_rocks_timer.one_shot = true;
		start_rocks_timer.autostart = true;
		start_rocks_timer.timeout.connect(_on_start_rocks_timer_timeout);
		add_child(start_rocks_timer);

	tree_exiting.connect(_on_tree_exiting);

	if (player_spawn_in_quadrant):
		player.global_position = _get_screen_quadrant_position(spawn_in_quadrant);
		player.global_rotation = _get_screen_quadrant_rotation(spawn_in_quadrant);

func _process(_delta: float) -> void:
	if (is_active):
		_check_win_condition();

	# Stop throwing rocks at limit
	if (current_rocks_thrown >= num_starting_rocks + num_rocks_to_throw):
		rock_thrower.stop();

func exit() -> void:
	rock_thrower.stop();

func _on_tree_exiting() -> void:
	exit();

func _on_start_rocks_timer_timeout() -> void:
	start_rocks_timer.queue_free();
	
	if (rock_throw_interval > 0.0):
		rock_thrower.set_rock_throw_interval(rock_throw_interval);
		rock_thrower.start();

func _check_win_condition() -> void:
	if (AsteroidManager.get_asteroid_count() == 0):
		win_condition_met.emit();

func _get_screen_quadrant_position(quadrant: int) -> Vector2:
	var x_pos_min := 0.0;
	var x_pos_max := 0.0;
	var y_pos_min := 0.0;
	var y_pos_max := 0.0;

	match(quadrant):
		# Top left
		0:
			x_pos_min = 0.0;
			x_pos_max = get_viewport_rect().size.x / 2.0;
			y_pos_min = 0.0;
			y_pos_max = get_viewport_rect().size.y / 2.0;
		# Top right
		1:
			x_pos_min = get_viewport_rect().size.x / 2.0;
			x_pos_max = get_viewport_rect().size.x;
			y_pos_min = 0.0;
			y_pos_max = get_viewport_rect().size.y / 2.0;
		# Bottom right
		2:
			x_pos_min = get_viewport_rect().size.x / 2.0;
			x_pos_max = get_viewport_rect().size.x;
			y_pos_min = get_viewport_rect().size.y / 2.0;
			y_pos_max = get_viewport_rect().size.y;
		# Bottom left
		3:
			x_pos_min = 0.0;
			x_pos_max = get_viewport_rect().size.x / 2.0;
			y_pos_min = get_viewport_rect().size.y / 2.0;
			y_pos_max = get_viewport_rect().size.y;

	x_pos_min = clampf(x_pos_min, spawn_quadrant_buffer, get_viewport_rect().size.x - spawn_quadrant_buffer);
	x_pos_max = clampf(x_pos_max, spawn_quadrant_buffer, get_viewport_rect().size.x - spawn_quadrant_buffer);
	y_pos_min = clampf(y_pos_min, spawn_quadrant_buffer, get_viewport_rect().size.y - spawn_quadrant_buffer);
	y_pos_max = clampf(y_pos_max, spawn_quadrant_buffer, get_viewport_rect().size.y - spawn_quadrant_buffer);

	return Vector2(randf_range(x_pos_min, x_pos_max), randf_range(y_pos_min, y_pos_max));


func _get_screen_quadrant_rotation(quadrant: int) -> float:
	match(quadrant):
		# Top left
		0:
			return randf_range(PI/4.0, 3.0*PI/4.0);
		# Top right
		1:
			return randf_range(3.0*PI/4.0, 5.0*PI/4.0);
		# Bottom right
		2:
			return randf_range(5.0*PI/4.0, 7.0*PI/4.0);
		# Bottom left
		3:
			return randf_range(7.0*PI/4.0, 9.0*PI/4.0);	

	return 0.0

func _on_rock_thrown() -> void:
	current_rocks_thrown += 1;
