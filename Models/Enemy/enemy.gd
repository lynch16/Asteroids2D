class_name Enemy
extends SpawnableCharacter2D

@export var combat_stats: CombatStats;

@onready var move_controller: NavCharacterMovementController = get_node("NavCharacterMovementController");
@onready var target_controller: TargetingController = get_node("TargetingController");
@onready var weapon_controller: CharacterWeapons = get_node("CharacterWeapons");

var damageable: Damageable;

func _enter_tree() -> void:
	super();
	hurtbox = get_node("Hurtbox2D");
	hurtbox.combat_stats = combat_stats;

func _physics_process(_delta: float) -> void:
	if (weapon_controller.current_weapon && target_controller.can_see_targets()):
		for t in target_controller.get_targets():
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

func set_target_position(new_position: Vector2) -> void:
	move_controller.update_nav_target(new_position);

func set_start_velocity(_velocity: Vector2) -> void:
	velocity = _velocity;
	move_controller.update_nav_velocity(_velocity);

## ENEMY MANAGER
# Spawn enemy along PathFollow2D outside screen
# Set whether enemy is shoot and scoot or hunters
# If shoot and scoot, set first target position to a random position in the same quadrant as them then shoot into a different quadrant

## EnemySpawnGroup
# Manages positioning and behavior of the group
# When one of the group finds a target, the others come hunting
