class_name PatrolState
extends FSMState


@onready var stateful_entity: CharacterEntity = (get_parent() as StateMachine).stateful_entity;

# Transitions: if enemy seen
# TODO: Patrols should move around the screen, not just fly in one direction

func on_enter(prior_state: FSMState) -> void:
	var last_known_position: Variant = null;
	if prior_state != null:
		last_known_position = prior_state.get("last_known_position");
		if (last_known_position is Vector2):
			var pos_vector: Vector2 = last_known_position;
			stateful_entity.look_at(pos_vector);
			stateful_entity.rotation += PI/2;
			
	if last_known_position == null:
		# Start perpendicular then randomize the direction
		var direction := stateful_entity.rotation;
		direction += randf_range(0, PI);
		stateful_entity.rotation = direction + PI/2;
		
	# Fly in the direction we're facing
	var velocity := Vector2(
		randf_range(stateful_entity.min_velocity, stateful_entity.max_velocity), 
		0.0
	);
	stateful_entity.velocity =  velocity.rotated(stateful_entity.rotation - PI/2);
	pass;

func on_update(_delta: float) -> void:
	# Look for enemy within cone of vision
	stateful_entity.move_and_slide();
	
#func on_exit() -> void:
	#pass;
