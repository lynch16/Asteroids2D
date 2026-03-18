@tool
class_name TileMapMeshControls
extends Node2D

@export var noise: FastNoiseLite;
@export var texture: Texture2D;
@export_tool_button("Generate", "Callable") var generate := _sample_viewport;

var corner_sample_tracker: Dictionary[Vector2, float] = {};
# Track center and normalized vertex
var tracked_verts: Dictionary[Vector2, Vector2] = {};

var recursion := 0;
var max_recur := 500;

@onready var mesh_instance: MeshInstance2D = get_node("../../MeshInstance2D");
	
func _ready() -> void:
	InputMap.load_from_project_settings();
	
	_sample_viewport();
				
func _process(_delta: float) -> void:
	# TODO: Put this into a window to limit interactions until in use
	# TODO: Save resulting mesh as resource
	# TODO: Add Collision
	# TODO: Make dots a separate resource to limit redraws
	var mouse_down_position := get_viewport().get_mouse_position();
	var viewport_rect := get_viewport_rect();
	if (visible && viewport_rect.has_point(mouse_down_position)):
		if Input.is_action_just_pressed("left_click"):
			_handle_mouse_click();
	
		if Input.is_action_just_pressed("right_click"):
			_handle_mouse_right_click();

func _track_verts(tile_center: Vector2) -> void:
	recursion += 1;
	print("recursion: ", recursion)
	if (recursion > max_recur): return;
	
	var viewport_rect := get_viewport_rect();
	var tile_index := TileMapProcGen.get_tile_index_from_corners(tile_center, corner_sample_tracker);
	
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
			if (viewport_rect.has_point(next_tile) && !tracked_verts.has(next_tile)):
				tracked_verts.set(tile_center, next_tile_dirs[i]);
				_track_verts(next_tile);
				# TODO: I am sometimes losing a vertix between index 0-1

#func _get_next_edge(tile_index: int, tile_center: Vector2) -> Vector2:
	#var next_tile_dirs := MSMeshes.NEXT_VERTEX_ARRAYS[tile_index];
	#for i in next_tile_dirs.size():
		#var next_tile := next_tile_dirs[i] * TileMapProcGen.TILE_SIZE + tile_center;
		#var viewport_rect := get_viewport_rect();
		#if (viewport_rect.has_point(next_tile) && !tracked_verts.has(next_tile)):
			#return next_tile;
	#
	#return Vector2(-1.0, -1.0);

func _handle_mouse_right_click() -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	var tile_center := TileMapProcGen.get_position_tile_center_coord(mouse_down_position);
	_track_verts(tile_center);
	print(tracked_verts)
	var collision := CollisionPolygon2D.new();
	var edge_verts := PackedVector2Array(tracked_verts.keys().map(
		func(key: Vector2) -> Vector2:
			return TileMapProcGen.calculate_weighted_vertex(corner_sample_tracker, key, tracked_verts[key])
	))
	collision.polygon = edge_verts;
	add_child(collision);
	collision.owner = get_tree().edited_scene_root
	# TODO: Instantiate Asteroid (Need to reconfigure asteroid to be polygon instead of sprite)
	# I think the Asteroid actually needs to be using a mesh so that I can apply marching squares on impact instead of subtraction against a Polygon2D
	# Set Polygon2D.polygon = edge_verts;
	# Polygon2D.texture = mesh_instance.texture;
	# Set CollisionPolygon2D.polygon = edge_verts;
	
	
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
	var corner := TileMapProcGen.get_position_tile_corner_coord(mouse_down_position);
	var viewport_size := get_viewport_rect().size;
	
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
	var new_mesh := TileMapProcGen.generate_mesh(viewport_size, corner_sample_tracker, texture);
	mesh_instance.mesh = new_mesh;
	
func _save_corner_samples(center: Vector2) -> void:
	for i: int in TileMapProcGen.CORNERS.size():
		var corner := center + TileMapProcGen.CORNERS[i] * float(TileMapProcGen.HALF_TILE_SIZE);
		if (!corner_sample_tracker.has(corner)):
			corner_sample_tracker.set(corner, _sample(corner));
	
func _sample(input: Vector2) -> float:
	return noise.get_noise_2dv(input);
	
