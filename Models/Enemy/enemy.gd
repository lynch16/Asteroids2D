class_name Enemy
extends SpawnableCharacter2D

@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var move_controller: NavCharacterMovementController = get_node("NavCharacterMovementController");
@onready var vision_area: VisionArea = get_node("VisionArea");
@onready var weapon_controller: CharacterWeapons = get_node("CharacterWeapons");

var damageable: Damageable;

signal target_acquired(target: Node2D);

func _enter_tree() -> void:
	super();
	hurtbox = %Hurtbox2D;
	var collision_shape: CollisionShape2D = get_node("CollisionShape2D");
	hurtbox.shape = collision_shape.shape;
	hurtbox.health_stats = health_stats;
	var health_bar: HealthBarDamageResult = %HealthBarDamageResult;
	health_bar.health_stats = health_stats;
	var death_damage_result: StopOnDeathDamageResult = %StopOnDeathDamageResult;
	death_damage_result.health_stats = health_stats;

func get_patrol_state() -> PatrolState:
	return ($StateMachine/PatrolState as PatrolState);

func _ready() -> void:
	health_stats.on_health_depleted.connect(_die);

func _physics_process(_delta: float) -> void:
	set_first_valid_target();

# This is basically the functionality for a hunter
# TODO: This should really be part of the FSM
func set_first_valid_target() -> void:
	if (weapon_controller.current_weapon && vision_area.can_see_visible_objects()):
		var targeter := weapon_controller.current_weapon.get_targeter();
		var next_target: Node2D;

		# Dont set new target if already tracking one
		if (targeter.target):
			return;

		for t in vision_area.get_visible_objects():
			if (!is_instance_valid(t) && t is CharacterBody2D):
				continue; 

			if (!targeter.is_target_in_sight((vision_area.field_of_view))):
				print("Not in sight");
				continue; 

			if (!targeter.is_target_in_range((vision_area.field_of_view))):
				print("Not in range");
				# Set target to first in sight if no other targets
				if (!next_target):
					next_target = t;
					set_and_notify_target(next_target);
				continue; 

			# If target in sight and in range, set that target and fire
			next_target = t;
			set_and_notify_target(next_target);
			return;
			

func set_target(target: Node2D) -> void:
	var targeter := weapon_controller.current_weapon.get_targeter();
	targeter.set_target(target);

# TODO: This signal should be propagated from the targeter
func set_and_notify_target(target: Node2D) -> void:
	set_target(target);
	target_acquired.emit(target)

func set_target_position(new_position: Vector2) -> void:
	move_controller.update_nav_target(new_position);

func set_start_velocity(_velocity: Vector2) -> void:
	velocity = _velocity;
	move_controller.update_nav_velocity(_velocity);

func _die() -> void:
	# TODO: Die animation
	queue_free();

func enable_dequeue_off_screen() -> void:
	var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D;
	notifier.screen_exited.connect(queue_free);

