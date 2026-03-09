@tool
extends Node2D

@export var weapon_controller: CharacterWeapons;
@export var enabled := false;
@export var target_movement_type: TargetMovementType = TargetMovementType.Line;

enum TargetMovementType {
	Circle,
	Line
}

var angle := 0.0;
var radius := 100.0
var center := Vector2(620.0, 100.0);
var start := Vector2(10.0, 100.0);
var target_orbit_speed := 2.0; #Radians per second
var target_linear_speed := 100.0 # m/s
var linear_dir := 1;

# TODO: Make target move in straight line instead of circle

@export_tool_button("Pause", "Callable") var pause := _pause_tool;
var paused := false;

@onready var target: CharacterBody2D = get_node("Target");

func _ready() -> void:
	PhysicsServer2D.set_active(true);
	if (target):
		if (target_movement_type == TargetMovementType.Line):
			target.global_position = start;
		elif (target_movement_type == TargetMovementType.Circle):
			target.global_position = center;

func _physics_process(delta: float) -> void:
	if enabled && weapon_controller && weapon_controller.current_weapon:
		if (target_movement_type == TargetMovementType.Line):
			_move_across_screen(delta);
		elif (target_movement_type == TargetMovementType.Circle):
			_orbit_movement(delta);
			
		weapon_controller.current_weapon.use();

func _move_across_screen(delta: float) -> void:
	var new_position := target.global_position + ((Vector2(target_linear_speed * linear_dir, 0) ) * delta);
	if (new_position.x >= get_viewport_rect().size.x - 10.0 || new_position.x  <= 0.0):
		linear_dir = linear_dir * -1;
		new_position = target.global_position + ((Vector2(target_linear_speed * linear_dir, 0) ) * delta);
	target.velocity = (new_position - target.global_position) / delta;
	target.move_and_slide();

# Spin target in a circle to simulate target movement
func _orbit_movement(delta: float) -> void:
	angle += target_orbit_speed * delta;
	var new_position := center + Vector2(cos(angle), sin(angle)) * radius;
	target.velocity = (new_position - target.global_position) / delta;
	target.move_and_slide();

func _pause_tool() -> void:
	if (paused):
		set_process_mode(ProcessMode.PROCESS_MODE_INHERIT);
	else:
		set_process_mode(ProcessMode.PROCESS_MODE_DISABLED);
		
	paused = !paused;
