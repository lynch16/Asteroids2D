@tool
class_name TileMapProcGen

const CORNER_NW = Vector2(-1,1);
const CORNER_NE = Vector2(1,1);
const CORNER_SE = Vector2(1,-1);
const CORNER_SW = Vector2(-1,-1);

const CORNERS: PackedVector2Array = [
	CORNER_NW,
	CORNER_NE,
	CORNER_SE,
	CORNER_SW,
];
const NEXT_CHECK: PackedVector2Array = [
	Vector2.UP,
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT
]
const TILE_SIZE = 32;
const HALF_TILE_SIZE = TILE_SIZE/2;
const BLOCK_DIVISION = 0.5;
const DOT_BUTTON_RADIUS = 2.0;
const ALL_CORNERS = 15 # 1111 in binary
const NO_CORNERS = 0 # 0000 in binary

static func generate_mesh(
	viewport_size: Vector2, 
	corner_samples: Dictionary[Vector2, float],
	texture: Texture2D,
) -> ArrayMesh:
	var surface_array := _calculate_surface_array(viewport_size, corner_samples, texture);
	var mesh := ArrayMesh.new();
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array);
	return mesh;
	
static func _calculate_surface_array(
	viewport_size: Vector2, 
	corner_samples: Dictionary[Vector2, float],
	texture: Texture2D,
) -> Array:
	var surface_array := [];
	surface_array.resize(Mesh.ARRAY_MAX);
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector2Array();
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array();
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array();
	surface_array[Mesh.ARRAY_NORMAL] = PackedVector3Array();
	for_each_tile(viewport_size, _generate_tile_from_corners.bind(corner_samples, surface_array, texture));
	return surface_array;

static func get_tile_index_from_corners(
	center: Vector2, 
	corner_samples: Dictionary[Vector2, float],
) -> int:
	var tile_index := 0;
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (!corner_samples.has(corner)):
			continue;
		
		tile_index += get_sample_int_from_vertex(corner, corner_samples) << i;
		
	return tile_index;
	
# TODO: This can be used to recalculate the tile_index so that centers_lookup isn't strictly needed
# This can reduce state to just corner_sample_tracker for the mesh
static func _generate_tile_from_corners(
	center: Vector2, 
	corner_samples: Dictionary[Vector2, float],
	surface_array: Array,
	texture: Texture2D,
) -> void:
	_add_tile(
		center, 
		get_tile_index_from_corners(center, corner_samples), 
		corner_samples, 
		surface_array, 
		texture
	);

static func get_sample_int_from_vertex(
	corner_vector: Vector2, 
	corner_samples: Dictionary[Vector2, float]
) -> int:
	if (!corner_samples.has(corner_vector)): return 0;
	var corner_sample: float = corner_samples.get(corner_vector);
	return int(corner_sample > 0.0)

static func _add_tile(
	center: Vector2, 
	tile_index: int,
	corner_samples: Dictionary[Vector2, float],
	surface_array: Array,
	texture: Texture2D,
) -> void:
	var verticies := MSMeshes.VERTEX_ARRAYS[tile_index].duplicate();
	var indicies := MSMeshes.INDEX_ARRAYS[tile_index].duplicate();
	var total_verticies: int = 0;
	if (surface_array[Mesh.ARRAY_VERTEX] is PackedVector2Array):
		var array_vertex: PackedVector2Array = surface_array[Mesh.ARRAY_VERTEX];
		total_verticies = array_vertex.size();
	
		for i: int in verticies.size():
			var vertex := verticies[i];
			verticies[i] = calculate_weighted_vertex(
				corner_samples, center, vertex);
	
		array_vertex.append_array(verticies);
	
	if (surface_array[Mesh.ARRAY_TEX_UV] is PackedVector2Array):
		var texSize := texture.get_size();
		var uv_array: PackedVector2Array = surface_array[Mesh.ARRAY_TEX_UV];
		for i: int in verticies.size():
			uv_array.append(Vector2.ONE / (texSize/verticies[i]));
			
	if (surface_array[Mesh.ARRAY_NORMAL] is PackedVector3Array):
		var tile_normal_array := PackedVector3Array();
		
		var normal_array: PackedVector3Array = surface_array[Mesh.ARRAY_NORMAL];
		tile_normal_array.resize(verticies.size());
		tile_normal_array.fill(Vector3.FORWARD);
		normal_array.append_array(tile_normal_array)
	
	if (surface_array[Mesh.ARRAY_INDEX] is PackedInt32Array):
		var array_index: PackedInt32Array = surface_array[Mesh.ARRAY_INDEX];
	
		for i: int in indicies.size():
			indicies[i] += total_verticies;
		
		array_index.append_array(indicies);

static func calculate_weighted_vertex(corner_sample: Dictionary[Vector2, float], center: Vector2, normalized_vertex: Vector2) -> Vector2:
	var is_edge := absf(normalized_vertex.x) + absf(normalized_vertex.y) == 1.0;
	var direction := Vector2.UP if normalized_vertex.x != 0.0 else Vector2.RIGHT;
			
	var vertex := normalized_vertex * float(HALF_TILE_SIZE) + center;
	if (is_edge):
		var corner_1 := vertex + direction * HALF_TILE_SIZE;
		var corner_2 := vertex - direction * HALF_TILE_SIZE;
		var value_1: float = corner_sample.get(corner_1);
		var value_2: float = corner_sample.get(corner_2);
		var weight := (value_1 + value_2)/(value_1 - value_2) / 2.0 + 0.5;
		vertex = corner_1.lerp(corner_2, weight);
	
	return vertex;
	
# TODO: These utilities assume the mesh spans the whole viewport
static func get_position_tile_center_coord(mouse_position: Vector2) -> Vector2:
	var tile_pos := Vector2(floori(mouse_position.x / TILE_SIZE), floori(mouse_position.y / TILE_SIZE)); 
	var center := Vector2(tile_pos.x + BLOCK_DIVISION, tile_pos.y + BLOCK_DIVISION) * float(TILE_SIZE);

	return center;
		
static func get_position_tile_corner_coord(mouse_position: Vector2) -> Vector2:
	var center := get_position_tile_center_coord(mouse_position);
	
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (mouse_position.distance_to(corner) < HALF_TILE_SIZE):
			return corner;
			
	return Vector2(-1.0, -1.0); # Off screen

# Utility function to get normalized tile coordinates from viewport
static func for_each_tile(viewport_size: Vector2, callable: Callable) -> void:
	# Determine how many tiles will fit across X and Y
	var x_viewport_tiles := int(viewport_size.x/TILE_SIZE);
	var y_viewport_tiles := int(viewport_size.y/TILE_SIZE);
	
	for x: int in range(0, x_viewport_tiles):
		for y: int in range(0, y_viewport_tiles + 1):
			var center := Vector2(x + BLOCK_DIVISION, y + BLOCK_DIVISION) * float(TILE_SIZE);
			callable.call(center);
			
static func for_each_corner(center: Vector2, callable: Callable) -> void:
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		callable.call(corner);
