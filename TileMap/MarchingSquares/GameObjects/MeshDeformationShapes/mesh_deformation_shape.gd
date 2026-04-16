class_name MeshDeformationShape
extends Resource

@export var damage: float;
@export var shape: Shape2D;

func _init(
	p_damage: float = 0.0,
	p_shape: Shape2D = CircleShape2D.new()
) -> void:
	damage = p_damage;
	shape = p_shape;
	
func apply_shape(
		_collision_point: Vector2,
	_collision_angle: float,
	_corner_sampling: Dictionary[Vector2, float],
) -> Dictionary[Vector2, float]:
	return _corner_sampling;
	
