class_name ObjectiveHUD
extends Node

@onready var game_manager: GameManager = get_node("/root/GameManager");

@onready var enemies_container: BoxContainer = %EnemiesContainer;
@onready var asteroids_value: Label = %AsteroidsValue;
@onready var enemies_value: Label = %EnemiesValue;

var active_level: Level;

var num_asteroids_destroyed := 0;
var num_enemies_destroyed := 0;
var asteroids_broken_off := 0;

func _ready() -> void:
	game_manager.level_start.connect(_start_new_level);

	AsteroidManager.asteroid_destroyed.connect(_update_asteroid_kill_count);
	AsteroidManager.asteroid_shattered.connect(_update_shatter_count);
	EnemyManager.enemy_destroyed.connect(_update_enemy_kill_count);

func _start_new_level(_idx: int, new_level: Level) -> void:
	print("START NEW LEVEL");
	active_level = new_level; 
	num_asteroids_destroyed = 0;
	num_enemies_destroyed = 0;
	asteroids_broken_off = 0;

	_update_objectives();

func _process(_delta: float) -> void:
	_update_objectives();

func _update_objectives() -> void:
	if (!active_level): return;

	print("num_asteroids_destroyed: ", num_asteroids_destroyed)
	var total_asteroids_required := active_level.num_starting_rocks + active_level.num_rocks_to_throw - num_asteroids_destroyed + asteroids_broken_off;
	var total_enemies_required := active_level.num_enemies - num_enemies_destroyed; # TODO: Increase to include number of groups when added
	if (total_enemies_required <= 0):
		enemies_container.hide();
	else:
		enemies_container.show();
	
	enemies_value.text = str(total_enemies_required);
	asteroids_value.text = str(total_asteroids_required);

func _update_asteroid_kill_count() -> void:
	num_asteroids_destroyed += 1;

func _update_shatter_count() -> void:
	asteroids_broken_off += 1;

func _update_enemy_kill_count() -> void:
	num_enemies_destroyed += 1;
