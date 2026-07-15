@tool
class_name DeformableMesh2D
extends Node2D

enum GroupDeformationResult {
	Destroyed = 0,
	Updated = 1,
	Created = 2,
	None = 3,
}

@export var collision_mesh_group: MS_CollisionMeshGroup;

# Node where collisions will be attached
@export var collision_object: CollisionObject2D;

signal spawn_new_group(newcollision_mesh_group: MS_CollisionMeshGroup);
signal all_colliders_destroyed();

var signals_enabled := true;
var _deformable_mesh_collisions: Array[DeformableMeshCollider2D] = [];

func _init(
	p_collision_mesh_group: MS_CollisionMeshGroup = null,
	p_collision_object: Node = null
) -> void:
	collision_mesh_group = p_collision_mesh_group;
	collision_object = p_collision_object;

func _enter_tree() -> void:
	_remove_editor_collisions();

	var collision_meshes := collision_mesh_group.collision_meshes;
	for i: int in collision_meshes.size():
		var collision := DeformableMeshCollider2D.new();
		collision._collision_mesh = collision_meshes[i].duplicate();
		collision.collision_mesh_group = self;
		collision.shape = collision_meshes[i].convex_shape;
		collision.spawn_new_group.connect(_spawn_new_group);
		call_deferred("_add_collision", collision);

func _exit_tree() -> void:
	signals_enabled = false;

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
	if (signals_enabled):
		spawn_new_group.emit(new_group);
	
func deform_group(
	collision_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> GroupDeformationResult:
	var valid_collision_count := 0;
	var destroyed_count := 0;
	var created_count := 0;

	for mesh_collider in _deformable_mesh_collisions:
		if (is_instance_valid(mesh_collider)):
			valid_collision_count += 1;

			var result := mesh_collider.apply_mesh_deformation(
				mesh_collider.to_local(collision_point),
				collision_angle,
				mesh_deformation_shapes
			)

			if (result == DeformableMeshCollider2D.MeshUpdateResult.Destroyed):
				destroyed_count += 1;
			elif (result == DeformableMeshCollider2D.MeshUpdateResult.Created):
				created_count += 1;

	if (created_count > 0):
		return GroupDeformationResult.Created;
	elif (destroyed_count > 0 && destroyed_count == valid_collision_count):
		return GroupDeformationResult.Destroyed;
	else:
		return GroupDeformationResult.Updated;

func _on_collider_freed(collision: DeformableMeshCollider2D) -> void:
	_deformable_mesh_collisions.erase(collision);
	if (signals_enabled && _deformable_mesh_collisions.size() == 0):
		all_colliders_destroyed.emit();
