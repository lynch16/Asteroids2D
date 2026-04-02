@tool
class_name MarchingSquaresEditor
extends Node2D

@export_category("Seed")
@export var noise: FastNoiseLite;
@export var texture: Texture2D;
@export_tool_button("Reset", "Eraser") var reset := _reset;
@export_tool_button("Seed", "InsertAfter") var seed_map := _seed;
@export_category("Edit Mesh")
@export_range(0, 10, 1, "suffix:corners") var cursor_radius := 2;
@export_range(0.0, 1.0, 0.1) var cursor_strength := 0.5;
@export var gradual_change := true;
@export_enum("Edit Mesh", "Select for Export") var edit_tool_mode: int = 0;
@export_tool_button("Generate for Export", "EditKey") var generate := _generate_resources;
@export_tool_button("Clear", "EditKey") var clear := _clear_staging_area;
@export_tool_button("Regenerate", "EditKey") var regenerate := _regenerate_resources;
@export_category("Save Asteroid Mesh")
@export_custom(PROPERTY_HINT_NONE, "suffix:.tres") var file_name: String = "test";
@export_tool_button("Export", "Save") var save := _save;

const FOLDER_NAME =  "res://Models/Asteroid/AsteroidMesh/"
enum ToolMode {
	EDIT_MESH,
	SELECT_FOR_EXPORT
}

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

var seed_corner_samples: Dictionary[Vector2, float] = {};
var staged_ms_colliders: Array[MS_Collider] = [];
var staged_viewport_samples: Dictionary[Vector2, float] = {};
var mode: EditorMode;
var last_corner_hover: Vector2;

var is_left_held := false;
var left_click_position: Vector2;
var left_release_position: Vector2;
var click_held_threshold := 0.5;
var left_click_start_time := 0.0;

@onready var seed_mesh_instance: MeshInstance2D = get_node("SeedMeshInstance2D");
@onready var mouse_position_label: Label = get_node("MousePosition");
@onready var staging_area: Node2D = get_node("StagingArea");

## As an editor script, we dont want to use the editor viewport
## This size will scale evenly from 720p - 4k
@onready var viewport_rect: Rect2 = Rect2(Vector2(), Vector2(640, 360));

func _ready() -> void:
	InputMap.load_from_project_settings();
	_reset();
	
func _process(delta: float) -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	mouse_position_label.text = str(mouse_down_position);
	
	if (visible && viewport_rect.has_point(mouse_down_position) && mode == EditorMode.EDIT_MESH):
		if Input.is_action_just_pressed("left_click"):
			left_click_start_time = Time.get_unix_time_from_system();
			left_click_position = mouse_down_position;
			left_release_position = Vector2.ZERO;
			
		elif Input.is_action_just_released("left_click"):
			left_release_position = mouse_down_position;
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
	
	if (!last_corner_hover || !corner == MarchingSquaresUtility.OFF_SCREEN && last_corner_hover != corner):
		last_corner_hover = corner;

func _get_points_in_circle(circle_center: Vector2) -> Array[Vector2]:
	var included_points: Array[Vector2] = [];
	var viewport_size := viewport_rect.size;
	var check_each_corner := func (corner: Vector2) -> void:
		if (Geometry2D.is_point_in_circle(corner, circle_center, MarchingSquaresUtility.TILE_SIZE * cursor_radius)):
			included_points.append(corner);
			
	var check_each_tile := func (center: Vector2) -> void:
		MarchingSquaresUtility.for_each_corner(center, check_each_corner);
		
	MarchingSquaresUtility.for_each_tile(viewport_size, check_each_tile)
	
	return included_points;
	
# Filters a Dictionary of corner samples to what is contained within the polygon
func _handle_mouse_click(delta: float, shift_held: bool) -> void:
	if (edit_tool_mode != ToolMode.EDIT_MESH): 
		return;
	
	var mouse_down_position := get_viewport().get_mouse_position();
	var corner := MarchingSquaresUtility.get_position_tile_corner_coord(mouse_down_position);
	
	if (corner == MarchingSquaresUtility.OFF_SCREEN):
		return;
	
	var all_modified_corners: Array[Vector2] = _get_points_in_circle(corner);

	for modified_corner in all_modified_corners:
		if (seed_corner_samples.has(modified_corner)):
			var current_val: float = seed_corner_samples.get(modified_corner);
			var new_val := current_val;
			var cursor_strength_delta := cursor_strength * delta;
			if !gradual_change:
				new_val = -1.0 if shift_held else 1.0;
			elif shift_held:
				new_val -= cursor_strength_delta;
			else:
				new_val += cursor_strength_delta;
			new_val = clamp(new_val, -1.0, 1.0);
			seed_corner_samples.set(modified_corner, new_val);
			
	_generate_mesh_from_saved_samples();

func _regenerate_resources() -> void:
	_clear_staging_area();
	_generate_resources();

func _clear_staging_area() -> void:
	for child in staging_area.get_children():
		child.queue_free();
		
func _generate_resources() -> void:
	var staged_colliders: Array[CollisionShape2D] = [];
	var selected_area := _get_drag_square();
	_clear_staging_area();
	staged_ms_colliders.clear();
	staged_viewport_samples.clear();
	
	for corner in seed_corner_samples:
		if (selected_area.has_point(corner)):
			staged_viewport_samples.set(corner, seed_corner_samples[corner]);
	
	var convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		staged_viewport_samples
	)
	
	for shape in convex_shapes:
		var collision_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(shape.points, staged_viewport_samples);
		var collision := CollisionShape2D.new();
		collision.shape = shape;
		staging_area.add_child(collision);
		collision.owner = get_tree().edited_scene_root
		staged_colliders.append(collision);
		
		
		var mesh := MarchingSquaresGenerate.generate_mesh(
			viewport_rect.size,
			collision_corners,
			texture
		);

		var collision_mesh := MarchingSquaresGenerate.upsert_mesh_instance(mesh, texture);
		collision.add_child(collision_mesh);
		if Engine.is_editor_hint():
			collision_mesh.owner = get_tree().edited_scene_root
		
		staged_ms_colliders.append(
			MS_Collider.new(
				collision,
				collision_mesh,
				collision_corners
			)
		)

	MarchingSquaresGenerate._reposition_colliders(convex_shapes, staged_colliders);

