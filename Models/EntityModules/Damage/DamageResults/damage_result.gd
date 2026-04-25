class_name DamageResult
extends Resource

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
	assert(initialized);
	pass;

func on_damage(_damage_dealt: float, _damager_node: Node) -> bool: 
	return false;

func on_end() -> void:
	end.emit();
	pass;
