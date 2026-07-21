class_name MS_Generator extends Node2D

@export var ms_canvas_2D: MS_Canvas2D;

signal shape_generated(shape: ConvexPolygonShape2D);

func generate_collision_shapes() -> void:
	ms_canvas_2D.ms_bitmap.shrink();
	
	var collision_polygons := ms_canvas_2D.ms_bitmap.bitmap.opaque_to_polygons(
		ms_canvas_2D.canvas.canvas_rect, 1.0
	);

	for polygon in collision_polygons:
		#### TODO:::::
		# Polygon is an array of bitmap verticies
		# Each polygon should become a new MS_BitMap and MS_Canvas
		# To resize, need to normalize the values to shift them to 0,0 position

		var convex_shape := ConvexPolygonShape2D.new();
		var resized_polygon := PackedVector2Array();
		for point in polygon:
			resized_polygon.append(
				Vector2(point.x * ms_canvas_2D.canvas.tile_size, point.y * ms_canvas_2D.canvas.tile_size)
			);

		convex_shape.set_point_cloud(resized_polygon);
		var collision := CollisionShape2D.new();
		collision.shape = convex_shape;
		add_child(collision);
