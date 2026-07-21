class_name MS_Canvas2D extends Node2D

@export var canvas: MS_Canvas;
@export_range(0, 10, 1, "suffix:corners") var cursor_radius := 2;

@export var ms_bitmap: MS_Bitmap;

func _ready() -> void:
	if (!ms_bitmap):
		ms_bitmap = MS_Bitmap.new();

	ms_bitmap.resize(canvas.canvas_rect.size);

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		_handle_mouse_click();

	queue_redraw();

# Filters a Dictionary of corner samples to what is contained within the polygon
func _handle_mouse_click() -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	_for_points_in_cursor(mouse_down_position, _update_bitmap);

func _update_bitmap(bit_position: Vector2i) -> void:
	ms_bitmap.set_cellv(bit_position, 1);

## Iterates over all integer positions, executing callable on each position
func _for_points_in_cursor(cursor_position: Vector2, callable: Callable) -> void:
	var tile_position := canvas.get_tile_position(cursor_position);

	for x in range(-cursor_radius, cursor_radius + 1):
		for y in range(-cursor_radius, cursor_radius + 1):
			if (abs(x) + abs(y) > cursor_radius):
				continue;

			var bit_pos := Vector2i(tile_position.x + x, tile_position.y + y);

			if (bit_pos.x > canvas.get_max_x() || bit_pos.y > canvas.get_max_y()):
				continue;

			callable.call(bit_pos);

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	draw_rect(canvas.canvas_rect, Color.AQUA, false);
	_draw_dots();
		
func _draw_dots() -> void:
	for x in ms_bitmap.bitmap_cells.size():
		var row: Array = ms_bitmap.bitmap_cells[x];
		
		for y in row.size():
			var value := ms_bitmap.get_cell(x, y);

			if (value > 0):
				draw_circle(canvas.get_canvas_pos_from_tile(Vector2i(x, y)), cursor_radius * canvas.tile_size/4.0, Color.RED);

