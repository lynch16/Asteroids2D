@tool
class_name TileMapDebugControls
extends Node2D

var dots_lookup: Dictionary[Vector2, bool] = {};
var last_corner_hover: Vector2;

@export var draw_corner_points := true;

@onready var mesh_controls: TileMapMeshControls = get_node("../MeshControls");
@onready var mouse_pos_label: Label = get_node("Label");

var num_hover_dots := 3.0;

# TODO: When I click on something, I want to be able to highlight the cell I clicked
func _process(_delta: float) -> void:
	_track_mouse_hover();
	mouse_pos_label.text = str(get_viewport().get_mouse_position());
	queue_redraw();

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	_draw_dots()
		
func _draw_dots() -> void:
	dots_lookup = {};
	var viewport_size := get_viewport_rect().size;
	
	TileMapProcGen.for_each_tile(viewport_size, _draw_dot);

func _draw_corner_dot(corner: Vector2) -> void:
	if (!draw_corner_points || dots_lookup.has(corner) || !mesh_controls):
		return;
			
	var color := Color.RED;
	var corner_sample: int = TileMapProcGen.get_sample_int_from_vertex(corner, mesh_controls.saved_corner_samples);
	
	if (last_corner_hover && last_corner_hover.distance_to(corner) > TileMapProcGen.TILE_SIZE * num_hover_dots):
		return;
	
	if (corner_sample > 0):
		color = Color.GREEN;
		
	if (corner == last_corner_hover):
		color = Color.BLUE;
			
	dots_lookup.set(corner, TileMapProcGen.get_sample_int_from_vertex(corner, mesh_controls.saved_corner_samples));
	draw_circle(corner, TileMapProcGen.DOT_BUTTON_RADIUS, color);

func _draw_dot(center: Vector2) -> void:
	TileMapProcGen.for_each_corner(center, _draw_corner_dot)
	
func _track_mouse_hover() -> void:
	var mouse_position := get_viewport().get_mouse_position();
	var corner := TileMapProcGen.get_position_tile_corner_coord(mouse_position);
	
	if (!last_corner_hover || last_corner_hover != corner):
		last_corner_hover = corner;
