@tool
class_name WeaponRange
extends Node2D

@export var weapon_controller: CharacterWeapons;
@export var enabled := false;
@export_tool_button("Pause", "Callable") var pause := _pause_tool;

var paused := false;

@onready var target: RangeActor = get_node("Target");
@onready var shooter: RangeActor = get_node("Shooter");

func _ready() -> void:
	PhysicsServer2D.set_active(true);
	if (target):
		weapon_controller.set_weapon_target(target);

func _physics_process(_delta: float) -> void:
	if enabled && weapon_controller && weapon_controller.current_weapon:
		weapon_controller.current_weapon.use();

func _pause_tool() -> void:
	if (paused):
		set_process_mode(ProcessMode.PROCESS_MODE_INHERIT);
	else:
		set_process_mode(ProcessMode.PROCESS_MODE_DISABLED);
		
	paused = !paused;
