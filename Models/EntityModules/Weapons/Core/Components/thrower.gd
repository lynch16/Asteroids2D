@tool
class_name ThrowerComponent
extends Node2D

@export_category("ThrowerComponent properties")
@export var throw_speed: float;

@export_category("Required properties")
## Projectile should be contained within this scene
@export var throwable_scene: PackedScene;
## How many throwables are sent on each use
@export var num_throw_per_use := 1;

@export_category("Optional properties")
## Needed to throw accurately at a moving target
@export var intercepter: InterceptorComponent;
## Needed for basic targeting if not using an intercepter
@export var targeter: TargeterComponent;

var starting_throwable_count: int = Vector2i.MAX.x;
var current_throwable_count: int;

signal projectiles_created(projectiles: Array[Projectile]);

func _ready() -> void:
	current_throwable_count = starting_throwable_count;
	
	if (targeter == null):
		targeter = get_node_or_null("%TargeterComponent");
	if (intercepter == null):
		intercepter = get_node_or_null("%InterceptorComponent");

func _create_projectiles() -> Array[Projectile]:
	if current_throwable_count <= 0:
		print("Out of ammo")
		# TODO: Out of ammo
		return [];

	var projectiles: Array[Projectile] = [];
	var num_to_throw := num_throw_per_use if num_throw_per_use < current_throwable_count else current_throwable_count;

	for i in num_to_throw:
		# TODO: Should projectile spawning be offloaded to a central utility that can batch?
		var projectile := throwable_scene.instantiate() as Projectile;
		projectile.global_position = global_position;
		projectile.global_rotation = global_rotation;
		
		projectiles.append(projectile);

		if Engine.is_editor_hint():
			get_tree().edited_scene_root.add_child(projectile);
			projectile.set_owner(get_tree().edited_scene_root);
		else:
			get_tree().get_root().add_child(projectile);

	current_throwable_count -= num_to_throw;

	projectiles_created.emit(projectiles);
	return projectiles;

## Throw the throwable directly at a specific point in space
func throw_direct() -> void:
	var aim_point := _aim_point();
	var projectiles := _create_projectiles();
	for projectile in projectiles:
		projectile.throwable.throw(
				_calc_exact_throw_velocity(aim_point), _get_aim_point_angle(aim_point));

## Add some stank on the shot so it isn't an aim bot
func throw_direct_with_variance(variance: float) -> void:
	var aim_point := _aim_point();
	var projectiles := _create_projectiles();
	for projectile in projectiles:
		var jitter := _throw_jitter(variance);
		projectile.throwable.throw(
			_calc_exact_throw_velocity(aim_point + jitter), _get_aim_point_angle(aim_point + jitter));
	
## Randomly shoot in a mostly forward direction
func throw_straight_with_variance(variance: float) -> void:
	var jitter := _throw_jitter(variance)
	var projectiles := _create_projectiles();
	for projectile in projectiles:
		var throw_velocity := _calc_exact_throw_velocity(_straight_ahead() + jitter);
		projectile.throwable.throw(throw_velocity, global_rotation);

## Shoot arrow straight in the direction facing
func throw_straight() -> void:
	var projectiles := _create_projectiles();
	for projectile in projectiles:
			projectile.throwable.throw(_calc_exact_throw_velocity(_straight_ahead()), global_rotation);

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
	return global_position + Vector2.RIGHT.rotated(global_rotation);

func _throw_jitter(variance: float) -> Vector2:
	return Vector2(randf_range(-variance, variance), randf_range(-variance, variance));

func _get_aim_point_angle(aim_point: Vector2) -> float:
	return global_position.angle_to_point(aim_point);
