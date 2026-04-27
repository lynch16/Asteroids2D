@tool
class_name Projectile
extends Node2D

@export var speed := 1000.0;
@export var _combat_stats: CombatStats;
@export var mesh_deformation_shapes: Array[MeshDeformationShape];
@export var collision_shape: Shape2D;

var velocity: Vector2 = Vector2.RIGHT;
var aim_point: Vector2 = Vector2.RIGHT;
var target: Node2D;
var last_position: Vector2;
var hitbox: MeshDeformHitbox2D;

func on_create(
	weapon: Weapon,
	weapon_aim_point: Vector2,
) -> void:
	global_position = weapon.global_position;
	global_rotation = weapon.global_rotation;
	aim_point = weapon_aim_point;
	hitbox = MeshDeformHitbox2D.new(
		_combat_stats,
		0.0, 
		collision_shape,
		null,
		weapon.owner_character,
		mesh_deformation_shapes,
	);
	add_child(hitbox);
		
func on_start(
	base_velocity: Vector2,
	launch_target: Node2D = null
) -> void:
	target = launch_target;
	
	var new_velocity := base_velocity + Vector2(speed, 0).rotated(global_rotation + get_angle_to(aim_point));
	velocity = new_velocity;
	
func update(delta: float) -> void:
	global_rotation = velocity.angle();
	last_position = global_position;
	position += velocity * delta;
	
func _process(_delta: float) -> void:
	if !Engine.is_editor_hint() || self != get_tree().edited_scene_root:
		_cull_offscreen();
		
func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint() || self != get_tree().edited_scene_root:
		update(delta);
	
func _cull_offscreen() -> void:
	var viewport := get_viewport_rect().size;
	if (
		global_position.x >= viewport.x || global_position.x <= 0.0 || \
		global_position.y >= viewport.y || global_position.y <= 0.0
	):
		queue_free();
