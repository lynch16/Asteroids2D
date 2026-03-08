@tool 

class_name Weapon extends EquipItem

@export var weapon_range: float = 200.0;

var aim_variance := deg_to_rad(15);

func is_target_in_range(target_position: Vector2) -> bool:
	return global_position.distance_to(target_position) <= weapon_range;
	
func is_target_in_sight(target_position: Vector2) -> bool:
	var target_angle := global_position.angle_to(target_position);
	return (global_rotation - target_angle) <= aim_variance;
