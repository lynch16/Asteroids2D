class_name Enemy
extends CharacterBody2D

@onready var move_controller: NavCharacterMovementController = get_node("NavCharacterMovementController");
@onready var weapon_controller: CharacterWeapons = get_node("CharacterWeapons");

func _physics_process(_delta: float) -> void:
	if (move_controller.are_targets_in_sight()):
		for t in move_controller.get_targets():
			if (weapon_controller.current_weapon):
				if (weapon_controller.current_weapon.is_target_in_sight((t.global_position)) && weapon_controller.current_weapon.is_target_in_range(t.global_position)):
					weapon_controller.current_weapon.use();
