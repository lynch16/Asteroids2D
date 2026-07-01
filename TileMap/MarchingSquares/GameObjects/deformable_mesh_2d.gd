@tool
class_name DeformableMesh2D
extends Node2D

@export var collision_mesh_group: MS_CollisionMeshGroup;

# Node where collisions will be attached
@export var collision_object: CollisionObject2D;

signal spawn_new_group(newcollision_mesh_group: MS_CollisionMeshGroup);
signal all_colliders_destroyed;

var _deformable_mesh_collisions: Array[DeformableMeshCollider2D] = [];

func _init(
	pcollision_mesh_group: MS_CollisionMeshGroup = null,
	p_collision_object: Node = null
) -> void:
	collision_mesh_group = pcollision_mesh_group;
	collision_object = p_collision_object;

func _enter_tree() -> void:
	_remove_editor_collisions();

	var collision_meshes := collision_mesh_group.collision_meshes;
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
		collision_object.add_child(collision);
		_deformable_mesh_collisions.append(collision);
	collision.owner = collision_object;
	
	collision.tree_exited.connect(_on_collider_freed.bind(collision));
	
func _remove_editor_collisions() -> void:
	for child in get_children():
		child.queue_free();

func get_colliders() -> Array[DeformableMeshCollider2D]:
	return _deformable_mesh_collisions;

func _spawn_new_group(new_group: MS_CollisionMeshGroup) -> void:
	spawn_new_group.emit(new_group);
	
func deform_group(
	collision_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> void:
	for mesh_collider in _deformable_mesh_collisions:
		if (is_instance_valid(mesh_collider)):
			mesh_collider.apply_mesh_deformation(
				mesh_collider.to_local(collision_point),
				collision_angle,
				mesh_deformation_shapes
			)

func _on_collider_freed(collision: DeformableMeshCollider2D) -> void:
	_deformable_mesh_collisions.erase(collision);
	if (_deformable_mesh_collisions.size() == 0):
		all_colliders_destroyed.emit();
