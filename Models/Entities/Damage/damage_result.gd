class_name DamageResult
extends Node

signal init;
signal end;

func on_init(_attached_node: Variant) -> void:
	init.emit();
	pass;
	
func update(_delta: float) -> void:
	pass;

func on_damage(_damage_amt: float) -> bool: 
	return false;

func on_end() -> void:
	end.emit();
	pass;
