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
var next_velocity: Vector2;
var next_rotation: float;

# TODO: Nothing listens to this
signal player_died(player: Player);

func _enter_tree() -> void:
	hurtbox = %Hurtbox2D;
	# TODO: I think CollisionShape2D for the Hurtbox is being duplicated 2x
	# There should be a collision shape for the physics body under the Character and for the Area for Hit/Hurboxes
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
	next_rotation = p_rotation;
	next_velocity = p_velocity

func _physics_process(_delta: float) -> void:
	var is_turning := false;
	var is_accelerating := false;

	if (!next_velocity.is_equal_approx(velocity)):
		velocity = next_velocity;
		is_accelerating = true;

	var normalized_rotation := snappedf(fposmod(rotation, TAU), 0.001);
	var normalized_next_rotation := snappedf(fposmod(next_rotation, TAU), 0.001);

	if (!is_equal_approx(normalized_rotation, normalized_next_rotation)):
		rotation = next_rotation;
		is_turning = true;
	
	_handle_animation_and_sound(
		is_accelerating,
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
	SignalBus._on_player_health_updated(int(new_health));
	
func _die() -> void:
	player_died.emit(self);
	# TODO: Death animation and sound
