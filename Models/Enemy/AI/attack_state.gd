class_name AttackState
extends FSMState

@onready var move_controller: NavCharacterMovementController = (get_parent() as StateMachine).move_controller;

var player: Player;

var timer := 0.0;
var player_reposition_timeout := 0.2;
var last_known_position: Vector2;

# Transitions: If health low; if enemy dead

func on_enter(_prior_state: FSMState) -> void:
	if (move_controller.are_targets_in_sight()):
		var targets := move_controller.get_targets();
		for t in targets:
			if t is Player:
				player = t;
				break;
	else:
		printerr("AttackState unable to find targets on enter");

func on_update(delta: float) -> void:
	timer += delta;
	
	if (timer >= player_reposition_timeout && is_instance_valid(player)):
		timer = 0.0;
		last_known_position = player.global_position;
		
	# Move towards target
	if (last_known_position):
		move_controller.update_nav_target(last_known_position);

	# See if there is anything between enemy and player
	# If not, fire
	# If so, calculate A* around obstacle until nothing betweeen enemy and player

	# If within range, fire
	
#func on_exit() -> void:
	#pass;
	
