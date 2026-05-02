class_name EnemySpawnGroup
extends SpawnPath2D
## Manages spawning enemies in a formation and sets communication among them

@export var num_enemies := 1;

## Buffer in pixels from the edge on which to set first target
@export var target_quadrant_buffer := 200;
@export var spawn_group_spacing := 50.0;

signal win_condition_met;

var enemies: Array[Enemy] = [];

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

	var squad_lead := enemies[0];
	set_start_position_velocity(squad_lead, all_hurtboxes)
	var spawn_quadrant := _calculate_screen_quadrant(squad_lead.global_position);
	var target_position := _get_screen_quadrant_position(spawn_quadrant);
	squad_lead.set_target_position(target_position);

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

func _check_win_condition() -> void:
	if (EnemyManager.get_enemy_count() == 0):
		win_condition_met.emit();

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
