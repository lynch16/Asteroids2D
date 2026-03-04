extends RigidBody2D
class_name Bullet

var bullet_speed := 1000;

@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = get_node("VisibleOnScreenNotifier2D");

func _ready() -> void:
	on_screen_notifier.screen_exited.connect(_on_visible_on_screen_notifier_2d_exited)
	body_entered.connect(_on_body_entered)

func _on_visible_on_screen_notifier_2d_exited() -> void:
	queue_free();

func fire_bullet(
	initial_pos: Vector2,
	direction: float,
	base_velocity: Vector2
) -> void:
	global_position = initial_pos;
	rotation = direction + PI/2;;
	apply_central_impulse(base_velocity + Vector2(bullet_speed, 0).rotated(direction))

func _on_body_entered(node: Node) -> void:
	if (node.is_in_group("enemy")):
		deal_damage.damage(node);
	
	queue_free(); 
