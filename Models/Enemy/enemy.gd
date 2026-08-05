class_name Enemy
extends SpawnableCharacter2D

@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var move_controller: NavCharacterMovementController = get_node("NavCharacterMovementController");
@onready var vision_area: VisionArea = get_node("VisionArea");
@onready var weapon_controller: CharacterWeapons = get_node("CharacterWeapons");

var damageable: Damageable;
var tracked_opponents: Array[Node2D] = [];

signal target_acquired(target: Node2D);

func _enter_tree() -> void:
	super();
	hurtbox = %Hurtbox2D;
	hurtbox.health_stats = health_stats;

func get_patrol_state() -> PatrolState:
	return ($StateMachine/PatrolState as PatrolState);

func _ready() -> void:
	health_stats.on_health_depleted.connect(_die);
	vision_area.on_visible_objects_updated.connect(_track_opponents);

func _track_opponents(tracked_opps: Array[Node2D]) -> void:
	if (tracked_opps.hash() != tracked_opponents.hash()):
		tracked_opponents = tracked_opps;
		# TODO: Using just the first opponent is sloppy but doesn't matter with just one Player
		target_acquired.emit(tracked_opponents[0]);

func set_target(target: Node2D) -> void:
	weapon_controller.set_weapon_target(target);

func set_move_position(new_position: Vector2) -> void:
	move_controller.update_nav_target(new_position);

func set_start_velocity(_velocity: Vector2) -> void:
	velocity = _velocity;
	move_controller.update_nav_velocity(_velocity);

func _die() -> void:
	move_controller.process_mode = Node.PROCESS_MODE_DISABLED;
	var sprite: AnimatedSprite2D = $AnimatedSprite2D;
	sprite.hide();
	get_tree().create_timer(1.0, false).timeout.connect(queue_free);

func enable_dequeue_off_screen() -> void:
	var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D;
	notifier.screen_exited.connect(queue_free);

