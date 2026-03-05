class_name AttackState
extends FSMState

@export var vision_area: VisionArea;

var player: Player;

var timer := 0.0;
var player_reposition_timeout := 0.2;
var player_last_position: Vector2;

@onready var stateful_entity: CharacterEntity = (get_parent() as StateMachine).stateful_entity;

# Transitions: If health low; if enemy dead

func on_enter() -> void:
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
		player_last_position = player.global_position;
		
	# Move towards target
	if (player_last_position):
		stateful_entity.look_at(player_last_position);
		stateful_entity.rotation += PI/2;
		stateful_entity.position = stateful_entity.position.move_toward(player_last_position, stateful_entity.max_velocity * delta);
	
	stateful_entity.move_and_slide();

	# See if there is anything between enemy and player
	# If not, fire
	# If so, calculate A* around obstacle until nothing betweeen enemy and player

	# If within range, fire
	
func on_exit() -> void:
	pass;
	
