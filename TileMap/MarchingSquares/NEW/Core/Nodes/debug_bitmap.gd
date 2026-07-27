class_name DebugBitmap extends Node2D

var debug_renders: Array = [];
var hit_position: Vector2;

func update_renders(new_renders: Array, p_hit_position: Vector2) -> void:
	debug_renders.append_array(new_renders);
	hit_position = p_hit_position;

func _process(_delta: float) -> void:
	global_position = hit_position;
	queue_redraw();

func _draw() -> void:
	_draw_dots();
	_draw_rect();

func _draw_rect() -> void:
	for debug: Array in debug_renders:
		var canvas: MS_Canvas = debug[1];
		draw_rect(canvas.canvas_rect, Color.BLUE, false);

func _draw_dots() -> void:
	for debug: Array in debug_renders:
		var bitmap: MS_Bitmap = debug[0];
		var canvas: MS_Canvas = debug[1];

		for x in bitmap.bitmap_cells.size():
			var row: Array = bitmap.bitmap_cells[x];
			
			for y in row.size():
				var value := bitmap.get_cell(x, y);

				var color := Color.RED;
				color.a = value;
				draw_circle(canvas.get_canvas_pos_from_tile(Vector2i(x, y)), canvas.tile_size/2.0, color);
