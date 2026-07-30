class_name MeshDeformationShape
extends Resource

@export var damage: float;
@export var shape: Shape2D;

var bitmap: MS_Bitmap;

func _init(
	p_damage: float = 0.0,
	p_shape: Shape2D = CircleShape2D.new()
) -> void:
	damage = p_damage;
	shape = p_shape;

	bitmap = MS_Bitmap.new();

func get_bitmap() -> MS_Bitmap:
	return bitmap
