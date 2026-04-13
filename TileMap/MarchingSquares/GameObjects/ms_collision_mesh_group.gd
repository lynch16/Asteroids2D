@tool
class_name MS_CollisionMeshGroup
extends Resource

@export var collision_meshes: Array[MS_CollisionMesh];

var collision_shapes: Array[CollisionShape2D];
var owner: Node2D;

func _init(
	p_collision_meshes: Array[MS_CollisionMesh] = [], 
) -> void:
	collision_meshes = p_collision_meshes;
	
	collision_shapes = [];
	owner = Node2D.new();
	resource_local_to_scene = true;
