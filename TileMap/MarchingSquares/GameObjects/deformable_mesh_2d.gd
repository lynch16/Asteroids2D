@tool
class_name DeformableMesh2D
extends Node2D

@export var _collision_mesh_group: MS_CollisionMeshGroup;
@export var _deformable_mesh_collisions: Array[DeformableMeshCollider2D] = [];

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_remove_editor_collisions();
		
	var collision_meshes := _collision_mesh_group.collision_meshes;
	for i: int in collision_meshes.size():
		var collision := DeformableMeshCollider2D.new();
		collision._collision_mesh = collision_meshes[i];
		collision.collision_mesh_group = self;
		collision.shape = collision_meshes[i].convex_shape;
		collision.spawn_new_group.connect(_spawn_new_group);
		call_deferred("_add_collision", collision);

func _add_collision(collision: DeformableMeshCollider2D) -> void:
	if (Engine.is_editor_hint()):
		add_child(collision);
	else:
		owner.add_child(collision);
		_deformable_mesh_collisions.append(collision);
	collision.owner = owner;
	
func _remove_editor_collisions() -> void:
	for child in get_children():
		child.queue_free();

func get_colliders() -> Array[DeformableMeshCollider2D]:
	return _deformable_mesh_collisions;

func _spawn_new_group(new_group: MS_CollisionMeshGroup) -> void:
	spawn_new_group.emit(new_group);
	
func deform_group(
	collidion_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> void:
	for mesh_collider in _deformable_mesh_collisions:
		mesh_collider.apply_mesh_deformation(
			collidion_point,
			collision_angle,
			mesh_deformation_shapes
		)
