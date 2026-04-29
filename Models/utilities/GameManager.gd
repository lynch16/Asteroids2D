class_name GameManager;
extends Node

signal game_start;
signal game_stop;

var started: bool = false;

@onready var pause_menu: PauseMenu = %PauseMenu;

@export var levels: Array[PackedScene] = [];
var current_level_idx: int = -1;
var active_level: Level;

func _ready() -> void:
	on_start();

func on_start() -> void:
	started = true;
	game_start.emit();
	start_next_level();

func trigger_game_over() -> void:
	print("GAME OVER");
	get_tree().paused = true;

func _get_active_level() -> Level:
	return levels.get(current_level_idx);

func start_next_level() -> void:
	current_level_idx += 1;
	if (current_level_idx >= levels.size()):
		print("YOU WON");
		return;

	var new_level_scene: PackedScene = levels.get(current_level_idx); 
	var new_level: Level = new_level_scene.instantiate();
	new_level.is_active = true;

	if (current_level_idx == 0):
		new_level.player_spawn_in_quadrant = true; 

	active_level = new_level;
	add_child(active_level);
	new_level.win_condition_met.connect(_on_next_level);

func _on_next_level() -> void:
	active_level.queue_free();
	start_next_level();
