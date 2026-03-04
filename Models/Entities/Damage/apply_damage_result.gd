class_name ApplyDamageResult
extends DamageResult

signal damage_applied(_dmg: float, _curr_health: float)

func update(_delta: float) -> void:
	pass;

func on_damage(dmg: float, _curr_health: float, _damager_node: Node) -> bool: 
	
	print("on_damage ", dmg, " ", _curr_health);
	
	var maybe_damageable := get_parent();
	if (maybe_damageable is Damageable):
		var damageable: Damageable = maybe_damageable;
		damageable.curr_health -= dmg;
		
		damage_applied.emit(dmg, damageable.curr_health);
	else:
		printerr(self.name + " is not child of Damageable. Unable to apply damage");
		
	return true;

func on_end() -> void:
	end.emit();
	pass;
