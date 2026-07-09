class_name GameManager
extends Node

signal game_start;
signal game_stop;
signal level_start(level_index: int);
signal player_lives_updated(lives_left: int);

@export var title_screen_scene: PackedScene;
@export var hud_scene: PackedScene;

@export var starting_level := 0;
@export var level_scene: PackedScene;
@export var levels: Array[LevelResource] = [];

@onready var pause_menu: PauseMenu = %PauseMenu;

var current_level_idx: int = 0;
var active_level: Level;
var started: bool = false;

@export var starting_player_lives := 3;
var player_lives: int;

func _ready() -> void:
	_load_title_screen();

func _load_title_screen() -> void:
	var title_screen: TitleScreen = title_screen_scene.instantiate();
	title_screen.start.connect(on_start);
	title_screen.exit_game.connect(_exit_game);
	add_child(title_screen);
	active_level = title_screen;

func _exit_game() -> void:
	get_tree().quit();

func on_start() -> void:
	if (active_level):
		active_level.queue_free();

	started = true;
	current_level_idx = starting_level;
	player_lives = starting_player_lives;
	var hud: HUD = hud_scene.instantiate();
	add_child(hud);
	game_start.emit();
	player_lives_updated.emit(player_lives);
	start_next_level();

func on_player_died() -> void:
	player_lives -= 1;
	player_lives_updated.emit(player_lives);

	if (player_lives <= 0):
		trigger_game_over();
	else:
		active_level.queue_free();
		start_next_level();

func trigger_game_over() -> void:
	print("GAME OVER");
	get_tree().paused = true;
	game_stop.emit();

func start_next_level() -> void:
	var new_level_settings: LevelResource = levels.get(current_level_idx); 
	var new_level: Level = level_scene.instantiate();
	new_level.level_settings = new_level_settings;
	new_level.is_active = true;

	active_level = new_level;
	add_child(active_level);
	new_level.win_condition_met.connect(_on_next_level);
	new_level.lose_condition_met.connect(on_player_died);
	level_start.emit(current_level_idx);

func _on_next_level() -> void:
	current_level_idx += 1;
	if (current_level_idx >= levels.size()):
		print("YOU WON");
		return;

	active_level.queue_free();
	start_next_level();
