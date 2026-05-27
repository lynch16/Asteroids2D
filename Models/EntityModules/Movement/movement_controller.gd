class_name MovementController
extends Node2D

@export var movement_stats: MovementStats;
@export var moveable_character: CharacterBody2D;

var movement_speed: float;

func apply_rotation(target_rotation: float) -> void:
	var delta := Engine.time_scale / Engine.physics_ticks_per_second;
	# Check that it's not zero or character will slowly rotate to face Vector2(0,0);
	if (target_rotation):
		var normalized_rotation := fposmod(target_rotation, TAU);
		var rotation_direction: float = 1.0 if (normalized_rotation > moveable_character.rotation) else -1.0;
		var new_angle := lerp_angle(moveable_character.global_rotation, normalized_rotation, movement_stats.rotation_speed * delta * rotation_direction);
		moveable_character.global_rotation = new_angle;

func accelerate_movement_speed() -> void:
	var delta := Engine.time_scale / Engine.physics_ticks_per_second;
	# Interpolate speed given rate of acceleration
	movement_speed = lerp(movement_speed, movement_stats.max_speed, movement_stats.acceleration * delta);

func apply_velocity(new_velocity: Vector2) -> void:
	moveable_character.velocity = calculate_moveable_char_velocity(new_velocity);

func calculate_moveable_char_velocity(new_velocity: Vector2) -> Vector2:
	return new_velocity.limit_length(movement_stats.max_speed);

func accelerate_velocity() -> void:
	accelerate_movement_speed();
	# Apply speed in direction of new target, limited to max speed;
	# Does not point to global position
	var new_velocity: Vector2 =  moveable_character.global_position * movement_speed;
	apply_velocity(new_velocity);