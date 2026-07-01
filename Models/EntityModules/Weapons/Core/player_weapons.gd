class_name PlayerWeapons
extends CharacterWeapons

func _physics_process(_delta: float) -> void:
	# TODO: This should just be an InputComponent
	if (Input.is_action_just_pressed("fire_weapon") && current_weapon):
		current_weapon.use();