func _sample_viewport() -> void:
	seed_corner_samples.clear();
	var viewport_size := viewport_rect.size;
	
	MarchingSquaresUtility.for_each_tile(viewport_size, _save_corner_samples);
	_generate_mesh_from_saved_samples();
	mode = EditorMode.EDIT_MESH;
	
func _generate_mesh_from_saved_samples() -> void:
	MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, seed_corner_samples, texture, seed_mesh_instance)
	
func _save_corner_samples(center: Vector2) -> void:
	for i: int in MarchingSquaresUtility.CORNERS.size():
		var corner := center + MarchingSquaresUtility.CORNERS[i] * float(MarchingSquaresUtility.HALF_TILE_SIZE);
		if (!seed_corner_samples.has(corner)):
			seed_corner_samples.set(corner, _sample(corner));

func _instantiate_viewport() -> void:
	seed_corner_samples.clear();
	var viewport_size := viewport_rect.size;
	
	MarchingSquaresUtility.for_each_tile(viewport_size, _instantiate_corner_samples);
	mode = EditorMode.EDIT_MESH;
	
func _instantiate_corner_samples(center: Vector2) -> void:
	for i: int in MarchingSquaresUtility.CORNERS.size():
		var corner := center + MarchingSquaresUtility.CORNERS[i] * float(MarchingSquaresUtility.HALF_TILE_SIZE);
		if (!seed_corner_samples.has(corner)):
			seed_corner_samples.set(corner, -1.0);
	
func _sample(input: Vector2) -> float:
	return noise.get_noise_2dv(input);
	
func _reset() -> void:
	seed_mesh_instance.mesh = null;
	seed_corner_samples.clear();
	staged_viewport_samples.clear();
	_clear_staging_area();
	staged_ms_colliders.clear();
	left_release_position = Vector2.ZERO;
	mode = EditorMode.READY;
	_instantiate_viewport();

func _seed() -> void:
	_sample_viewport();

func _save() -> void:
	var final_collisions: Array[AsteroidCollision] = [];
	var children := staging_area.get_children();
	
	for i: int in children.size():
		var associated_stage_index := staged_ms_colliders.find_custom(
			func(ms_collider: MS_Collider) -> bool:
				return ms_collider.collision == children[i];
		);
		var associated_stage := staged_ms_colliders[associated_stage_index];
		
		var asteroid_collision := AsteroidCollision.new(
			associated_stage.mesh_instance.texture,
			associated_stage.corner_sampling,
			associated_stage.collision.shape as ConvexPolygonShape2D,
			associated_stage.mesh_instance.mesh as ArrayMesh,
			associated_stage.collision.position,
			
		);
		final_collisions.append(asteroid_collision);
	
	var asteroid_mesh := AsteroidMesh.new(
		final_collisions,
	);
	
	ResourceSaver.save(asteroid_mesh, FOLDER_NAME + file_name + ".tres");

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	_draw_dots();
	_draw_drag_square();
		
func _draw_dots() -> void:
	var viewport_size := viewport_rect.size;
	var drag_square := _get_drag_square();
	var circle_points: Array[Vector2] = [];
	if last_corner_hover:
		circle_points = _get_points_in_circle(last_corner_hover);
		
	var draw_corner_dot := func(corner: Vector2) -> void:
		if (!seed_corner_samples.has(corner)):
			return;
			
		var color := Color.RED;
		var corner_val: float = seed_corner_samples.get(corner);
	
		if (corner == last_corner_hover):
			color = Color.BLUE;
		elif (corner_val > 0.0):
			color = Color.GREEN;
			
		if (_show_drag_square() && drag_square.has_point(corner)):
			color = Color.PURPLE;
		elif (circle_points.find(corner) == -1):
			return;
			
		color.a = abs(corner_val);
	
		draw_circle(corner, MarchingSquaresUtility.DOT_BUTTON_RADIUS, color);
	
	var draw_dot := func draw_dot(center: Vector2) -> void:
		MarchingSquaresUtility.for_each_corner(center, draw_corner_dot)
	
	MarchingSquaresUtility.for_each_tile(viewport_size, draw_dot);

func _get_drag_square() -> Rect2:
	if (_show_drag_square()):
		var target_square_end :=  get_viewport().get_mouse_position() if left_release_position == Vector2.ZERO else left_release_position;
		var start_position := Vector2(
			left_click_position.x if left_click_position.x < target_square_end.x else target_square_end.x,
			left_click_position.y if left_click_position.y < target_square_end.y else target_square_end.y,
		)
		var rect_size := Vector2(
			absf(left_click_position.x - target_square_end.x),
			absf(left_click_position.y - target_square_end.y),
		)
		return Rect2(start_position, rect_size);
	else:
		return viewport_rect;

func _show_drag_square() -> bool:
	return edit_tool_mode == ToolMode.SELECT_FOR_EXPORT && \
			left_click_position && \
			(is_left_held || left_release_position != Vector2.ZERO);
	
func _draw_drag_square() -> void:
	if (edit_tool_mode != ToolMode.SELECT_FOR_EXPORT): 
		return;
		
	if (_show_drag_square()):
		draw_rect(_get_drag_square(), Color.YELLOW, false);
