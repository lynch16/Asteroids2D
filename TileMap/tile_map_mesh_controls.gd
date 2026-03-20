@tool
class_name TileMapMeshControls
extends Node2D

@export var noise: FastNoiseLite;
@export var texture: Texture2D;
@export_tool_button("Generate", "Callable") var generate := _sample_viewport;

var saved_corner_samples: Dictionary[Vector2, float] = {};
var staged_corner_samples: Dictionary[Vector2, float] = {};
var staged_mesh_inst: MeshInstance2D;
var staged_collision: CollisionPolygon2D;
var staged_tile_center_generate_point: Vector2;

@onready var seed_mesh_inst: MeshInstance2D = get_node("../../SeedMeshInstance2D");
	
func _ready() -> void:
	InputMap.load_from_project_settings();
	
	_sample_viewport();
				
func _process(_delta: float) -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	var viewport_rect := get_viewport_rect();
	if (visible && viewport_rect.has_point(mouse_down_position)):
		if Input.is_action_just_pressed("left_click"):
			_handle_mouse_click();
	
		if Input.is_action_just_pressed("right_click"):
			_handle_mouse_right_click();

func _save_asteroid_mesh(filename: String) -> void:
	var asteroid_mesh := AsteroidMesh.new(
		staged_mesh_inst.mesh as ArrayMesh,
		texture,
		staged_corner_samples,
		staged_collision.polygon
	);
	
	ResourceSaver.save(asteroid_mesh, "res://TileMap/AsteroidMesh/" + filename + ".tres");

func _handle_mouse_right_click() -> void:
	var viewport_rect := get_viewport_rect();
	var mouse_down_position := get_viewport().get_mouse_position();
	# Determine which tile mouse click is on
	staged_tile_center_generate_point = TileMapProcGen.get_position_tile_center_coord(mouse_down_position);
	# Get polygon of outer edges connected to that tile. This polygon is not guaranteed to exactly match mesh
	var rough_polygon := TileMapProcGen._isolate_polygon_from_mesh(staged_tile_center_generate_point, viewport_rect, saved_corner_samples);
	# Filter overall corner sample data into just what applies to tiles touching polygon
	staged_corner_samples = TileMapProcGen._filter_corner_samples_by_polygon(
		rough_polygon,
		saved_corner_samples
	);

	# TODO: Normalize all new verticies around Vector2.ZERO to simplfiy positioning downstream
	#var rough_center_point := TileMapProcGen._get_center_point_of_polygon(rough_polygon);
	#filtered_corner_samples.keys().reduce(
		#func(new_samples: Dictionary[Vector2, float], corner_vector: Vector2) -> Dictionary[Vector2, float]:
			#new_samples[corner_vector - rough_center_point] = filtered_corner_samples[corner_vector];
			#return new_samples;,
		#staged_corner_samples
	#)
	#
	# Create a new MeshInstance2D, Generate a new mesh based on the filtered corner samples, Load texture
	staged_mesh_inst = MeshInstance2D.new();
	TileMapProcGen._upsert_new_mesh_instance(viewport_rect, staged_corner_samples, texture, staged_mesh_inst)
	add_child(staged_mesh_inst);
	staged_mesh_inst.owner = get_tree().edited_scene_root
	
	staged_collision = CollisionPolygon2D.new();
	staged_collision = TileMapProcGen._upsert_collision_polygon_from_mesh(staged_mesh_inst, staged_collision);
	add_child(staged_collision);
	staged_collision.owner = get_tree().edited_scene_root
	
	_save_asteroid_mesh("test")
	
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
	
	if (saved_corner_samples.has(corner)):
		var curr_val: int = TileMapProcGen.get_sample_int_from_vertex(corner, saved_corner_samples);
		saved_corner_samples.set(corner, int(curr_val == 0));
		_generate_mesh_from_saved_samples();

func _sample_viewport() -> void:
	saved_corner_samples.clear();
	var viewport_size := get_viewport_rect().size;
	TileMapProcGen.for_each_tile(viewport_size, _save_corner_samples);
	_generate_mesh_from_saved_samples();
	
func _generate_mesh_from_saved_samples() -> void:
	var viewport_size := get_viewport_rect().size;
	seed_mesh_inst.mesh = TileMapProcGen.generate_mesh(viewport_size, saved_corner_samples, texture);
	
func _save_corner_samples(center: Vector2) -> void:
	for i: int in TileMapProcGen.CORNERS.size():
		var corner := center + TileMapProcGen.CORNERS[i] * float(TileMapProcGen.HALF_TILE_SIZE);
		if (!saved_corner_samples.has(corner)):
			saved_corner_samples.set(corner, _sample(corner));
	
func _sample(input: Vector2) -> float:
	return noise.get_noise_2dv(input);
	
