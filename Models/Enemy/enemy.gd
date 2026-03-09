class_name Enemy
extends CharacterBody2D

@onready var move_controller: NavCharacterMovementController = get_node("NavCharacterMovementController");
@onready var weapon_controller: CharacterWeapons = get_node("CharacterWeapons");

func _physics_process(_delta: float) -> void:
	if (weapon_controller.current_weapon && move_controller.are_targets_in_sight()):
		for t in move_controller.get_targets():
			if (!is_instance_valid(t)):
				return; 
				
			if (weapon_controller.current_weapon.is_target_in_sight((t.global_position)) && weapon_controller.current_weapon.is_target_in_range(t.global_position)):
				if (t is CharacterBody2D):
					var char_t: CharacterBody2D = t;
					weapon_controller.set_weapon_target(char_t);
				
				weapon_controller.current_weapon.use();
			else:
				if (!weapon_controller.current_weapon.is_target_in_range(t.global_position)):
					print("Not in range");
				if (!weapon_controller.current_weapon.is_target_in_sight(t.global_position)):
					print("Not in sight");
