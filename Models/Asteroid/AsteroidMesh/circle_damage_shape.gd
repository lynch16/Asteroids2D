class_name CircleDamageShape
extends DamageShape

@export var radius: float;

func _init(
	p_damage: float = 0.0,
	p_shape: CircleShape2D = CircleShape2D.new(),
	p_radius: float = 1.0,
) -> void:
	shape = p_shape;
	radius = p_radius;
	damage = p_damage;

func apply_vector(
	collision_point: Vector2,
	ms_corner: Vector2,
	corner_value: float,
) -> float:
	if (Geometry2D.is_point_in_circle(ms_corner, collision_point, radius)):
		return corner_value - damage;
	return corner_value;
