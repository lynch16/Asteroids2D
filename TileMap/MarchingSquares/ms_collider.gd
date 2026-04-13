class_name MS_Collider
extends Resource

var collision: CollisionShape2D;
var mesh_instance: MeshInstance2D;
var corner_sampling: Dictionary[Vector2, float];

func _init(
	p_collision: CollisionShape2D = CollisionShape2D.new(),
	p_mesh_instance: MeshInstance2D = MeshInstance2D.new(),
	p_corner_sampling: Dictionary[Vector2, float] = {},
) -> void:
	collision = p_collision;
	mesh_instance = p_mesh_instance;
	corner_sampling = p_corner_sampling;
