class_name Enemy
extends SpawnableCharacter2D

@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var move_controller: NavCharacterMovementController = get_node("NavCharacterMovementController");
@onready var vision_area: VisionArea = get_node("VisionArea");
@onready var weapon_controller: CharacterWeapons = get_node("CharacterWeapons");

var damageable: Damageable;

func _enter_tree() -> void:
	super();
	hurtbox = %Hurtbox2D;
	var collision_shape: CollisionShape2D = get_node("CollisionShape2D");
	hurtbox.shape = collision_shape.shape;
	hurtbox.health_stats = health_stats;

func _physics_process(_delta: float) -> void:
	if (weapon_controller.current_weapon && vision_area.can_see_targets()):
		var targeter := weapon_controller.current_weapon.get_targeter();

		## TODO: This should be a smarter way to select the target
		for t in vision_area.get_targets():
			if (!is_instance_valid(t)):
				return; 

			var prior_target := targeter.target;

			targeter.set_target(t);
				
			if (targeter.is_target_in_sight((vision_area.field_of_view)) && targeter.is_target_in_range(vision_area.view_distance)):
				if (!t is CharacterBody2D):
					targeter.set_target(prior_target);
					return;
				
				weapon_controller.current_weapon.use();
			else:
				if (!targeter.is_target_in_sight((vision_area.field_of_view))):
					print("Not in range");
				if (!targeter.is_target_in_sight((vision_area.field_of_view))):
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
