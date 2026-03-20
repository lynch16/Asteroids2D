class_name AsteroidMesh
extends Resource

@export var texture: Texture2D;
@export var corner_sampling: Dictionary[Vector2, float];
# Track center and normalized vertex
@export var polygon_points: PackedVector2Array;
@export var mesh: ArrayMesh;

func _init(
	p_mesh: ArrayMesh = ArrayMesh.new(), 
	p_texture: Texture2D = Texture2D.new(), 
	p_corner_sampling: Dictionary[Vector2, float] = {},
	p_polygon_points: PackedVector2Array = PackedVector2Array(),
) -> void:
	mesh = p_mesh;
	texture = p_texture;
	corner_sampling = p_corner_sampling;
	polygon_points = p_polygon_points;

func apply(asteroid: Asteroid, to_global: Callable) -> void:
	var mesh_instance := asteroid.get_mesh_instance()
	mesh_instance.mesh = mesh;
	mesh_instance.texture = texture;
	mesh_instance.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;
	
	var collider := asteroid.get_collider();
	collider.polygon = polygon_points;

	var curr_mesh_center := TileMapProcGen._get_center_point_of_polygon(polygon_points);
	var mesh_offset: Vector2 = asteroid.global_position - to_global.call(curr_mesh_center);
	mesh_instance.position = mesh_offset;
	collider.position = mesh_offset;
