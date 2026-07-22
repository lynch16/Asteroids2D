class_name MS_Generator extends Node2D

@export var ms_canvas_2D: MS_Canvas2D;

signal shape_generated(shape: ConvexPolygonShape2D);

func generate_collision_shapes() -> void:
	ms_canvas_2D.ms_bitmap.shrink();
	
	var collision_polygons := ms_canvas_2D.ms_bitmap.to_polygon_shapes(ms_canvas_2D.canvas);

	for polygon in collision_polygons:
		var collision := CollisionShape2D.new();
		collision.shape = polygon;
		add_child(collision);
