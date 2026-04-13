@tool
class_name Projectile
extends Node2D

@export var speed := 1000.0;
@export var mesh_deformation_shapes: Array[MeshDeformationShape];

# TODO: This should be a HitBox and created by the weapon on firing
@onready var collision_area_2d: Area2D = get_node("Area2D");
@onready var deal_damage: DealDamage = get_node("DealDamage");

var velocity: Vector2 = Vector2.RIGHT;
var aim_point: Vector2 = Vector2.RIGHT;
var target: Node2D;
var last_position: Vector2;

func _ready() -> void:
	collision_area_2d.body_entered.connect(_on_body_entered);
	collision_area_2d.body_shape_entered.connect(_on_body_shape_entered);

func on_create(
	weapon: Weapon,
	weapon_aim_point: Vector2,
) -> void:
	global_position = weapon.global_position;
	global_rotation = weapon.global_rotation;
	aim_point = weapon_aim_point;
		
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
	
func on_hit(hit_node: Node) -> void:
	deal_damage.damage(hit_node);
	
func get_collider() -> CollisionShape2D:
	return get_node("Area2D/CollisionShape2D");
		
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

func _on_body_entered(node: Node) -> void:
	on_hit(node);
	queue_free(); 
	
# TODO: Make mesh deformation configurable for HitBox (if deformation shapes exist)
func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if (body is PhysicsBody2D):
		var physics_body: PhysicsBody2D = body;
		var body_shape_owner := physics_body.shape_find_owner(body_shape_index);
		var body_collider := physics_body.shape_owner_get_owner(body_shape_owner);
		
		if (body_collider is DeformableMeshCollider2D):
			var mesh_collider: DeformableMeshCollider2D = body_collider;
			var projectile_collision := get_collider();
			var collision_points := projectile_collision.shape.collide_and_get_contacts(
				projectile_collision.global_transform,
				mesh_collider.shape,
				mesh_collider.global_transform
			);
			
			if (collision_points.size() > 0):
				var impact_point: Vector2 = collision_points.get(0);
				var impact_angle := last_position.angle_to(impact_point);
			
				mesh_collider.apply_mesh_deformation(
					to_local(impact_point),
					impact_angle,
					mesh_deformation_shapes,
				);
