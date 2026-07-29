@tool
class_name MS_Generator extends Node2D

@export var generative_bundle: MS_GenerativeBundle;

signal regenerate(new_bundle: MS_GenerativeBundle);

## Treat all polygons as different parts of the same object
func generate() -> void:
	var collision_polygons := _get_source_collision_polygons();

	for polygon in collision_polygons:
		var collision := CollisionShape2D.new();
		collision.shape = polygon;
		add_child(collision);

	var mesher := MS_Mesh.new(
		generative_bundle.ms_bitmap,
		generative_bundle.ms_canvas,
		generative_bundle.texture
	);

	var mesh_instance := mesher.create_mesh_instance();
	add_child(mesh_instance);

## Treat each polygon within the bitmap as a unique object [br]
## Need to hook up to regenerate to use the shattered objects
func shatter() -> void:
	var source_ms_bitmap := generative_bundle.ms_bitmap;
	var source_canvas := generative_bundle.ms_canvas;
	var collision_polygons := _get_source_collision_polygons();

	## Create new resources with each polygon
	for polygon in collision_polygons:
		## Isolate a new bitmap and canvas for just this polygon
		var new_bitmap := source_ms_bitmap.get_bitmap_from_polygon(polygon, source_canvas);
		var new_canvas: MS_Canvas = source_canvas.duplicate(true);
		
		## Get min positions of new bitmap [br]
		## Use min to update the offset of the polygon points, 
		## essentially removing the dead space from around the polygon positioning
		var min_max_position := new_bitmap.get_min_max_positions()
		var min_pos: Vector2 = min_max_position[0] * new_canvas.tile_size;
		var shifted_points := PackedVector2Array();
		for point in polygon.points:
			shifted_points.append(point - min_pos);
		polygon.points = shifted_points;

		## Shrink the bitmap and canvas to just be the polygon too
		new_bitmap.shrink(true, min_max_position);
		new_canvas.resize(
			new_bitmap.get_size() * new_canvas.tile_size
		);

		var new_bundle := MS_GenerativeBundle.new(
			new_canvas,
			new_bitmap,
			generative_bundle.texture,
		);

		regenerate.emit(new_bundle);

## Shrink bitmap and canvas to only what we will be using
## Convert bitmap to zero, one, or many polygons
func _get_source_collision_polygons() -> Array[ConvexPolygonShape2D]:
	generative_bundle.ms_bitmap.shrink();
	generative_bundle.ms_canvas.resize(generative_bundle.ms_bitmap.get_size() * generative_bundle.ms_canvas.tile_size);
	
	return generative_bundle.ms_bitmap.to_polygon_shapes(generative_bundle.ms_canvas, 0.25);

func collide_with(subtractive_generator: MS_Generator, should_shatter: bool = true) -> void:
	var position_diff := subtractive_generator.global_position - global_position;
	generative_bundle.ms_bitmap.subtract(
		subtractive_generator.generative_bundle.ms_bitmap,
		generative_bundle.ms_canvas.get_tile_position(position_diff)
	);

	if (should_shatter):
		shatter();
	else:
		generate();
