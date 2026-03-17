@tool
class_name TileMap_MSquares
extends Node2D

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

@export var noise: FastNoiseLite;
@export_tool_button("Generate", "Callable") var generate := _sample_viewport;

var corner_sample_tracker: Dictionary[Vector2, float] = {};
var surface_array := [];
var dots_lookup: Dictionary[Vector2, bool] = {};
var last_corner_hover: Vector2;
var polygons := [];
var mdt: MeshDataTool;
var centers_lookup: Dictionary[Vector2, int] = {};
var tracked_verts: Dictionary[Vector2, int] = {};

var recursion := 0;
var max_recur := 500;
	
func _ready() -> void:
	InputMap.load_from_project_settings()
	
	_sample_viewport();
	queue_redraw()
				
func _process(_delta: float) -> void:
	queue_redraw()
	
	($Label as Label).text = str(get_viewport().get_mouse_position());
	
	# TODO: Put this into a window to limit interactions until in use
	# TODO: Save resulting mesh as resource
	# TODO: Add Collision
	# TODO: Make dots a separate resource to limit redraws
	if Input.is_action_just_pressed("left_click"):
		_handle_mouse_click();
	
	if Input.is_action_just_pressed("right_click"):
		_handle_mouse_right_click();

func _track_verts(tile_center: Vector2) -> void:
	tracked_verts.set(tile_center, true);
	recursion += 1;
	if (recursion > max_recur): return;
	
	var viewport_rect := get_viewport_rect();
	var tile_index := centers_lookup[tile_center];

	if (tile_index == ALL_CORNERS):
		if (
			(tile_center.x + TILE_SIZE > viewport_rect.size.x) || \
			(tile_center.y + TILE_SIZE > viewport_rect.size.y) || \
			(tile_center.x - TILE_SIZE < 0) || \
			(tile_center.y - TILE_SIZE < 0)
		):
			print("INCLUDE");
			# TODO: Edges not yet included automatically. The tile walker never moves into this block
		print("ALL_CORNERS");
	elif (tile_index == NO_CORNERS):
		print("NO CORNERS");
	else:
		var next_tile_dirs := MSMeshes.NEXT_VERTEX_ARRAYS[tile_index];
		for i in next_tile_dirs.size():
			var next_tile := next_tile_dirs[i] * TILE_SIZE + tile_center;
			if (viewport_rect.has_point(next_tile) && !tracked_verts.has(next_tile)):
				_track_verts(next_tile);

func _get_next_edge(tile_index: int, tile_center: Vector2) -> Vector2:
	var next_tile_dirs := MSMeshes.NEXT_VERTEX_ARRAYS[tile_index];
	for i in next_tile_dirs.size():
		var next_tile := next_tile_dirs[i] * TILE_SIZE + tile_center;
		var viewport_rect := get_viewport_rect();
		if (viewport_rect.has_point(next_tile) && !tracked_verts.has(next_tile)):
			return next_tile;
	
	return Vector2(-1.0, -1.0);

func _handle_mouse_right_click() -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	var tile_center := _get_position_tile_center_coord(mouse_down_position);
	_track_verts(tile_center);
	
		# Null = END
		# Only SW == One down, one left
		# Only SE == One Down, one right
		# SW + SE == One left, one right (NO DOWN AS FULL)
		# Only NE == One Up, One right
		# NE + SW == One Up, One right, one down, one left
		# NE+SE = One Up, one down, (NO RIGHT AS FULL)
		# NE, SE, SW = One UP, one left (NO DOWN or RIGHT AS FULL)
		# Only NW = One UP, ONe left
		# NW + SW = One Up, One down (NO LEFT AS FULL)
		# NW + SW = One Up, One RIght, One Down, One left
		# NW, SW, SE = One Up, One Right (NO DOWN OR LEFT AS FULL)
		# NW + NE = One Right, One Left
		# NW, NE, SW = One Right, One Down (NO UP OR LEFT AS FULL)
		# NW, NE, SE = One Left, One Down (NO UP OR RIGHT AS FULL)
		# ALL FULL = SKIP
		
		
	# TODO: Open a mouse dropdown to select the action
	# 1. Track what type of tile each tile is
	# 2. When selecting a tile, get the tile type,
			# If tile type is all 4 corners, walk tiles until not
	# 3. use the tile type to get the normalized verticies, 
	# 4. use the normalized verticies to determine edges
	# 5. save edge verticies to a new PackedVector2Array
	# 6. 
	# TMP: Create a collision polygon
	pass;
				
func _handle_mouse_click() -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	var corner := _get_position_tile_corner_coord(mouse_down_position);
	
	if (corner_sample_tracker.has(corner)):
		var curr_val: int = _get_sample_int_from_vertex(corner);
		corner_sample_tracker.set(corner, int(curr_val == 0));
		_generate_mesh();
		
func _get_position_tile_center_coord(mouse_position: Vector2) -> Vector2:
	var tile_pos := Vector2(floori(mouse_position.x / TILE_SIZE), floori(mouse_position.y / TILE_SIZE)); 
	var center := Vector2(tile_pos.x + BLOCK_DIVISION, tile_pos.y + BLOCK_DIVISION) * float(TILE_SIZE);

	return center;
		
func _get_position_tile_corner_coord(mouse_position: Vector2) -> Vector2:
	var center := _get_position_tile_center_coord(mouse_position);
	
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (mouse_position.distance_to(corner) < HALF_TILE_SIZE):
			return corner;
			
	return last_corner_hover;
	
