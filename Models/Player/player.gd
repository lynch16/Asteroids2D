class_name Player
extends CharacterBody2D

@export var min_speed := 10:
	set(val):
		# TODO: https://github.com/godotengine/godot/pull/115649
		min_speed = max(0, min(val, max_speed if max_speed != null else Vector2i.MAX.x)) # Ensures min doesn't exceed max
@export var max_speed := 100:
	set(val):
		max_speed = max(min_speed if min_speed != null else 0, val) # Ensures max doesn't go below min
@export var thrust := 200;
@export var rotation_speed := 5;
@export var mass := 2;

var bulletScn := preload("res://Models/Player/bullet.tscn");

@onready var bullet_spawn_loc: Node2D = get_node("BulletSpawnLocation");
@onready var bullet_timer: Timer = get_node("BulletSpawnTimer");
@onready var damageable: Damageable = get_node("Damageable");
@onready var apply_damage_dr: ApplyDamageResult = get_node("Damageable/ApplyDamageResult");

var ship_direction: float;
var acceleration := Vector2();

func _ready() -> void:
	velocity = Vector2.UP;
	ship_direction = velocity.angle();
	bullet_timer.timeout.connect(_spawn_bullet)
	# Register broadcast handler and emit initial health state
	apply_damage_dr.damage_applied.connect(_handle_player_damage);
	damageable.on_destroy.connect(_die);
	
	# Call deferred so that handlers can connect before initial broadcast
	SignalBus.call_deferred("_on_player_health_updated", int(damageable.curr_health));
	
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
	velocity = tmp_vel.min(Vector2(max_speed, max_speed));
	rotation = _convert_direction_to_rotation(ship_direction);
	
	move_and_slide();
	
	_handle_body_collisions();
	
	if (Input.is_action_pressed("fire_weapon")):
		_fire_weapon();

# MUST be called after move_and_slide to register collisions
# TODO: Need god mode to disable asteroid collisions
func _handle_body_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i);
		var maybe_deal_damage: Variant = collision.get_collider().get("deal_damage");
		if maybe_deal_damage is DealDamage:
			var deal_damager: DealDamage = maybe_deal_damage;
			deal_damager.damage(self);
			
func _handle_player_damage(_dmg: float, _new_health: float) -> void:
	SignalBus._on_player_health_updated(int(damageable.curr_health));

func _fire_weapon() -> void:
	if (bullet_timer.is_stopped()):
		bullet_timer.start();

func _spawn_bullet() -> void:
	var bullet: Bullet = bulletScn.instantiate();
	get_tree().root.add_child(bullet)
	bullet.fire_bullet(
		bullet_spawn_loc.global_position, 
		ship_direction, 
		velocity
	);
	
func _die() -> void:
	GameManager.trigger_game_over();

func _convert_direction_to_rotation(direction: float) -> float:
	return direction + PI/2;
	
func _convert_rotation_to_direction(_rotation: float) -> float:
	return _rotation - PI/2;

func _move_forward() -> void:
	# Apply acceleration to max speed in direction facing
	acceleration = Vector2(thrust, 0).rotated(ship_direction);
	
func _brake() -> void:
	# Apply acceleration to max speed in reverse direction facing
	acceleration = Vector2(-thrust, 0).rotated(ship_direction);
	
# Rotate direction of travel to the left
func _yaw_left(delta: float) -> void:
	ship_direction -= rotation_speed * delta;
	
# Rotate direction of travel to the right
func _yaw_right(delta: float) -> void:
	ship_direction += rotation_speed * delta;
