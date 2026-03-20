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

func _track_edge_verticies(
	tile_center: Vector2, 
	# Track center and normalized vertex
	tracked_verticies: Dictionary[Vector2, Vector2] = {}
) -> Dictionary[Vector2, Vector2]:
	recursion += 1;
	if (recursion > max_recur): return tracked_verticies;
	
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
			if (viewport_rect.has_point(next_tile) && !tracked_verticies.has(next_tile)):
				tracked_verticies.set(tile_center, next_tile_dirs[i]);
				return _track_edge_verticies(next_tile, tracked_verticies);

	return tracked_verticies;
	
#func _get_next_edge(tile_index: int, tile_center: Vector2) -> Vector2:
	#var next_tile_dirs := MSMeshes.NEXT_VERTEX_ARRAYS[tile_index];
	#for i in next_tile_dirs.size():
		#var next_tile := next_tile_dirs[i] * TileMapProcGen.TILE_SIZE + tile_center;
		#var viewport_rect := get_viewport_rect();
		#if (viewport_rect.has_point(next_tile) && !tracked_verts.has(next_tile)):
			#return next_tile;
	#
	#return Vector2(-1.0, -1.0);
	
func _isolate_polygon_from_mesh(tile_center: Vector2) -> PackedVector2Array:
	var tracked_verts := _track_edge_verticies(tile_center);
	return PackedVector2Array(tracked_verts.keys().map(
		func(key: Vector2) -> Vector2:
			return TileMapProcGen.calculate_weighted_vertex(corner_sample_tracker, key, tracked_verts[key])
	));
	
func _filter_corner_samples_by_polygon(polygon: PackedVector2Array) -> Dictionary[Vector2, float]:
	var polygon_corner_tracker: Dictionary[Vector2, float] = {}
	
	return corner_sample_tracker.keys().reduce(
		func(tracker: Dictionary[Vector2, float], key: Vector2) -> Dictionary[Vector2, float]:
			if (Geometry2D.is_point_in_polygon(key, polygon)):
				tracker.set(key, corner_sample_tracker[key]);
				# Expand out to include all connected tiles
				for i in TileMapProcGen.CORNERS.size():
					var center := key - TileMapProcGen.CORNERS[i] * float(TileMapProcGen.HALF_TILE_SIZE);
					# Gather all corners of connected tiles
					for j in TileMapProcGen.CORNERS.size():
						TileMapProcGen.for_each_corner(center, 
							func(corner: Vector2) -> void:
								if (!tracker.has(corner)):
									tracker.set(corner, corner_sample_tracker[corner]);
						);
	
			return tracker;,
		polygon_corner_tracker
	);

func _handle_mouse_right_click() -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	# Determine which tile mouse click is on
	var tile_center := TileMapProcGen.get_position_tile_center_coord(mouse_down_position);
	# Get polygon of outer edges connected to that tile
	var polygon := _isolate_polygon_from_mesh(tile_center);
	# Filter overall corner sample data into just what applies to tiles touching polygon
	var new_corner_samples := _filter_corner_samples_by_polygon(polygon);
	
	var new_mesh_inst := MeshInstance2D.new();
	new_mesh_inst.mesh = TileMapProcGen.generate_mesh(
		get_viewport_rect().size,
		new_corner_samples,
		texture
	);
	new_mesh_inst.texture = texture;
	new_mesh_inst.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;
	add_child(new_mesh_inst);
	new_mesh_inst.owner = get_tree().edited_scene_root
	
	var convex_3d_polygon := new_mesh_inst.mesh.create_convex_shape();
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
	
	var collision := CollisionPolygon2D.new();
	collision.polygon = final_points;
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
	
