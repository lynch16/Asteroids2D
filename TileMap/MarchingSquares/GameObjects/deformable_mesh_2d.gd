@tool
class_name DeformableMesh2D
extends Node2D

@export var _collision_mesh_group: MS_CollisionMeshGroup;

# Node where collisions will be attached
@export var physics_node: Node = owner;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);
signal all_colliders_destroyed;

var _deformable_mesh_collisions: Array[DeformableMeshCollider2D] = [];

func _enter_tree() -> void:
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
		physics_node.add_child(collision);
		_deformable_mesh_collisions.append(collision);
	collision.owner = physics_node;
	
	collision.tree_exited.connect(_on_collider_freed.bind(collision));
	
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
		if (is_instance_valid(mesh_collider)):
			mesh_collider.apply_mesh_deformation(
				collidion_point,
				collision_angle,
				mesh_deformation_shapes
			)

func _on_collider_freed(collision: DeformableMeshCollider2D) -> void:
	_deformable_mesh_collisions.erase(collision);
	if (_deformable_mesh_collisions.size() == 0):
		all_colliders_destroyed.emit();
