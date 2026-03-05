class_name PatrolState
extends FSMState


@onready var stateful_entity: CharacterEntity = (get_parent() as StateMachine).stateful_entity;

# Transitions: if enemy seen
# TODO: Patrols should move around the screen, not just fly in one direction

func on_enter() -> void:
	# Start perpendicular then randomize the direction
	var direction := stateful_entity.rotation + PI/2;
	direction += randf_range(-PI/4, PI/4)
	stateful_entity.rotation = direction + PI/2;
	
	# Pick a random direction and start flying
	var velocity := Vector2(
		randf_range(stateful_entity.min_velocity, stateful_entity.max_velocity), 
		0.0
	);
	stateful_entity.velocity =  velocity.rotated(direction);
	pass;

func on_update(_delta: float) -> void:
	# Look for enemy within cone of vision
	stateful_entity.move_and_slide();
	
func on_exit() -> void:
	pass;
