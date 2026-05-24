class_name Thrower
extends Node2D

@export_category("Thrower properties")
@export var throw_speed: float;

@export_category("Required properties")
@export var throwable: Throwable;

@export_category("Optional properties")
## Needed to throw accurately at a moving target
@export var intercepter: Interceptor;
## Needed for basic targeting if not using an intercepter
@export var targeter: Targeter;

## Throw the throwable directly at a specific point in space
func throw_direct() -> void:
	var aim_point := _aim_point();
	throwable.throw(_calc_exact_throw_velocity(aim_point), _get_aim_point_angle(aim_point));

## Add some stank on the shot so it isn't an aim bot
func throw_direct_with_variance(variance: float) -> void:
	var aim_point := _aim_point();
	throwable.throw(
		_calc_exact_throw_velocity(aim_point), _get_aim_point_angle(aim_point) + _throw_variance(variance));

## Randomly shoot in a mostly forward direction
func throw_straight_with_variance(variance: float) -> void:
	throwable.throw(_calc_exact_throw_velocity(_straight_ahead()), global_rotation + _throw_variance(variance));

## Shoot arrow straight in the direction facing
func throw_straight() -> void:
	throwable.throw(_calc_exact_throw_velocity(_straight_ahead()), global_rotation);

func _aim_point() -> Vector2:
	if (intercepter):
		return intercepter.calculate_intercept_point();
	else:
		return targeter.get_target_global_position();

func _calc_exact_throw_velocity(aim_point: Vector2) -> Vector2:
	var base_velocity := Vector2.ZERO;
	if (intercepter):
		base_velocity = intercepter._calculate_self_velocity();

	return base_velocity + Vector2(throw_speed, 0).rotated(_get_aim_point_angle(aim_point));

func _straight_ahead() -> Vector2:
	return Vector2.RIGHT.rotated(rotation);

func _throw_variance(variance: float) -> float:
	return randf_range(-variance, variance);

func _get_aim_point_angle(aim_point: Vector2) -> float:
	return global_rotation + get_angle_to(aim_point);