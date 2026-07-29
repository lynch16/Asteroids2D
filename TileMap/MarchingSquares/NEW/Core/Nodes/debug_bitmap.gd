class_name DebugBitmap extends Node2D

var source_bitmap: MS_Bitmap;
var source_canvas: MS_Canvas;

var hit_bitmap: MS_Bitmap;
var tile_hit_position: Vector2i;
var canvas_position: Vector2;

func update_renders(
	p_hit_bitmap: MS_Bitmap,
	p_tile_hit_position: Vector2i,
	p_canvas_position: Vector2,
) -> void:
	hit_bitmap = p_hit_bitmap;
	tile_hit_position = p_tile_hit_position;
	canvas_position = p_canvas_position;

func _process(_delta: float) -> void:
	queue_redraw();

func _draw() -> void:
	_draw_dots();

func _draw_dots() -> void:
	if (hit_bitmap):
		var subtractive_size := hit_bitmap.get_size();
		var this_size := source_bitmap.get_size();

		var subtrative_canvas_size := source_canvas.get_canvas_pos_from_tile(subtractive_size);
		var subtractive_canvas_position := source_canvas.get_canvas_pos_from_tile(tile_hit_position);
		var subtractive_rect := Rect2(
			-canvas_position + subtractive_canvas_position, 
			subtrative_canvas_size
		);

		draw_rect(subtractive_rect, Color.PURPLE, false, 2.0);

		print(hit_bitmap.bitmap_cells)

		for x in range(subtractive_size.x):
			for y in range(subtractive_size.y):
				var associated_bit := Vector2i(tile_hit_position.x + x, tile_hit_position.y + y);
				if (
					associated_bit.x > 0 &&
					associated_bit.y > 0 &&
					associated_bit.x < subtractive_size.x &&
					associated_bit.y < subtractive_size.y
				):
					var color := Color.RED;
					color.a = hit_bitmap.get_cell(x, y);
					draw_circle(
						-canvas_position + source_canvas.get_canvas_pos_from_tile(Vector2i(associated_bit.x, associated_bit.y)), 
						source_canvas.tile_size/2.0, 
						color
					);
