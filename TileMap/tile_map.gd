@tool
class_name TileMap_MSquares
extends Node2D

const CORNERS: PackedVector2Array = [
	Vector2(-1, 1),
	Vector2(1, 1),
	Vector2(1, -1),
	Vector2(-1, -1),
]
const TILE_SIZE = 16;
const HALF_TILE_SIZE = TILE_SIZE/2;
const BLOCK_DIVISION = 0.5;
const DOT_BUTTON_RADIUS = 2.0;
const ALL_CORNERS = 15 # 1111 in binary

@export var noise: FastNoiseLite;
@export_tool_button("Generate", "Callable") var generate := _sample_viewport;

var corner_sample_tracker: Dictionary[Vector2, int] = {};
var surface_array := [];
var dots_lookup: Dictionary[Vector2, bool] = {};
var last_corner_hover: Vector2;
	
func _ready() -> void:
	InputMap.load_from_project_settings()
	
	_sample_viewport();
	queue_redraw()
				
func _process(_delta: float) -> void:
	queue_redraw()
	
	# TODO: Put this into a window to limit interactions until in use
	# TODO: Save resulting mesh as resource
	# TODO: Add Collision
	if Input.is_action_just_pressed("left_click"):
		_handle_mouse_click();
				
func _handle_mouse_click() -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	var corner := _get_position_tile_corner_coord(mouse_down_position);
	
	if (corner_sample_tracker.has(corner)):
		var curr_val: int = corner_sample_tracker.get(corner);
		corner_sample_tracker.set(corner, int(curr_val == 0));
		_generate_mesh();
	
func _get_position_tile_corner_coord(mouse_position: Vector2) -> Vector2:
	var tile_pos := Vector2(floori(mouse_position.x / TILE_SIZE), floori(mouse_position.y / TILE_SIZE)); 
	var center := Vector2(tile_pos.x + BLOCK_DIVISION, tile_pos.y + BLOCK_DIVISION) * float(TILE_SIZE);
	
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
			corner_sample_tracker.set(corner, int(_sample(corner) > 0.0));
	
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
	
func _generate_tile_from_corners(center: Vector2) -> void:
	var tile_index := 0;
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (!corner_sample_tracker.has(corner)):
			continue;
					
		tile_index += corner_sample_tracker.get(corner) << i;
				
	_add_tile(center, tile_index);

func _add_tile(center: Vector2, tile_index: int) -> void:
	var texture: CompressedTexture2D = ($MeshInstance2D as MeshInstance2D).texture;
	var verticies := MSMeshes.VERTEX_ARRAYS[tile_index].duplicate();
	var indicies := MSMeshes.INDEX_ARRAYS[tile_index].duplicate();
	var total_verticies: int = 0;
	if (surface_array[Mesh.ARRAY_VERTEX] is PackedVector2Array):
		var array_vertex: PackedVector2Array = surface_array[Mesh.ARRAY_VERTEX];
		total_verticies = array_vertex.size();
	
		for i: int in verticies.size():
			var vertex := verticies[i];
			vertex = vertex * float(HALF_TILE_SIZE) + center;
			verticies[i] = vertex;
	
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
		
# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	_draw_dots()
		
func _draw_dots() -> void:
	dots_lookup = {};
	_for_each_tile(_draw_dot);
	_track_mouse_hover();
	
func _draw_dot(center: Vector2) -> void:
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (dots_lookup.has(corner)):
			return;
			
		var color := Color.RED;
		
		if (corner == last_corner_hover):
			color = Color.GREEN;
			
		dots_lookup.set(corner, true);
		draw_circle(corner, DOT_BUTTON_RADIUS, color);
		
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
