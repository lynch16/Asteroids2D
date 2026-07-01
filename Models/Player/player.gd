class_name Player
extends CharacterBody2D

@export var movement_stats: MovementStats;
@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var hurtbox: Hurtbox2D = %Hurtbox2D;
@onready var thrust_animations: ThrustAnimations = get_node("AnimatedShipSprite2D/ThrustAnimations");
@onready var thrust_sound: AudioStreamPlayer = get_node("ThrustSound");
@onready var turn_sound: AudioStreamPlayer = get_node("TurnSound");
@onready var movement_controller: MovementController = get_node("MovementController");

var damageable: Damageable;

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

	movement_controller.movement_stats = movement_stats;
	movement_controller.movement_updated.connect(_update_movement);

func _update_movement(p_velocity: Vector2, p_rotation: float) -> void:
	var is_turning := false;
	var is_accelerating := false;

	velocity = p_velocity;

	if (p_velocity > velocity):
		is_accelerating = true;

	if (p_rotation != rotation):
		rotation = p_rotation;
		is_turning = true;
	
	_handle_animation_and_sound(
		is_accelerating,
		is_turning
	);

func _physics_process(_delta: float) -> void:
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
