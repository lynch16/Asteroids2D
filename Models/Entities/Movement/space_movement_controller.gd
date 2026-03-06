# Moves entities as if they are in space: Based on thrust in direction of travel
class_name SpaceMovementController
extends MovementController

@export var thrust := 200;
@export var rotation_speed := 5;
@export var moveable_character: CharacterBody2D;

var ship_direction: float;
var acceleration := Vector2();
var target_velocity: Vector2;
var target_position: Vector2;

var buffer_vector := Vector2(5.0, 5.0);

func _ready() -> void:
	moveable_character.velocity = Vector2.UP;
	ship_direction = moveable_character.velocity.angle();
	target_velocity = moveable_character.velocity;
	target_position = moveable_character.global_position;
	
func _apply_velocity() -> void:
	moveable_character.velocity = target_velocity
	moveable_character.rotation = target_velocity.angle() + PI/2
	moveable_character.move_and_slide();
	
func _physics_process(delta: float) -> void:
	_apply_velocity();
	#_apply_ship_controls(delta);
	#
	#moveable_character.velocity = target_velocity
	#moveable_character.rotation = target_velocity.angle() + PI/2
	#moveable_character.move_and_slide();
	
	#var tmp_vel := moveable_character.velocity + (acceleration * delta);
	#print("acceleration: ", acceleration);
	#moveable_character.velocity = tmp_vel.min(Vector2(max_speed, max_speed));
	#moveable_character.rotation = _convert_direction_to_rotation(ship_direction);
	#moveable_character.move_and_slide();

#func _apply_ship_controls(delta: float) -> void:
	#var target_direction := moveable_character.global_position.direction_to(target_velocity);
	#var rotation_difference := target_direction.angle() - ship_direction;
	#
	#if (rotation_difference > 0):
		#_rotate_right(delta);
	#elif (rotation_difference < 0):
		#_rotate_left(delta);
		#
	#if (abs(target_position - moveable_character.global_position) > buffer_vector):
		#_speed_up();

func _speed_up() -> void:
	# Apply acceleration to max speed in direction facing
	acceleration = Vector2(thrust, 0).rotated(ship_direction);
	
func _brake() -> void:
	# Apply acceleration to max speed in reverse direction facing
	acceleration = Vector2(-thrust, 0).rotated(ship_direction);
	
# Rotate direction of travel to the left
func _rotate_left(delta: float) -> void:
	ship_direction -= rotation_speed * delta;
	
# Rotate direction of travel to the right
func _rotate_right(delta: float) -> void:
	ship_direction += rotation_speed * delta;
