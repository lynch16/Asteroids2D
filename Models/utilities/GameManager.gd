class_name GameManager
extends Node

signal game_start;
signal game_stop;
signal level_start(level_index: int, level: Level);
signal player_lives_updated(lives_left: int);

@export var title_screen_scene: PackedScene;
@export var hud_scene: PackedScene;

@export var starting_level := 0;
@export var level_scene: PackedScene;
@export var levels: Array[LevelResource] = [];

@export var player_health: HealthStats;

@onready var pause_menu: PauseMenu = %PauseMenu;
@onready var music_player: MusicPlayer = $MusicPlayer;
@onready var game_over_screen: EndPlayScreen = $GameOverScreen;
@onready var win_screen: EndPlayScreen = $WinScreen;

var current_level_idx: int = 0;
var active_level: Level;
var started: bool = false;
var hud: HUD;

@export var starting_player_lives := 3;
var player_lives: int;

func _ready() -> void:
	pause_menu.on_show.connect(music_player.play_pause_music);
	pause_menu.on_hide.connect(_restart_level_music);
	music_player.play_title_music();

	_load_title_screen();

func _restart_level_music() -> void:
	if (started):
		music_player.play_level_music();
	else:
		music_player.play_title_music();

func _load_title_screen() -> void:
	var title_screen: TitleScreen = title_screen_scene.instantiate();
	title_screen.start.connect(on_start);
	title_screen.exit_game.connect(_exit_game);
	add_child(title_screen);
	active_level = title_screen;

func _exit_game() -> void:
	get_tree().quit();

func on_start() -> void:
	pause_menu.start_monitoring();

	if (active_level):
		active_level.queue_free();

	started = true;
	current_level_idx = starting_level;
	player_lives = starting_player_lives;
	hud = hud_scene.instantiate();
	add_child(hud);
	game_start.emit();
	player_lives_updated.emit(player_lives);
	start_next_level();

func on_player_died() -> void:
	player_lives -= 1;
	player_lives_updated.emit(player_lives);

	if (player_lives <= 0):
		trigger_game_over();
		music_player._play_lose_music();
	else:
		_respawn_start_next_level();

func trigger_game_over() -> void:
	game_stop.emit();
	pause_menu.stop_monitoring();
	active_level.win_condition_met.disconnect(_play_win_music);
	active_level.lose_condition_met.disconnect(on_player_died);
	hud.hide();
	game_over_screen.show();

func start_next_level(reset_player_health: bool = false) -> void:
	if (active_level):
		active_level.queue_free();

	if (reset_player_health):
		player_health.reset_health();

	var new_level_settings: LevelResource = levels.get(current_level_idx); 
	var new_level: Level = level_scene.instantiate();
	new_level.level_settings = new_level_settings;
	new_level.is_active = true;

	music_player.play_next_level_music(current_level_idx);

	active_level = new_level;
	add_child(active_level);
	new_level.win_condition_met.connect(_play_win_music);
	new_level.lose_condition_met.connect(on_player_died);
	level_start.emit(current_level_idx, active_level);

func _respawn_start_next_level() -> void:
	music_player.pause_music();
	get_tree().create_timer(2.0, false).timeout.connect(start_next_level.bind(true));

func _play_win_music() -> void:
	music_player.play_win_music();
	get_tree().create_timer(2.0, false).timeout.connect(_on_next_level);

func _on_next_level() -> void:
	current_level_idx += 1;
	if (current_level_idx >= levels.size()):
		pause_menu.stop_monitoring();
		active_level.win_condition_met.disconnect(_play_win_music);
		active_level.lose_condition_met.disconnect(on_player_died);
		hud.hide();
		win_screen.show();
		return;

	start_next_level();
