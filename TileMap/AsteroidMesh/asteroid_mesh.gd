class_name AsteroidMesh
extends Resource

@export var mesh_surface_array: Array;
@export var texture: Texture2D;
@export var corner_sampling: Dictionary[Vector2, float];
# Track center and normalized vertex
@export var edge_verticies: Dictionary[Vector2, Vector2];

func _init(
	p_mesh_surface_array: Array = [], 
	p_texture: Texture2D = Texture2D.new(), 
	p_corner_sampling: Dictionary[Vector2, float] = {}
) -> void:
	mesh_surface_array = p_mesh_surface_array;
	texture = p_texture;
	corner_sampling = p_corner_sampling;
	
func get_polygon_verts_from_edge() -> PackedVector2Array:
	return PackedVector2Array(edge_verticies.keys().map(
		func(key: Vector2) -> Vector2:
			return TileMapProcGen.calculate_weighted_vertex(corner_sampling, key, edge_verticies[key])
	))
