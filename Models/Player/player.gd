extends CharacterBody2D
class_name Player

@export var thrust := 1000;
@export var mass := 2;
@export var rotation_speed := 5;
@export var max_speed := 400; # m/s

var ship_direction: float = Vector2.UP.angle();
var acceleration := Vector2();
var bulletScn := preload("res://Models/Player/bullet.tscn");

@onready var bullet_spawn_loc: Node2D = get_node("BulletSpawnLocation");
@onready var bullet_timer: Timer = get_node("BulletSpawnTimer");

func _ready() -> void:
	velocity = Vector2.UP;
	ship_direction = velocity.angle();
	bullet_timer.timeout.connect(_spawn_bullet)

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
		
	rotation = _convert_direction_to_rotation(ship_direction);
	
	var tmp_vel := velocity + (acceleration * delta);
	if (tmp_vel.length() <= max_speed):
		velocity = tmp_vel;
	
	move_and_slide();
	
	if (Input.is_action_pressed("fire_weapon")):
		_fire_weapon();

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
	
func _convert_direction_to_rotation(direction: float) -> float:
	return direction + PI/2;
