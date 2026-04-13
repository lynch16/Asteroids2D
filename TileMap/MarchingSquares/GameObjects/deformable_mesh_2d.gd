class_name DeformableMesh2D
extends Node2D

@export var _collision_mesh_group: MS_CollisionMeshGroup;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_meshes := _collision_mesh_group.collision_meshes;
	for i: int in collision_meshes.size():
		var collision := DeformableMeshCollider2D.new();
		collision._collision_mesh = collision_meshes[i];
		collision.shape = collision_meshes[i].convex_shape;
		collision.spawn_new_group.connect(_spawn_new_group);
		call_deferred("_add_collision", collision);

func _add_collision(collision: DeformableMeshCollider2D) -> void:
	owner.add_child(collision);
	collision.owner = owner;

func _spawn_new_group(new_group: MS_CollisionMeshGroup) -> void:
	spawn_new_group.emit(new_group);
