class_name Player
extends CharacterBody2D

@export var movement_stats: MovementStats;
@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var hurtbox: Hurtbox2D = %Hurtbox2D;
@onready var thrust_animations: ThrustAnimations = get_node("AnimatedShipSprite2D/ThrustAnimations");
@onready var thrust_sound: AudioStreamPlayer = get_node("ThrustSound");
@onready var turn_sound: AudioStreamPlayer = get_node("TurnSound");

var damageable: Damageable;
var ship_direction: float;
var acceleration := Vector2();

# TODO: Nothing listens to this
signal player_died(player: Player);

func _enter_tree() -> void:
	hurtbox = %Hurtbox2D;
	var collision_shape: CollisionShape2D = get_node("CollisionShape2D");
	hurtbox.shape = collision_shape.shape;
	hurtbox.health_stats = health_stats;

func _ready() -> void:
	# Register broadcast handler and emit initial health state
	health_stats.on_health_changed.connect(_handle_player_damage);
	health_stats.on_health_depleted.connect(_die);
	
	# Call deferred so that Damageble handlers can connect before initial broadcast to HUD
	SignalBus._on_player_health_updated(int(health_stats.current_health));
	
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO;
	var is_turning := false;
	
	if (Input.is_action_pressed("yaw_left")):
		_yaw_left(delta);
		is_turning = true;
	
	if (Input.is_action_pressed("yaw_right")):
		is_turning = true;
		_yaw_right(delta);
	
	if (Input.is_action_pressed("thrust")):
		_move_forward();
	
	if (Input.is_action_pressed("brake")):
		_brake();
		
	var tmp_vel := velocity + (acceleration * delta);
	velocity = tmp_vel.min(Vector2(movement_stats.max_speed, movement_stats.max_speed));

	if (!ship_direction):
		ship_direction = rotation;
	rotation = ship_direction;

	_handle_animation_and_sound(
		acceleration.length() > 0.0,
		is_turning
	);

	move_and_slide();

func _handle_animation_and_sound(
	is_accelerating: bool,
	is_turning: bool
) -> void:
	if (is_accelerating):
		thrust_animations.start_animation();
		if (!thrust_sound.playing):
			thrust_sound.play();
	else:
		thrust_animations.stop_animation();
		thrust_sound.stop();

	if (is_turning):
		if (!turn_sound.playing):
			turn_sound.play();
	else:
		turn_sound.stop();

func _handle_player_damage(_old_health: float, new_health: float) -> void:
	print("PLAYER HIT: ", new_health)
	SignalBus._on_player_health_updated(int(new_health));
	
func _die() -> void:
	player_died.emit(self);
	# TODO: Death animation and sound

func _move_forward() -> void:
	# Apply acceleration to max speed in direction facing
	acceleration = Vector2(movement_stats.acceleration, 0).rotated(ship_direction);
	
func _brake() -> void:
	# Apply acceleration to max speed in reverse direction facing
	acceleration = Vector2(-movement_stats.acceleration, 0).rotated(ship_direction);
	
# Rotate direction of travel to the left
func _yaw_left(delta: float) -> void:
	ship_direction -= movement_stats.rotation_speed * delta;
	
# Rotate direction of travel to the right
func _yaw_right(delta: float) -> void:
	ship_direction += movement_stats.rotation_speed * delta;
