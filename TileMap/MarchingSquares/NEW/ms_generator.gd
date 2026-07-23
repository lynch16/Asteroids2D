class_name MS_Generator extends Node2D

@export var source_canvas: MS_Canvas;
@export var source_ms_bitmap: MS_Bitmap;
@export var texture: Texture2D;

func generate_collision_shapes() -> void:
	## Shrink bitmap and canvas to only what we will be using
	source_ms_bitmap.shrink();
	source_canvas.resize(source_ms_bitmap.get_size() * source_canvas.tile_size);
	
	## Convert bitmap to zero, one, or many polygons
	var collision_polygons := source_ms_bitmap.to_polygon_shapes(source_canvas);

	## Create new resources with each polygon
	for polygon in collision_polygons:
		## Isolate a new bitmap and canvas for just this polygon
		var new_bitmap := source_ms_bitmap.get_bitmap_from_polygon(polygon, source_canvas);
		var new_canvas: MS_Canvas = source_canvas.duplicate(true);
		
		## Get min positions of new bitmap
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
			texture
		);

		## Instantiate everything
		var collision := CollisionShape2D.new();
		collision.shape = polygon;
		add_child(collision);
		var mesh_instance := mesher.create_mesh_instance();
		collision.add_child(mesh_instance);
		
