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

func _ready() -> void:
	# TODO: Enemy health bars
	health_stats.on_health_depleted.connect(_die);

func _physics_process(_delta: float) -> void:
	set_first_valid_target();

func set_first_valid_target() -> void:
	if (weapon_controller.current_weapon && vision_area.can_see_visible_objects()):
		var targeter := weapon_controller.current_weapon.get_targeter();

		## TODO: This should be a smarter way to select the target
		for t in vision_area.get_visible_objects():
			if (!is_instance_valid(t) && t is CharacterBody2D):
				continue; 

			if (!targeter.is_target_in_range((vision_area.field_of_view))):
				print("Not in range");
				continue; 

			if (!targeter.is_target_in_sight((vision_area.field_of_view))):
				print("Not in sight");
				continue; 

			targeter.set_target(t);
			weapon_controller.current_weapon.use();

func set_target_position(new_position: Vector2) -> void:
	move_controller.update_nav_target(new_position);

func set_start_velocity(_velocity: Vector2) -> void:
	velocity = _velocity;
	move_controller.update_nav_velocity(_velocity);

func _die() -> void:
	# TODO: Die animation
	queue_free();

## ENEMY MANAGER
# Spawn enemy along PathFollow2D outside screen
# TODO: Set whether enemy is shoot and scoot or hunters
# TODO: If shoot and scoot, set first target position to a random position in the same quadrant as them then shoot into a different quadrant

## EnemySpawnGroup
# Manages positioning and behavior of the group
# TODO: When one of the group finds a target, the others come hunting
