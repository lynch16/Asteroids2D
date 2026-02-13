extends CharacterBody2D

@export var thrust = 100;
@export var rotation_speed = 5;
@export var bullet_speed = 300;

var ship_direction = Vector2.UP;
var acceleration = Vector2();

func _ready() -> void:
	velocity = Vector2.UP;
	ship_direction = velocity.angle();
	get_node("BulletSpawnTimer").timeout.connect(_spawn_bullet)

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
		
	rotation = ship_direction + PI/2;
	velocity += acceleration * delta;
	
	move_and_slide();
	
	if (Input.is_action_pressed("fire_weapon")):
		_fire_weapon();

func _move_forward():
	# Apply acceleration to max speed in direction facing
	acceleration = Vector2(thrust, 0).rotated(ship_direction);
	
func _brake():
	# Apply acceleration to max speed in reverse direction facing
	acceleration = Vector2(-thrust, 0).rotated(ship_direction);
	
# Rotate direction of travel to the left
func _yaw_left(delta: float):
	ship_direction -= rotation_speed * delta;
	
# Rotate direction of travel to the right
func _yaw_right(delta: float):
	ship_direction += rotation_speed * delta;

func _fire_weapon():
	var timer: Timer = get_node("BulletSpawnTimer");
	if (timer.is_stopped()):
		timer.start();

func _spawn_bullet():
	var bulletScn = load("res://Models/Player/bullet.tscn");
	var bullet: Bullet = bulletScn.instantiate();
	bullet.position = get_node("BulletSpawnLocation").position;
	bullet.rotation = ship_direction;
	bullet.apply_central_impulse(velocity + Vector2(bullet_speed, 0).rotated(ship_direction))
	add_child(bullet)
