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

func _apply_vector(
	collision_point: Vector2,
	_collision_angle: float,
	ms_corner: Vector2,
	corner_value: float,
) -> float:
	if (Geometry2D.is_point_in_circle(ms_corner, collision_point, radius)):
		return corner_value - damage;
	return corner_value;

func apply_shape(
	collision_point: Vector2,
	collision_angle: float,
	corner_sampling: Dictionary[Vector2, float],
) -> Dictionary[Vector2, float]:
	var new_corners: Dictionary[Vector2, float] = {};
	return corner_sampling.keys().reduce(
		func (updated_corners: Dictionary[Vector2, float], key: Vector2) -> Dictionary[Vector2, float]:
			updated_corners[key] = _apply_vector(
				collision_point,
				collision_angle,
				key,
				corner_sampling[key]
			)
			return updated_corners,
		new_corners
	)
