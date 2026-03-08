@tool
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
	base_velocity: Vector2
) -> void:
	linear_velocity = base_velocity;

func _on_body_entered(node: Node) -> void:
	if (node.is_in_group("enemy")):
		deal_damage.damage(node);
	
	queue_free(); 
