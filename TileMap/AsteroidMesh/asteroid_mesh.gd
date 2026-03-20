class_name AsteroidMesh
extends Resource

@export var mesh_surface_array: Array;
@export var texture: Texture2D;
@export var corner_sampling: Dictionary[Vector2, float];
# Track center and normalized vertex
@export var polygon_points: Dictionary[Vector2, Vector2];

func _init(
	p_mesh_surface_array: Array = [], 
	p_texture: Texture2D = Texture2D.new(), 
	p_corner_sampling: Dictionary[Vector2, float] = {},
	p_polygon_points: Dictionary[Vector2, Vector2] = {},
) -> void:
	mesh_surface_array = p_mesh_surface_array;
	texture = p_texture;
	corner_sampling = p_corner_sampling;
	polygon_points = p_polygon_points;
	
func get_polygon_verts_from_edge() -> PackedVector2Array:
	return PackedVector2Array(polygon_points.keys().map(
		func(key: Vector2) -> Vector2:
			return TileMapProcGen.calculate_weighted_vertex(corner_sampling, key, polygon_points[key])
	))
