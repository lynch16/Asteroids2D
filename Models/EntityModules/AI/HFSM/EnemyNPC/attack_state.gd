class_name AttackState
extends EnemyState

var target_reposition_timeout := 0.2;
var timer := 0.0;
var last_known_position: Vector2;

@export var weapon_controller: CharacterWeapons;

# Transitions: If health low; if enemy dead

func on_enter(_prior_state: FSMState) -> void:
	if (vision_area.has_visible_objects()):
		_set_first_valid_target();
	else:
		printerr("AttackState unable to find targets on enter");

func on_update(delta: float) -> void:
	timer += delta;

	var targeter := weapon_controller.current_weapon.get_targeter();
	
	if (timer >= target_reposition_timeout && is_instance_valid(targeter.target)):
		timer = 0.0;
		last_known_position = targeter.target.global_position;
		
	# Move towards target
	if (last_known_position):
		move_controller.update_nav_target(last_known_position);

	# TODO: This is causing enemy to attack if it sees the player, not just when it can hit. Keep for realism?
	if (weapon_controller.current_weapon && vision_area.can_see_node(targeter.target)):
		weapon_controller.current_weapon.use();

func _set_first_valid_target() -> void:
	if (weapon_controller.current_weapon && vision_area.has_visible_objects()):
		var targeter := weapon_controller.current_weapon.get_targeter();
		var next_target: Node2D;

		# Dont set new target if already tracking one
		if (targeter.target):
			return;

		for t in vision_area.get_visible_objects():
			if (!is_instance_valid(t) && t is CharacterBody2D):
				continue; 

			if (!targeter.is_target_in_sight((vision_area.field_of_view))):
				print("Not in sight");
				continue; 

			if (!targeter.is_target_in_range((vision_area.field_of_view))):
				print("Not in range");
				# Set target to first in sight if no other targets
				if (!next_target):
					next_target = t;
					weapon_controller.set_weapon_target(next_target);
				continue; 

			# If target in sight and in range, set that target and fire
			next_target = t;
			weapon_controller.set_weapon_target(next_target);
			return;
	
