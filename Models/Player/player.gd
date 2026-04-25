class_name Player
extends CharacterBody2D

@export var movement_stats: MovementStats;
@export var combat_stats: CombatStats;
@onready var hurtbox: Hurtbox2D = get_node("Hurtbox2D");

var ship_direction: float;
var acceleration := Vector2();

func _ready() -> void:
	velocity = Vector2.UP;
	ship_direction = velocity.angle();
	# Register broadcast handler and emit initial health state
	hurtbox.combat_stats = combat_stats;
	combat_stats.on_health_changed.connect(_handle_player_damage);
	combat_stats.on_health_depleted.connect(_die);
	
	# Call deferred so that Damageble handlers can connect before initial broadcast to HUD
	SignalBus._on_player_health_updated(int(combat_stats.current_health));
	
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO;
	
	if (Input.is_action_pressed("yaw_left")):
		_yaw_left(delta);
	
	if (Input.is_action_pressed("yaw_right")):
		_yaw_right(delta);
	
	if (Input.is_action_pressed("thrust")):
		_move_forward();
	
	if (Input.is_action_pressed("brake")):
		_brake();
		
	var tmp_vel := velocity + (acceleration * delta);
	velocity = tmp_vel.min(Vector2(movement_stats.max_speed, movement_stats.max_speed));
	rotation = ship_direction;
	
	move_and_slide();

func _handle_player_damage(_old_health: float, new_health: float) -> void:
	SignalBus._on_player_health_updated(int(new_health));
	
func _die() -> void:
	GameManager.trigger_game_over();

func _move_forward() -> void:
	# Apply acceleration to max speed in direction facing
	acceleration = Vector2(movement_stats.thrust, 0).rotated(ship_direction);
	
func _brake() -> void:
	# Apply acceleration to max speed in reverse direction facing
	acceleration = Vector2(-movement_stats.thrust, 0).rotated(ship_direction);
	
# Rotate direction of travel to the left
func _yaw_left(delta: float) -> void:
	ship_direction -= movement_stats.rotation_speed * delta;
	
# Rotate direction of travel to the right
func _yaw_right(delta: float) -> void:
	ship_direction += movement_stats.rotation_speed * delta;
