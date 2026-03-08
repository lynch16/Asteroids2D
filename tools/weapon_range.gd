@tool
extends Node2D

@export var weapon_controller: CharacterWeapons;
@export var enabled := false;

@export_tool_button("Pause", "Callable") var pause := _pause_tool;
var paused := false;

func _ready() -> void:
	PhysicsServer2D.set_active(true);

func _physics_process(_delta: float) -> void:
	if enabled && weapon_controller && weapon_controller.current_weapon:
		weapon_controller.current_weapon.use();

func _pause_tool() -> void:
	print("PAUSE");
	if (paused):
		set_process_mode(ProcessMode.PROCESS_MODE_INHERIT);
	else:
		set_process_mode(ProcessMode.PROCESS_MODE_DISABLED);
		
	paused = !paused;
