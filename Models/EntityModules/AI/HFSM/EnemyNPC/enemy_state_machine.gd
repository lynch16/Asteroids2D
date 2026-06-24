@tool
class_name EnemyStateMachine
extends StateMachine

@export var move_controller: MovementController:
	set(value):
		move_controller = value;
		update_configuration_warnings();

@export var vision_area: VisionArea:
	set(value):
		vision_area = value;
		update_configuration_warnings();

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray();
	if (move_controller == null):
		warnings.append("StateMachine is missing MovementController");
	if (vision_area == null):
		warnings.append("StateMachine is missing VisionArea");
	return warnings;
