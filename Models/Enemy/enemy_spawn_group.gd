class_name EnemySpawnGroup
extends SpawnPath2D
## Manages positioning and behavior of the group. Spawn enemy along PathFollow2D outside screen
# Set whether enemy is shoot and scoot or hunters
# If shoot and scoot, set first target position to a random position in the same quadrant as them then shoot into a different quadrant. 
# Enemy retreats after shooting in the direction they came 
# If hunters, they move across the screen and then fan out to search for the player. When one of the group finds a target, the others come hunting.

@export var num_enemies := 1;

## Buffer in pixels from the edge on which to set first target
@export var target_quadrant_buffer := 200;
@export var spawn_group_spacing := 50.0;

enum PatrolMode {
	ShootRandom = 0,
	Hunt = 1,
}

@export var patrol_mode: PatrolMode

var enemies: Array[Enemy] = [];
var spawn_quadrant: int;
var squad_lead: Enemy;

func _init(
	p_num_enemies: int = 1,
) -> void:
	num_enemies = p_num_enemies;

func _ready() -> void:
	var all_hurtboxes: Array[Hurtbox2D] = [];

	for i in num_enemies:
		var enemy := EnemyManager.create_enemy();
		enemies.append(enemy);
		all_hurtboxes.append(enemy.hurtbox);

	squad_lead = enemies[0];
	set_start_position_velocity(squad_lead, all_hurtboxes)
	spawn_quadrant = _calculate_screen_quadrant(squad_lead.global_position);

	match(patrol_mode):
		PatrolMode.Hunt:
			_create_hunter_group();
		PatrolMode.ShootRandom:
			_create_shoot_scoot_group();

func _intialize_flying_v(target_position: Vector2) -> void:
	var offset_vector := Vector2(0, 0);
	match(spawn_quadrant):
		0: 
			offset_vector = Vector2(1, -1);
		1: 
			offset_vector = Vector2(-1, -1);
		2: 
			offset_vector = Vector2(-1, 1);
		3: 
			offset_vector = Vector2(1, 1);

	for i in num_enemies:
		if (i == 0): 
			continue;

		var target_offset := offset_vector * i * spawn_group_spacing;
		if (i % 2 == 0):
			target_offset = offset_vector.rotated(PI/2) * i * spawn_group_spacing;

		enemies[i].global_position = squad_lead.global_position + target_offset;
		var calculated_target := target_position + target_offset;
		enemies[i].global_rotation = squad_lead.global_rotation
		enemies[i].set_target_position(calculated_target);
		enemies[i].set_start_velocity(squad_lead.velocity);

func _update_group_target(target: Node2D) -> void:
	for enemy in enemies: 
		enemy.set_target(target);

func _create_hunter_group() -> void:
	var opposite_quad: int = wrap(spawn_quadrant + 2, 0, 3);
	var target_position := _get_screen_quadrant_position(opposite_quad);
	squad_lead.set_target_position(target_position);
	_intialize_flying_v(target_position);

	for enemy in enemies:
		var enemy_patrol_state := enemy.get_patrol_state();
		enemy_patrol_state.randomize_target_on_end = true;
		enemy.target_acquired.connect(_update_group_target);

	# Should be a different sprite than shoot/scoot to tell the player
	# Move to a position in the space as a group based on spawn quadrant 
		# TODO: See if it would be better to pick first destination on the opposite side of the map sometimes

	# After first location, split up and hunt individually
	# If one locates, inform the other ones to come - they should change color again when they are hunting
	# TODO: How to break free of hunt group

func _create_shoot_scoot_group() -> void:
	var target_position := _get_screen_quadrant_position(spawn_quadrant);
	# Move into nearest quadrant from spawn
	squad_lead.set_target_position(target_position);
	_intialize_flying_v(target_position);

	for i in enemies.size():
		var enemy_patrol_state := enemies[i].get_patrol_state();
		enemy_patrol_state.randomize_target_on_end = false;
		enemy_patrol_state.set_on_navigation_finished(_shoot_and_scoot.bind(enemies[i]));
	# TODO: Need test bed for this

func _shoot_and_scoot(enemy: Enemy) -> void:
	# Pick a direction and shoot
	# TODO: Pick random direction within a slight variation range
		# TODO: Rotate to that direction and shoot
	var enemy_patrol_state := enemy.get_patrol_state();
	enemy_patrol_state.randomize_target_on_end = false;
	# TODO: Enemy is shooting themselves again if weapon point is too close to body
	enemy.weapon_controller.current_weapon.use();
	enemy_patrol_state.move_controller.turn_around(_run_off_screen.bind(enemy));

func _run_off_screen(enemy: Enemy) -> void:
	# TODO: Dequeue off screen
	var max_screen_size := get_viewport_rect().end.length();
	var off_screen := enemy.global_position + -enemy.velocity.normalized() * max_screen_size;
	enemy.set_target_position(off_screen);
	enemy.enable_dequeue_off_screen();

func _get_screen_quadrant_position(quadrant: int) -> Vector2:
	var x_pos_min := 0.0;
	var x_pos_max := 0.0;
	var y_pos_min := 0.0;
	var y_pos_max := 0.0;

	match(quadrant):
		# Top left
		0:
			x_pos_min = target_quadrant_buffer;
			x_pos_max = get_viewport_rect().size.x / 2.0;
			y_pos_min = target_quadrant_buffer;
			y_pos_max = get_viewport_rect().size.y / 2.0;
		# Top right
		1:
			x_pos_min = get_viewport_rect().size.x / 2.0;
			x_pos_max = get_viewport_rect().size.x - target_quadrant_buffer;
			y_pos_min = target_quadrant_buffer;
			y_pos_max = get_viewport_rect().size.y / 2.0;
		# Bottom left
		2:
			x_pos_min = 0.0;
			x_pos_max = get_viewport_rect().size.x / 2.0
			y_pos_min = get_viewport_rect().size.y / 2.0;
			y_pos_max = get_viewport_rect().size.y - target_quadrant_buffer;
		# Bottom right
		3:
			x_pos_min = get_viewport_rect().size.x / 2.0;
			x_pos_max = get_viewport_rect().size.x - target_quadrant_buffer;
			y_pos_min = get_viewport_rect().size.y / 2.0;
			y_pos_max = get_viewport_rect().size.y - target_quadrant_buffer;

	x_pos_min = clampf(x_pos_min, target_quadrant_buffer, get_viewport_rect().size.x - target_quadrant_buffer);
	x_pos_max = clampf(x_pos_max, target_quadrant_buffer, get_viewport_rect().size.x - target_quadrant_buffer);
	y_pos_min = clampf(y_pos_min, target_quadrant_buffer, get_viewport_rect().size.y - target_quadrant_buffer);
	y_pos_max = clampf(y_pos_max, target_quadrant_buffer, get_viewport_rect().size.y - target_quadrant_buffer);

	return Vector2(randf_range(x_pos_min, x_pos_max), randf_range(y_pos_min, y_pos_max));
