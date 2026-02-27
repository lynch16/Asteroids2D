extends CharacterBody2D
class_name Player

@export var thrust: int = 100;
@export var mass: int = 2;
@export var rotation_speed: int = 5;
@export var max_speed: int = 400; # m/s

var ship_direction: float;
var acceleration: Vector2 = Vector2();

func _ready() -> void:
	velocity = Vector2.UP;
	ship_direction = velocity.angle();
	($BulletSpawnTimer as Timer).timeout.connect(_spawn_bullet)

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
	
	var tmp_vel: Vector2 = velocity + (acceleration * delta);
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
	if (($BulletSpawnTimer as Timer).is_stopped()):
		($BulletSpawnTimer as Timer).start();

func _spawn_bullet() -> void:
	var bulletScn: PackedScene = load("res://Models/Player/bullet.tscn");
	var bullet: Bullet = bulletScn.instantiate();
	get_tree().root.add_child(bullet)
	bullet.fire_bullet(
		($BulletSpawnLocation as Node2D).global_position, 
		ship_direction, 
		velocity
	);
	
	
func _convert_direction_to_rotation(direction: float) -> float:
	return direction + PI/2;
