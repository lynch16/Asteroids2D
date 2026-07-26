class_name CircleMeshDeformationShape
extends MeshDeformationShape

@export var radius: float;

func _init(
	p_damage: float = 0.0,
	p_shape: CircleShape2D = CircleShape2D.new(),
	p_radius: float = 1.0,
) -> void:
	super._init(p_damage, p_shape);
	radius = p_radius;

func _get_bitmap() -> MS_Bitmap:
	var new_size := Vector2i(radius * 2 + 1, radius * 2 + 1);
	bitmap.resize(new_size);
	for x in range(radius * 2 + 1):
		for y in range(radius * 2 + 1):
			if (abs(x) + abs(y) > radius):
				continue;
			
			bitmap.set_cell(x, y, damage);

	return bitmap;
