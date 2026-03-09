class_name Weapon extends EquipItem

@export var weapon_range: float = 10.0;

var aim_variance := 5;

func is_target_in_range(target_position: Vector2) -> bool:
	return global_position.distance_to(target_position) <= weapon_range;
	
func is_target_in_sight(target_position: Vector2) -> bool:
	var min_aim_angle_with_variance := wrapf(
		rad_to_deg(_aim_angle_rotation() - aim_variance),
		-PI,
		PI
	);
	var max_aim_angle_with_variance := wrapf(
		rad_to_deg(_aim_angle_rotation() + aim_variance),
		-PI,
		PI
	);
	return global_position.angle_to(target_position) <= max_aim_angle_with_variance || (
		global_position.angle_to(target_position) >= min_aim_angle_with_variance
	);
