class_name DamageShape
extends Resource

@export var damage: float;
@export var shape: Shape2D;

func _init(
	p_damage: float = 0.0,
	p_shape: Shape2D = CircleShape2D.new()
) -> void:
	damage = p_damage;
	shape = p_shape;
	
## Applies the shape impact on the given MarchingSquares corner vector
func apply_vector(
	_collision_point: Vector2,
	_ms_corner: Vector2,
	corner_value: float,
) -> float:
	return corner_value;
	
