@tool
class_name MS_CollisionMeshGroup
extends Resource

@export var collision_meshes: Array[MS_CollisionMesh];

func _init(
	p_collision_meshes: Array[MS_CollisionMesh] = [], 
) -> void:
	collision_meshes = p_collision_meshes;
	resource_local_to_scene = true;
