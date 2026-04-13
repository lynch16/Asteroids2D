class_name PlayerWeapons
extends CharacterWeapons

func _physics_process(_delta: float) -> void:
	if (Input.is_action_pressed("fire_weapon") && current_weapon):
		current_weapon.use();
