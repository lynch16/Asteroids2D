extends RigidBody2D
class_name Bullet

var bullet_speed: int = 300;

func _ready() -> void:
	($VisibleOnScreenNotifier2D as VisibleOnScreenNotifier2D).screen_exited.connect(_on_visible_on_screen_notifier_2d_exited)
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

func _on_body_entered(_node: Node) -> void:
	queue_free(); 
