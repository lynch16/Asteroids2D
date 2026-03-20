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

const MAX_RECURSION := 500;

# Externally this needs to:
# 1. (Re)Generate mesh because:
# 	1a. We want to hand sculpt asteroids in the editor and save for use in scenes
#		1ai. This involves generating from noise and using keyboard keys to manage sculpting
# 	1b. Asteroids will break during gameplay and should result in distinct physics bodies
# 2. Apply a collision shape to result in breaking the current mesh apart
# 3. Apply textures to the mesh

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
	

# Filters a Dictionary of corner samples to what is contained within the polygon
# Reduces the polygon to tile size in order to gather corners for full tiles involved in the polygon
# Returns a new Dictonary with the filtered samples
static func _filter_corner_samples_by_polygon(
	polygon: PackedVector2Array,
	corner_samples: Dictionary[Vector2, float]
) -> Dictionary[Vector2, float]:
	var polygon_corner_tracker: Dictionary[Vector2, float] = {}
	
	return corner_samples.keys().reduce(
		func(tracker: Dictionary[Vector2, float], key: Vector2) -> Dictionary[Vector2, float]:
			if (Geometry2D.is_point_in_polygon(key, polygon)):
				tracker.set(key, corner_samples[key]);
				# Expand out to include all connected tiles
				for i in CORNERS.size():
					var center := key - CORNERS[i] * float(HALF_TILE_SIZE);
					# Gather all corners of connected tiles
					for j in CORNERS.size():
						for_each_corner(center, 
							func(corner: Vector2) -> void:
								if (!tracker.has(corner)):
									tracker.set(corner, corner_samples[corner]);
						);
	
			return tracker;,
		polygon_corner_tracker
	);

# Recursive function to gather all tile centers and normalized vertex to corner from that center
# 
static func _track_edge_verticies(
	tile_center: Vector2, 
	viewport_rect: Rect2,
	corner_samples: Dictionary[Vector2, float],
	recursion: int = 0,
	# Track center and normalized vertex
	tracked_verticies: Dictionary[Vector2, Vector2] = {},
) -> Dictionary[Vector2, Vector2]:
	recursion += 1;
	if (recursion > MAX_RECURSION): return tracked_verticies;
	
	var tile_index := TileMapProcGen.get_tile_index_from_corners(tile_center, corner_samples);
	
	if (tile_index == TileMapProcGen.ALL_CORNERS):
		if (
			(tile_center.x + TileMapProcGen.TILE_SIZE > viewport_rect.size.x) || \
			(tile_center.y + TileMapProcGen.TILE_SIZE > viewport_rect.size.y) || \
			(tile_center.x - TileMapProcGen.TILE_SIZE < 0) || \
			(tile_center.y - TileMapProcGen.TILE_SIZE < 0)
		):
			print("INCLUDE");
			# TODO: Edges not yet included automatically. The tile walker never moves into this block
		print("ALL_CORNERS");
	elif (tile_index == TileMapProcGen.NO_CORNERS):
		print("NO CORNERS");
	else:
		var next_tile_dirs := MSMeshes.NEXT_VERTEX_ARRAYS[tile_index];
		for i in next_tile_dirs.size():
			var next_tile := next_tile_dirs[i] * TileMapProcGen.TILE_SIZE + tile_center;
			if (viewport_rect.has_point(next_tile) && !tracked_verticies.has(next_tile)):
				tracked_verticies.set(tile_center, next_tile_dirs[i]);
				return _track_edge_verticies(next_tile, viewport_rect, corner_samples, recursion, tracked_verticies);

	return tracked_verticies;

# Recurrsively crawls from given Vector2, collecting all weighted verticies from connected edge
static func _isolate_polygon_from_mesh(
	tile_center: Vector2, 
	viewport_rect: Rect2,
	corner_samples: Dictionary[Vector2, float],
) -> PackedVector2Array:
	var tracked_verts := _track_edge_verticies(tile_center, viewport_rect, corner_samples);
	return PackedVector2Array(tracked_verts.keys().map(
		func(key: Vector2) -> Vector2:
			return calculate_weighted_vertex(corner_samples, key, tracked_verts[key])
	));

# Create or update a MeshInstance2D based on the providered corner samples and texture
# This is set to repeat the texture across the mesh
static func _upsert_new_mesh_instance(
	viewport_rect: Rect2,
	corner_samples: Dictionary[Vector2, float],
	texture: Texture2D,
	mesh_instance: MeshInstance2D = MeshInstance2D.new()
) -> MeshInstance2D:
	mesh_instance.mesh = TileMapProcGen.generate_mesh(
		viewport_rect.size,
		corner_samples,
		texture
	);
	mesh_instance.texture = texture;
	mesh_instance.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;
	
	return mesh_instance;

# Create or Update a CollisionPolygon2D based on provided MeshInstance2D
# Parses the MeshInstance2D for a ConvexPolygonShape3D before converting to 2D
# To determine the order of verticies, function compares angle then distance from centroid in clockwise order
static func _upsert_collision_polygon_from_mesh(
	mesh_instance: MeshInstance2D,
	collision: CollisionPolygon2D = CollisionPolygon2D.new()
) -> CollisionPolygon2D:
	var convex_3d_polygon := mesh_instance.mesh.create_convex_shape();
	var cX := 0.0;
	var cY := 0.0;
	
	for point in convex_3d_polygon.points:
		cX += point.x;
		cY += point.y;
		
	var center_polygon_point := Vector2(cX / convex_3d_polygon.points.size(), cY / convex_3d_polygon.points.size())
	
	var normalized_points := [];
	for point in convex_3d_polygon.points:
		normalized_points.append(Vector2(point.x - center_polygon_point.x, point.y - center_polygon_point.y));
	
	normalized_points.sort_custom(
		func(a: Vector2, b: Vector2) -> bool:
			var angle_a := center_polygon_point.angle_to(a);
			var angle_b := center_polygon_point.angle_to(b);
			
			if (angle_a > angle_b):
				return true;
			
			if (angle_a == angle_b):
				var distance_a := center_polygon_point.distance_to(a);
				var distance_b := center_polygon_point.distance_to(b);
				
				return distance_a < distance_b;
			else:
				return false;
	);
	
	var final_points := normalized_points.map(
		func(p: Vector2) -> Vector2:
			return p + center_polygon_point;
	)
	
	collision.polygon = final_points;
	
	return collision;

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
