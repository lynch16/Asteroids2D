@tool
class_name TileMapMeshControls
extends Node2D

@export var noise: FastNoiseLite;
@export var texture: Texture2D;
@export_tool_button("Generate", "Callable") var generate := _sample_viewport;

var corner_sample_tracker: Dictionary[Vector2, float] = {};

var recursion := 0;
var max_recur := 500;

@onready var mesh_instance: MeshInstance2D = get_node("../../MeshInstance2D");
	
func _ready() -> void:
	InputMap.load_from_project_settings();
	
	_sample_viewport();
				
func _process(_delta: float) -> void:
	# TODO: Save resulting mesh as resource
	var mouse_down_position := get_viewport().get_mouse_position();
	var viewport_rect := get_viewport_rect();
	if (visible && viewport_rect.has_point(mouse_down_position)):
		if Input.is_action_just_pressed("left_click"):
			_handle_mouse_click();
	
		if Input.is_action_just_pressed("right_click"):
			_handle_mouse_right_click();


func _handle_mouse_right_click() -> void:
	var viewport_rect := get_viewport_rect();
	var mouse_down_position := get_viewport().get_mouse_position();
	# Determine which tile mouse click is on
	var tile_center := TileMapProcGen.get_position_tile_center_coord(mouse_down_position);
	# Get polygon of outer edges connected to that tile
	var polygon := TileMapProcGen._isolate_polygon_from_mesh(tile_center, viewport_rect, corner_sample_tracker);
	# Filter overall corner sample data into just what applies to tiles touching polygon
	var new_corner_samples := TileMapProcGen._filter_corner_samples_by_polygon(
		polygon,
		corner_sample_tracker
	);
	
	# Create a new MeshInstance2D, Generate a new mesh based on the filtered corner samples, Load texture
	var new_mesh_inst := MeshInstance2D.new();
	TileMapProcGen._upsert_new_mesh_instance(viewport_rect, new_corner_samples, texture, new_mesh_inst)
	add_child(new_mesh_inst);
	new_mesh_inst.owner = get_tree().edited_scene_root
	
	var collision := TileMapProcGen._upsert_collision_polygon_from_mesh(new_mesh_inst);
	add_child(collision);
	collision.owner = get_tree().edited_scene_root
	
	# TODO: Instantiate Asteroid (Need to reconfigure asteroid to be polygon instead of sprite)
	# I think the Asteroid actually needs to be using a mesh so that I can apply marching squares on impact instead of subtraction against a Polygon2D
	
		
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
	var corner := TileMapProcGen.get_position_tile_corner_coord(mouse_down_position);
	
	if (corner_sample_tracker.has(corner)):
		var curr_val: int = TileMapProcGen.get_sample_int_from_vertex(corner, corner_sample_tracker);
		corner_sample_tracker.set(corner, int(curr_val == 0));
		_generate_mesh();
	
func _sample_viewport() -> void:
	corner_sample_tracker.clear();
	var viewport_size := get_viewport_rect().size;
	TileMapProcGen.for_each_tile(viewport_size, _save_corner_samples);
	_generate_mesh();
	
func _generate_mesh() -> void:
	var viewport_size := get_viewport_rect().size;
	mesh_instance.mesh = TileMapProcGen.generate_mesh(viewport_size, corner_sample_tracker, texture);
	
func _save_corner_samples(center: Vector2) -> void:
	for i: int in TileMapProcGen.CORNERS.size():
		var corner := center + TileMapProcGen.CORNERS[i] * float(TileMapProcGen.HALF_TILE_SIZE);
		if (!corner_sample_tracker.has(corner)):
			corner_sample_tracker.set(corner, _sample(corner));
	
func _sample(input: Vector2) -> float:
	return noise.get_noise_2dv(input);
	
