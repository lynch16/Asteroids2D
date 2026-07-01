@tool 
class_name EquipItem 
extends Node2D

@export var use_rate: float = 0.5;

var last_use_time: float;
var can_use: bool = true;
var owner_character: CharacterBody2D;

@export_category("Optional components for additional features")
@export var targeter: TargeterComponent:
	set(value):
		targeter = value;
		update_configuration_warnings();

func set_target(new_target: Node2D) -> void:
	if (!targeter):
		printerr("Use of set_target on " + name + " requires TargeterComponent");
		return;

	targeter.set_target(new_target);

## Expose targeter up to the wielder
func get_targeter() -> TargeterComponent:
	if (!targeter):
		printerr("Use of set_target on " + name + " requires TargeterComponent");
		return targeter;

	return targeter;

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray();
	if (targeter == null && get_node_or_null("%TargeterComponent") == null):
		warnings.append("Projectile is missing TargeterComponent");
	return warnings;

func _ready() -> void:
	if (targeter == null):
		targeter = get_node_or_null("%TargeterComponent");
	
func equip() -> void:
	pass;
	
func unequip() -> void:
	pass;
	
func use() -> void:
	_try_use();
	
func _try_use() -> bool:
	if (!can_use):
		return false;
		
	 # Check if has been long enough since last used
	if (Time.get_unix_time_from_system() - last_use_time < use_rate):
		return false;
	
	last_use_time = Time.get_unix_time_from_system();
	_use();
	
	return true;
	
func _use() -> void:
	pass;
	
