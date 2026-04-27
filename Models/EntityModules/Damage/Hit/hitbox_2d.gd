class_name Hitbox2D
extends Area2D

var attacker_combat_stats: CombatStats;
var lifetime: float;
var shape: Shape2D;
var hit_log: HitLog;
var deal_damage: DealDamage;

func _init(
	p_attacker_combat_stats: CombatStats = CombatStats.new(),
	p_lifetime: float = 0.0,
	p_shape: Shape2D = null,
	p_hit_log: HitLog = null,
) -> void:
	attacker_combat_stats = p_attacker_combat_stats;
	lifetime = p_lifetime;
	shape = p_shape;
	hit_log = p_hit_log;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitorable = false;
	area_entered.connect(_on_body_entered);

	deal_damage = DealDamage.new(
		attacker_combat_stats,
		hit_log
	);
	add_child(deal_damage);
	deal_damage.owner = self;

	if (lifetime > 0.0):
		var timer := Timer.new();
		timer.wait_time = lifetime;
		timer.one_shot = true;
		timer.timeout.connect(queue_free);
		add_child(timer);
		timer.start();

	if (shape != null):
		var collision_shape := CollisionShape2D.new();
		collision_shape.shape = shape;
		add_child(collision_shape);


func _on_body_entered(node: Node) -> void:
	deal_damage.damage(node);
