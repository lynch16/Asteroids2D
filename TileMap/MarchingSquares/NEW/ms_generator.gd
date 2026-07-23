class_name MS_Generator extends Node2D

@export var canvas: MS_Canvas;
@export var ms_bitmap: MS_Bitmap;
@export var texture: Texture2D;

func generate_collision_shapes() -> void:
	## Shrink bitmap and canvas to only what we will be using
	ms_bitmap.shrink();
	canvas.resize(ms_bitmap.get_size() * canvas.tile_size);
	
	## Convert bitmap to zero, one, or many polygons
	var collision_polygons := ms_bitmap.to_polygon_shapes(canvas);

	## Create new resources with each polygon
	for polygon in collision_polygons:
		## Isolate a new bitmap and canvas for just this polygon
		var new_bitmap := ms_bitmap.get_bitmap_from_polygon(polygon, canvas);
		var new_canvas: MS_Canvas = canvas.duplicate(true);
		
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
		new_bitmap.shrink();
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
		
