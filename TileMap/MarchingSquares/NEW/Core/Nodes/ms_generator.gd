@tool
class_name MS_Generator extends Node2D

@export var generative_bundle: MS_GenerativeBundle;

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

## Treat each polygon within the bitmap as a unique object
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

		## Use minifed bitmap and canvas to create a mesh
		var mesher := MS_Mesh.new(
			new_bitmap,
			new_canvas,
			generative_bundle.texture
		);

		## Instantiate everything
		var collision := CollisionShape2D.new();
		collision.shape = polygon;
		add_child(collision);

		var mesh_instance := mesher.create_mesh_instance();
		add_child(mesh_instance);

## Shrink bitmap and canvas to only what we will be using
## Convert bitmap to zero, one, or many polygons
func _get_source_collision_polygons() -> Array[ConvexPolygonShape2D]:
	generative_bundle.ms_bitmap.shrink();
	generative_bundle.ms_canvas.resize(generative_bundle.ms_bitmap.get_size() * generative_bundle.ms_canvas.tile_size);
	
	return generative_bundle.ms_bitmap.to_polygon_shapes(generative_bundle.ms_canvas, 0.25);
