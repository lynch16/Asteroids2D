class_name MS_Generator extends Node2D

@export var canvas: MS_Canvas;
@export var ms_bitmap: MS_Bitmap;
@export var texture: Texture2D;

func generate_collision_shapes() -> void:
	ms_bitmap.shrink();
	canvas.resize(ms_bitmap.get_size() * canvas.tile_size);
	
	var collision_polygons := ms_bitmap.to_polygon_shapes(canvas);

	for polygon in collision_polygons:
		var collision := CollisionShape2D.new();
		collision.shape = polygon;
		add_child(collision);

	var mesher := MS_Mesh.new(
		ms_bitmap,
		canvas,
		texture
	);

	var mesh_instance := mesher.create_mesh_instance();
	add_child(mesh_instance);