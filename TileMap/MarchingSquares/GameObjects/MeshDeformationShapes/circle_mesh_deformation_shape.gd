class_name CircleMeshDeformationShape
extends MeshDeformationShape

@export var radius: int;

func _init(
	p_damage: float = 0.0,
	p_shape: CircleShape2D = CircleShape2D.new(),
	p_radius: int = 1,
) -> void:
	super._init(p_damage, p_shape);
	radius = p_radius;

func get_bitmap() -> MS_Bitmap:
	var new_size := Vector2i(radius * 2 + 1, radius * 2 + 1);
	bitmap.resize(new_size);
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if (abs(x) + abs(y) > radius):
				continue;

			var norm_x := _normalize_cell_point(x);
			var norm_y := _normalize_cell_point(y);

			if (norm_x < new_size.x && norm_x > 0 &&
				norm_y < new_size.y && norm_y > 0):
				bitmap.set_cell(norm_x, norm_y, damage);

	return bitmap;

func _normalize_cell_point(cell_point: int) -> int:
	return radius + cell_point + 1;
