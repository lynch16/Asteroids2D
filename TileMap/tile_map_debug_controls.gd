@tool
class_name TileMapDebugControls
extends Node2D

var dots_lookup: Dictionary[Vector2, bool] = {};
var last_corner_hover: Vector2;

@onready var proc_gen_utils: TileMapProcGen = get_node("..");
@onready var mesh_controls: TileMapMeshControls = get_node("../MeshControls");
@onready var mouse_pos_label: Label = get_node("Label");

func _process(_delta: float) -> void:
	if (visible):
		_track_mouse_hover();
		mouse_pos_label.text = str(get_viewport().get_mouse_position());
		queue_redraw();

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	_draw_dots()
	for k: Vector2 in mesh_controls.tracked_verts.keys():
		var rect := Rect2(k.x - proc_gen_utils.HALF_TILE_SIZE, k.y - proc_gen_utils.HALF_TILE_SIZE, proc_gen_utils.TILE_SIZE, proc_gen_utils.TILE_SIZE);
		draw_rect(rect, Color.ORANGE, false);
		
func _draw_dots() -> void:
	dots_lookup = {};
	proc_gen_utils._for_each_tile(_draw_dot);

func _draw_corner_dot(corner: Vector2) -> void:
	if (dots_lookup.has(corner)):
		return;
			
	var color := Color.RED;
	var corner_sample: int = mesh_controls._get_sample_int_from_vertex(corner);
	if (corner_sample > 0):
		color = Color.GREEN;
		
	if (corner == last_corner_hover):
		color = Color.BLUE;
			
	dots_lookup.set(corner, mesh_controls._get_sample_int_from_vertex(corner));
	draw_circle(corner, proc_gen_utils.DOT_BUTTON_RADIUS, color);

func _draw_center_dot(center: Vector2) -> void:
	draw_circle(center, proc_gen_utils.DOT_BUTTON_RADIUS, Color.PURPLE);
	
func _draw_dot(center: Vector2) -> void:
	_draw_center_dot(center);
	proc_gen_utils._for_each_corner(center, _draw_corner_dot)
	

func _track_mouse_hover() -> void:
	var mouse_position := get_viewport().get_mouse_position();
	var corner := proc_gen_utils._get_position_tile_corner_coord(mouse_position);
	
	if (!last_corner_hover || last_corner_hover != corner):
		last_corner_hover = corner;
