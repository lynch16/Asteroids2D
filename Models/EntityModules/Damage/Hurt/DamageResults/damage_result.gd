class_name DamageResult
extends Node

var damageable: Damageable = null;
var initialized: bool = false;

signal init;
signal end;

func on_init(p_damageable: Damageable) -> void:
	damageable = p_damageable;
	initialized = true;
	init.emit();
	pass;
	
func update(_delta: float) -> void:
	assert(initialized, "DamageResult " + name + " must be initialized before calling update");
	pass;

func on_damage(
	_damage_dealt: float, 
	_damager_node: Node, 
	_hit_position: Vector2,
	_hit_angle: float
) -> bool: 
	return false;

func on_end() -> void:
	end.emit();
	pass;
