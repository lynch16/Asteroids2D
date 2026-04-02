@tool
class_name MarchingSquaresGenerate

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
	MarchingSquaresUtility.for_each_tile(viewport_size, _generate_tile_from_corners.bind(corner_samples, surface_array, texture));
	return surface_array;
	
static func _generate_tile_from_corners(
	center: Vector2, 
	corner_samples: Dictionary[Vector2, float],
	surface_array: Array,
	texture: Texture2D,
) -> void:
	_add_tile(
		center, 
		MarchingSquaresUtility.get_tile_index_from_corners(center, corner_samples), 
		corner_samples, 
		surface_array, 
		texture
	);

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
			verticies[i] = _calculate_weighted_vertex(
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

static func _calculate_weighted_vertex(corner_sample: Dictionary[Vector2, float], center: Vector2, normalized_vertex: Vector2) -> Vector2:
	var is_edge := absf(normalized_vertex.x) + absf(normalized_vertex.y) == 1.0;
	var direction := Vector2.UP if normalized_vertex.x != 0.0 else Vector2.RIGHT;
			
	var vertex := normalized_vertex * float(MarchingSquaresUtility.HALF_TILE_SIZE) + center;
	if (is_edge):
		var corner_1 := vertex + direction * MarchingSquaresUtility.HALF_TILE_SIZE;
		var corner_2 := vertex - direction * MarchingSquaresUtility.HALF_TILE_SIZE;
		var value_1: float = 1.0;
		if (corner_sample.has(corner_1)):
			value_1 = corner_sample.get(corner_1);
		
		var value_2: float = 1.0;
		if (corner_sample.has(corner_2)):
			value_2 = corner_sample.get(corner_2);
				
		var weight := (value_1 + value_2)/(value_1 - value_2) / 2.0 + 0.5;
		vertex = corner_1.lerp(corner_2, weight);
	
	return vertex;
	
# Create or update a MeshInstance2D
# This is set to repeat the texture across the mesh
static func upsert_mesh_instance(
	mesh: ArrayMesh,
	texture: Texture2D,
	mesh_instance: MeshInstance2D = MeshInstance2D.new()
) -> MeshInstance2D:
	mesh_instance.mesh = mesh;
	mesh_instance.texture = texture;
	mesh_instance.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;
	
	return mesh_instance;
	
# Create or update a MeshInstance2D based on the providered corner samples and texture
# This is set to repeat the texture across the mesh
static func upsert_generated_mesh_instance(
	viewport_rect: Rect2,
	corner_samples: Dictionary[Vector2, float],
	texture: Texture2D,
	mesh_instance: MeshInstance2D = MeshInstance2D.new()
) -> MeshInstance2D:
	var mesh := MarchingSquaresGenerate.generate_mesh(
		viewport_rect.size,
		corner_samples,
		texture
	);
	return upsert_mesh_instance(mesh, texture, mesh_instance)

# Create or Update a CollisionPolygon2D based on provided MeshInstance2D
# Parses the MeshInstance2D for a ConvexPolygonShape3D before converting to 2D
static func generate_collision_shapes(
	viewport_rect: Rect2,
	corner_samples: Dictionary[Vector2, float],
) -> Array[ConvexPolygonShape2D]:
	var x_viewport_tiles := int(viewport_rect.size.x/MarchingSquaresUtility.TILE_SIZE);
	var y_viewport_tiles := int(viewport_rect.size.y/MarchingSquaresUtility.TILE_SIZE);
	var bitmap := BitMap.new();
	bitmap.create(Vector2i(x_viewport_tiles, y_viewport_tiles));
	for vector in corner_samples:
		var x_as_tile := clampi(floori(vector.x / MarchingSquaresUtility.TILE_SIZE), 0, x_viewport_tiles - 1)
		var y_as_tile := clampi(floori(vector.y / MarchingSquaresUtility.TILE_SIZE), 0, y_viewport_tiles - 1)
		var bit_vector := Vector2(x_as_tile, y_as_tile); 
		bitmap.set_bitv(bit_vector, corner_samples[vector] > 0.0);
	
	var polygons := bitmap.opaque_to_polygons(Rect2(Vector2(), Vector2(x_viewport_tiles, y_viewport_tiles)), 1.0);
	var collision_shapes: Array[ConvexPolygonShape2D] = [];
	
	for polygon in polygons:
		var resized_polygon := PackedVector2Array();
		for point in polygon:
			resized_polygon.append(
				Vector2(point.x * MarchingSquaresUtility.TILE_SIZE, point.y * MarchingSquaresUtility.TILE_SIZE)
			);
			
		var convex_shape := ConvexPolygonShape2D.new();
		convex_shape.points = resized_polygon;
		collision_shapes.append(convex_shape);

	return collision_shapes;

# Need to have a func to get cluster center and pass it to two below funcs
static func _get_collider_cluster_center(collider_shapes: Array[ConvexPolygonShape2D]) -> Vector2:
	var all_polygon_points: Array[Vector2] = [];
	for shape in collider_shapes:
		all_polygon_points.append_array(shape.points);
	
	return MarchingSquaresUtility.get_center_point_of_polygon(all_polygon_points);

# Reposition the internal Shape2D Resource and MeshInstance2D node so that cluster is positioned at Vector2.ZERO
static func _reposition_colliders(collider_shapes: Array[ConvexPolygonShape2D], colliders: Array[CollisionShape2D]) -> void:
	var cluster_center := _get_collider_cluster_center(collider_shapes);
	for i: int in collider_shapes.size():
		#var new_points: Array[Vector2] = [];
		#for point in collider_shapes[i].points:
			#new_points.append(point - cluster_center);
		#collider_shapes[i].set_points(new_points);
		colliders[i].position = colliders[i].position - cluster_center;