func _sample_viewport() -> void:
	corner_sample_tracker = {};
	_for_each_tile(_save_corner_samples);
	_generate_mesh();
	
func _save_corner_samples(center: Vector2) -> void:
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (!corner_sample_tracker.has(corner)):
			corner_sample_tracker.set(corner, _sample(corner));
	
func _sample(input: Vector2) -> float:
	return noise.get_noise_2dv(input);
	
func _generate_mesh() -> void:
	var mesh := ArrayMesh.new();
	var mesh_instance: MeshInstance2D = $MeshInstance2D;
	mesh_instance.mesh = mesh;
	
	surface_array = [];
	surface_array.resize(Mesh.ARRAY_MAX);
	
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector2Array();
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array();
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array();
	surface_array[Mesh.ARRAY_NORMAL] = PackedVector3Array();
	
	_for_each_tile(_generate_tile_from_corners);
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array);
	
	mdt = MeshDataTool.new();
	mdt.create_from_surface(
		($MeshInstance2D as MeshInstance2D).mesh as ArrayMesh,
		0
	);

func _generate_tile_from_corners(center: Vector2) -> void:
	var tile_index := 0;
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (!corner_sample_tracker.has(corner)):
			continue;
		
		tile_index += _get_sample_int_from_vertex(corner) << i;
				
	_add_tile(center, tile_index);
	
func _get_sample_int_from_vertex(corner_vector: Vector2) -> int:
	var corner_sample: float = corner_sample_tracker.get(corner_vector);
	return int(corner_sample > 0.0)

func _add_tile(center: Vector2, tile_index: int) -> void:
	centers_lookup[center] = tile_index;
	
	var texture: CompressedTexture2D = ($MeshInstance2D as MeshInstance2D).texture;
	var verticies := MSMeshes.VERTEX_ARRAYS[tile_index].duplicate();
	var indicies := MSMeshes.INDEX_ARRAYS[tile_index].duplicate();
	var total_verticies: int = 0;
	if (surface_array[Mesh.ARRAY_VERTEX] is PackedVector2Array):
		var array_vertex: PackedVector2Array = surface_array[Mesh.ARRAY_VERTEX];
		total_verticies = array_vertex.size();
	
		for i: int in verticies.size():
			var vertex := verticies[i];
			verticies[i] = _calculate_weighted_vertex(center, vertex);
	
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

func _calculate_weighted_vertex(center: Vector2, normalized_vertex: Vector2) -> Vector2:
	var is_edge := absf(normalized_vertex.x) + absf(normalized_vertex.y) == 1.0;
	var direction := Vector2.UP if normalized_vertex.x != 0.0 else Vector2.RIGHT;
			
	var vertex := normalized_vertex * float(HALF_TILE_SIZE) + center;
	#if (is_edge):
		#var corner_1 := vertex + direction * HALF_TILE_SIZE;
		#var corner_2 := vertex - direction * HALF_TILE_SIZE;
		#var value_1: float = corner_sample_tracker.get(corner_1);
		#var value_2: float = corner_sample_tracker.get(corner_2);
		#var weight := (value_1 + value_2)/(value_1 - value_2) / 2.0 + 0.5;
		#vertex = corner_1.lerp(corner_2, weight);
	
	return vertex;

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	_draw_dots()
	for k: Vector2 in tracked_verts.keys():
		var rect := Rect2(k.x - HALF_TILE_SIZE, k.y - HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
		draw_rect(rect, Color.ORANGE, false);
		
func _draw_dots() -> void:
	dots_lookup = {};
	_for_each_tile(_draw_dot);
	_track_mouse_hover();

func _draw_corner_dot(corner: Vector2) -> void:
	if (dots_lookup.has(corner) || !corner_sample_tracker.has(corner)):
		return;
			
	var color := Color.RED;
	var corner_sample: int = _get_sample_int_from_vertex(corner);
	if (corner_sample > 0):
		color = Color.GREEN;
		
	if (corner == last_corner_hover):
		color = Color.BLUE;
			
	dots_lookup.set(corner, _get_sample_int_from_vertex(corner));
	draw_circle(corner, DOT_BUTTON_RADIUS, color);

func _draw_center_dot(center: Vector2) -> void:
	draw_circle(center, DOT_BUTTON_RADIUS, Color.PURPLE);
	
func _draw_dot(center: Vector2) -> void:
	_draw_center_dot(center);
	_for_each_corner(center, _draw_corner_dot)

func _track_mouse_hover() -> void:
	var mouse_position := get_viewport().get_mouse_position();
	var corner := _get_position_tile_corner_coord(mouse_position);
	
	if (!last_corner_hover || last_corner_hover != corner):
		draw_circle(last_corner_hover, DOT_BUTTON_RADIUS, Color.RED);
		draw_circle(corner, DOT_BUTTON_RADIUS, Color.GREEN);
		
		last_corner_hover = corner;
		
# Utility function to get normalized tile coordinates from viewport
func _for_each_tile(callable: Callable) -> void:
	var viewport := get_viewport_rect().size;
	# Determine how many tiles will fit across X and Y
	var x_viewport_tiles := int(viewport.x/TILE_SIZE);
	var y_viewport_tiles := int(viewport.y/TILE_SIZE);
	
	for x: int in range(0, x_viewport_tiles):
		for y: int in range(0, y_viewport_tiles + 1):
			var center := Vector2(x + BLOCK_DIVISION, y + BLOCK_DIVISION) * float(TILE_SIZE);
			callable.call(center);
			
func _for_each_corner(center: Vector2, callable: Callable) -> void:
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		callable.call(corner);
