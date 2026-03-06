class_name AttackState
extends FSMState

@export var vision_area: VisionArea;

var player: Player;

var timer := 0.0;
var player_reposition_timeout := 0.2;
var last_known_position: Vector2;

@onready var stateful_entity: Enemy = (get_parent() as StateMachine).stateful_entity;

# Transitions: If health low; if enemy dead

func on_enter(_prior_state: FSMState) -> void:
	if (vision_area.can_see_targets):
		var targets := vision_area.targets;
		for t in targets:
			if t is Player:
				player = t;
				break;
	else:
		printerr("AttackState unable to find targets on enter");

func on_update(delta: float) -> void:
	timer += delta;
	
	# TODO: Entities need a "turn to function"
	if (timer >= player_reposition_timeout && is_instance_valid(player)):
		timer = 0.0;
		last_known_position = player.global_position;
		
	# Move towards target
	if (last_known_position):
		(stateful_entity as Enemy).set_movement_target(last_known_position);

	# See if there is anything between enemy and player
	# If not, fire
	# If so, calculate A* around obstacle until nothing betweeen enemy and player

	# If within range, fire
	
#func on_exit() -> void:
	#pass;
	
