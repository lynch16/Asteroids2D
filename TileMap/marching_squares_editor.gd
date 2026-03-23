@tool
class_name MarchingSquaresEditor
extends Node2D

@export_tool_button("Reset", "Eraser") var reset := _reset;
@export var noise: FastNoiseLite;
@export var texture: Texture2D;
@export_range(0, 3, 1, "suffix:corners") var cursor_radius := 2;
@export_range(0.0, 1.0, 0.1) var cursor_strength := 0.5;
@export var gradual_change := true;
@export_tool_button("Generate", "EditKey") var generate := _generate_resources;
@export_custom(PROPERTY_HINT_NONE, "suffix:.tres") var file_name: String = "test";
@export_tool_button("Save", "Save") var save := _save;

enum EditorMode {
	READY,
	EDIT_MESH,
	GENERATED
}

const DIRS = [
	Vector2.UP,
	Vector2.UP + Vector2.RIGHT,
	Vector2.RIGHT,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.LEFT,
	Vector2.LEFT + Vector2.UP,
]

var saved_corner_samples: Dictionary[Vector2, float] = {};
var staged_corner_samples: Dictionary[Vector2, float] = {};
var staged_mesh_inst: MeshInstance2D;
var staged_collisions: Array[CollisionShape2D] = [];
var mode: EditorMode;
var last_corner_hover: Vector2;

var is_left_held := false;
var left_click_position: Vector2;
var click_held_threshold := 0.5;
var left_click_start_time := 0.0;

@onready var seed_mesh_instance: MeshInstance2D = get_node("SeedMeshInstance2D");
@onready var mouse_position_label: Label = get_node("MousePosition");
@onready var staging_area: Node2D = get_node("StagingArea");

func _ready() -> void:
	InputMap.load_from_project_settings();
	_reset();
	
func _process(delta: float) -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	mouse_position_label.text = str(mouse_down_position);
	
	var viewport_rect := get_viewport_rect();
	if (visible && viewport_rect.has_point(mouse_down_position) && mode == EditorMode.EDIT_MESH):
		if Input.is_action_just_pressed("left_click"):
			left_click_start_time = Time.get_unix_time_from_system();
			left_click_position = mouse_down_position;
			
		if Input.is_action_just_released("left_click"):
			is_left_held = false;
			
		if (gradual_change):
			if Input.is_action_pressed("shift_left_click"):
				_handle_mouse_click(delta, true);
			elif Input.is_action_pressed("left_click"):
				_handle_mouse_click(delta, false);
				
				if (Time.get_unix_time_from_system() - left_click_start_time >= click_held_threshold):
					is_left_held = true;
				else:
					is_left_held = false;
				
		else:
			if Input.is_action_just_released("shift_left_click"):
				_handle_mouse_click(delta, true);	
			elif Input.is_action_just_released("left_click"):
				_handle_mouse_click(delta, false);
	
	_track_mouse_hover();
	queue_redraw();

func _track_mouse_hover() -> void:
	var mouse_position := get_viewport().get_mouse_position();
	var corner := MarchingSquaresUtility.get_position_tile_corner_coord(mouse_position);
	
	if (!last_corner_hover || last_corner_hover != corner):
		last_corner_hover = corner;
			
func _handle_mouse_click(delta: float, shift_held: bool) -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	var corner := MarchingSquaresUtility.get_position_tile_corner_coord(mouse_down_position);
	
	var all_modified_corners: Array[Vector2] = [corner];
	# TODO: This misses a corner when radius is big enough
	for dir: Vector2 in DIRS:
		for cursor_extension in range(0, cursor_radius + 1):
			var modified_corner := corner + dir * MarchingSquaresUtility.TILE_SIZE * cursor_extension;
			if (!all_modified_corners.has(modified_corner)):
				all_modified_corners.append(modified_corner);
	for modified_corner in all_modified_corners:
		if (saved_corner_samples.has(modified_corner)):
			var current_val: float = saved_corner_samples.get(modified_corner);
			var new_val := current_val;
			var cursor_strength_delta := cursor_strength * delta;
			if !gradual_change:
				new_val = -1.0 if shift_held else 1.0;
			elif shift_held:
				new_val -= cursor_strength_delta;
			else:
				new_val += cursor_strength_delta;
			new_val = clamp(new_val, -1.0, 1.0);
			saved_corner_samples.set(modified_corner, new_val);
			
	_generate_mesh_from_saved_samples();
