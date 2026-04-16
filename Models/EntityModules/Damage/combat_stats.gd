class_name CombatStats
extends Resource

@export var initial_health := 100.0:
	set(val):
		initial_health = max(0.0, val);
		current_health = initial_health;
var current_health := 0.0:
	set(val):
		var new_health: float = max(0.0, val);
		on_health_changed.emit(current_health, new_health);
		if (new_health == 0.0):
			on_health_depleted.emit();
		current_health = new_health

@export var base_attack_power := 1.0:
	set(val):
		base_attack_power = val;
		current_attack_power = base_attack_power;
var current_attack_power := 1.0;

@export var base_defense := 1.0:
	set(val):
		base_defense = val;
		current_defense = base_defense;
var current_defense := 1.0;

@export var god_mode_enabled: bool = false;

signal on_health_depleted;
signal on_health_changed(old_value: float, new_value: float);

func _init(
	p_initial_health: float = 100.0,
	p_attack_power: float = 1.0,
	p_defense: float = 1.0,
) -> void:
	initial_health = p_initial_health;
	base_attack_power = p_attack_power;
	base_defense = p_defense;
	
func take_damage(damage: float) -> void:
	if (god_mode_enabled):
		return;
		
	current_health -= damage;
	
func heal(heal_amt: float) -> void:
	current_health += heal_amt;

func calculate_damage(base_dmg: float) -> float:
	return _apply_attack_power(base_dmg);

func _apply_attack_power(attack_dmg: float) -> float:
	return current_attack_power * attack_dmg;

func _apply_defense(attack_dmg: float) -> float:
	return current_defense * attack_dmg;
