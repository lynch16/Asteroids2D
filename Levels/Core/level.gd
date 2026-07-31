class_name Level
extends Node2D

@export var level_settings: LevelResource;

var is_active: bool = false;
## How many rocks to seed the level with
var num_starting_rocks := 1; 
## How quickly to throw rocks during the game
var rock_throw_interval := 0.0; 
## How many rocks to throw during the game
var num_rocks_to_throw := 5; 
## How long to wait after the level starts to begin throwing rocks
var rock_thrower_start_delay := 10.0; 

var enemey_scene: PackedScene;
## How many enemies to spawn
var possible_num_enemies := Vector2i(0, 0);
## How long to wait before spawning enemies
var enemies_start_delay := 10.0;
## Hunters vs shoot at random place
var enemy_hunters := false;
## How many enemy groups to send
var enemy_group_count := 0;

@onready var player_spawn: PlayerSpawn = %PlayerSpawn;
@onready var game_area: GameArea = %GameArea;
@onready var rock_thrower: RockThrower = %RockThrower;

var start_rocks_timer: Timer;
var start_enemies_timer: Timer;
var current_rocks_thrown := 0;
var current_enemy_group_count := 0;

var enemy_groups: Array[int] = [];
var total_enemies_required := 0;

signal level_loaded(level: Level);
signal win_condition_met;
signal lose_condition_met; 

func _ready() -> void:
	if (!level_settings):
		printerr("Level settings missing");
	
	num_starting_rocks = level_settings.num_starting_rocks;
	rock_throw_interval = level_settings.rock_throw_interval;
	num_rocks_to_throw = level_settings.num_rocks_to_throw;
	rock_thrower_start_delay = level_settings.rock_thrower_start_delay;
	AsteroidManager.asteroid_count = 0;
	enemey_scene = level_settings.enemey_scene;
	possible_num_enemies = level_settings.possible_num_enemies;
	enemy_group_count = level_settings.enemy_group_count;
	enemies_start_delay = level_settings.enemies_start_delay;
	enemy_hunters = level_settings.enemy_hunters;

	level_loaded.emit(self);
	rock_thrower.on_throw_rock.connect(_on_rock_thrown);
	player_spawn.player_spawned.connect(start_enemies);
	tree_exiting.connect(_on_tree_exiting);

	for i in range(enemy_group_count):
		var num_enemies := randi() % possible_num_enemies.y + possible_num_enemies.x;
		enemy_groups.append(num_enemies);
		total_enemies_required += num_enemies;

	print("total_enemies_required: ", total_enemies_required)
	enter();

func enter() -> void:
	player_spawn.spawn_player(_on_player_die);

func start_enemies(_player: Player) -> void:
	for i in num_starting_rocks:
		rock_thrower.throw_rock();

	if (rock_thrower_start_delay > 0.0):
		start_rocks_timer = Timer.new();
		start_rocks_timer.wait_time = rock_thrower_start_delay;
		start_rocks_timer.one_shot = true;
		start_rocks_timer.autostart = true;
		start_rocks_timer.timeout.connect(_on_start_rocks_timer_timeout);
		add_child(start_rocks_timer);

	if (possible_num_enemies.y > 0):
		start_enemies_timer = Timer.new();
		start_enemies_timer.wait_time = enemies_start_delay;
		start_enemies_timer.autostart = true;
		start_enemies_timer.timeout.connect(_on_start_enemies_timer_timeout);
		add_child(start_enemies_timer);

func _on_player_die(player: Player) -> void:
	lose_condition_met.emit();
	get_tree().create_timer(1.0, false).timeout.connect(player.queue_free);

func _process(_delta: float) -> void:
	if (is_active):
		_check_win_condition();

	# Stop throwing rocks at limit
	if (_are_all_rocks_thrown()):
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

func _on_start_enemies_timer_timeout() -> void:
	var num_enemies := enemy_groups[current_enemy_group_count];
	var spawn_group := EnemySpawnGroup.new(num_enemies);
	if (enemy_hunters):
		spawn_group.patrol_mode = EnemySpawnGroup.PatrolMode.Hunt;
	else:
		spawn_group.patrol_mode = EnemySpawnGroup.PatrolMode.ShootRandom;

	game_area.add_child(spawn_group);
	current_enemy_group_count += 1;

	if (current_enemy_group_count >= enemy_group_count):
		start_enemies_timer.stop();

func _are_all_rocks_thrown() -> bool:
	return current_rocks_thrown >= num_starting_rocks + num_rocks_to_throw

func _check_win_condition() -> void:
	if (
		AsteroidManager.get_asteroid_count() <= 0 &&
		_are_all_rocks_thrown() && # TODO: Should they have to wait for all rocks to be thrown if they cleared the screen?
		EnemyManager.get_enemy_count() <= 0
	):
		is_active = false;
		win_condition_met.emit();

func _on_rock_thrown() -> void:
	current_rocks_thrown += 1;
