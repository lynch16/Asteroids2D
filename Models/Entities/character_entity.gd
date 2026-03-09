class_name CharacterEntity
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

var ship_direction: float;
var acceleration := Vector2();
var target_velocity: Vector2;
var target_rotation: float;

func _ready() -> void:
	velocity = Vector2.UP;
	ship_direction = velocity.angle();
	target_velocity = velocity;
	target_rotation = rotation;
	
func _physics_process(delta: float) -> void:
	var tmp_vel := velocity + (acceleration * delta);
	velocity = tmp_vel.min(Vector2(max_speed, max_speed));
	rotation = _convert_direction_to_rotation(ship_direction);
	
	move_and_slide();
	#ship_direction = _convert_rotation_to_direction(rotation);

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