#
func _generate_resources() -> void:
	var viewport_rect := get_viewport_rect();
	#var mouse_down_position := get_viewport().get_mouse_position();
	## Determine which tile mouse click is on
	#var staged_tile_center_generate_point := TileMapProcGen.get_position_tile_center_coord(mouse_down_position);
	## Get polygon of outer edges connected to that tile. This polygon is not guaranteed to exactly match mesh
	#var rough_polygon := TileMapProcGen._isolate_polygon_from_mesh(staged_tile_center_generate_point, viewport_rect, saved_corner_samples);
	## Filter overall corner sample data into just what applies to tiles touching polygon
	#staged_corner_samples = TileMapProcGen._filter_corner_samples_by_polygon(
		#rough_polygon,
		#saved_corner_samples
	#);
	#
	#print("staged_corner_samples: ", staged_corner_samples)

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
	TileMapProcGen._upsert_new_mesh_instance(viewport_rect, saved_corner_samples, texture, staged_mesh_inst)
	staging_area.add_child(staged_mesh_inst);
	staged_mesh_inst.owner = get_tree().edited_scene_root
	
	var collision_shapes := TileMapProcGen._generate_collision_shapes(
		viewport_rect,
		saved_corner_samples
	)
	
	for shape in collision_shapes:
		var collision := CollisionShape2D.new();
		collision.shape = shape;
		staging_area.add_child(collision);
		collision.owner = get_tree().edited_scene_root

func _sample_viewport() -> void:
	# TODO: Check if in ready mode and if not, show popup warning to clear and resample
	saved_corner_samples.clear();
	var viewport_size := get_viewport_rect().size;
	
	MarchingSquaresUtility.for_each_tile(viewport_size, _save_corner_samples);
	_generate_mesh_from_saved_samples();
	mode = EditorMode.EDIT_MESH;
	
func _generate_mesh_from_saved_samples() -> void:
	var viewport_size := get_viewport_rect().size;
	seed_mesh_instance.mesh = MarchingSquaresGenerate.generate_mesh(viewport_size, saved_corner_samples, texture);
	
func _save_corner_samples(center: Vector2) -> void:
	for i: int in MarchingSquaresUtility.CORNERS.size():
		var corner := center + MarchingSquaresUtility.CORNERS[i] * float(MarchingSquaresUtility.HALF_TILE_SIZE);
		if (!saved_corner_samples.has(corner)):
			saved_corner_samples.set(corner, _sample(corner));
	
func _sample(input: Vector2) -> float:
	return noise.get_noise_2dv(input);
	
func _reset() -> void:
	seed_mesh_instance.mesh = null;
	saved_corner_samples = {};
	for child in staging_area.get_children():
		child.queue_free();
	staged_collisions = [];
	mode = EditorMode.READY;
	_sample_viewport();

func _save() -> void:
	# TODO: Overwrite protection
	var collision_shapes: Array[Shape2D] = [];
	for collision in staged_collisions:
		collision_shapes.append(collision.shape);
	
	var asteroid_mesh := AsteroidMesh.new(
		staged_mesh_inst.mesh as ArrayMesh,
		texture,
		staged_corner_samples,
		collision_shapes
	);
	
	ResourceSaver.save(asteroid_mesh, "res://TileMap/AsteroidMesh/" + file_name + ".tres");

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	_draw_dots();
	# TODO: Draw click and hold box to filter mesh and collision by it then implement the mesh and collision generation
		
func _draw_dots() -> void:
	var viewport_size := get_viewport_rect().size;
	MarchingSquaresUtility.for_each_tile(viewport_size, _draw_dot);

func _draw_corner_dot(corner: Vector2) -> void:
	if (!saved_corner_samples.has(corner)):
		return;
			
	var color := Color.RED;
	var corner_val: float = saved_corner_samples.get(corner);
	#var corner_sample: int = MarchingSquaresUtility.get_sample_int_from_vertex(corner, mesh_controls.saved_corner_samples);
	
	if (last_corner_hover && last_corner_hover.distance_to(corner) > MarchingSquaresUtility.TILE_SIZE * cursor_radius):
		return;
	
	if (corner_val > 0.0):
		color = Color.GREEN;
		
	if (corner == last_corner_hover):
		color = Color.BLUE;
	
	color.a = abs(corner_val);
	
	draw_circle(corner, MarchingSquaresUtility.DOT_BUTTON_RADIUS, color);

func _draw_dot(center: Vector2) -> void:
	MarchingSquaresUtility.for_each_corner(center, _draw_corner_dot)
