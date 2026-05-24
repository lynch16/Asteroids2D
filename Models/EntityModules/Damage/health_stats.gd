class_name HealthStats
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

@export var god_mode_enabled: bool = false;

signal on_health_depleted;
signal on_health_changed(old_value: float, new_value: float);

func _init(
	p_initial_health: float = 100.0,
) -> void:
	initial_health = p_initial_health;
	
func take_damage(damage: float) -> void:
	if (god_mode_enabled):
		return;
		
	current_health -= damage;
	
func heal(heal_amt: float) -> void:
	current_health += heal_amt;
