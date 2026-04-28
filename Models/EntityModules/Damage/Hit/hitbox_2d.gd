class_name Hitbox2D
extends Area2D

var attacker_combat_stats: CombatStats;
var lifetime: float;
var shape: Shape2D;
var hit_log: HitLog;
var deal_damage: DealDamage;
var owner_node: Node;

func _init(
	p_attacker_combat_stats: CombatStats = CombatStats.new(),
	p_lifetime: float = 0.0,
	p_shape: Shape2D = null,
	p_hit_log: HitLog = null,
	p_owner_node: Node = null,
) -> void:
	attacker_combat_stats = p_attacker_combat_stats;
	lifetime = p_lifetime;
	shape = p_shape;
	hit_log = p_hit_log;
	owner_node = p_owner_node;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitorable = false;
	area_shape_entered.connect(_on_area_shape_entered);

	deal_damage = DealDamage.new(
		attacker_combat_stats,
		owner_node,
		hit_log,
	);
	add_child(deal_damage);

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

func _on_area_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is Area2D):
		var collision_body: Area2D = body;
		var body_shape_owner := collision_body.shape_find_owner(body_shape_index);
		var body_collider := collision_body.shape_owner_get_owner(body_shape_owner);

		var local_shape_owner := shape_find_owner(local_shape_index);
		var local_collider := shape_owner_get_owner(local_shape_owner);

		if (body_collider is DeformableMeshCollider2D):
			var mesh_collider: DeformableMeshCollider2D = body_collider;
			var local_mesh_collider: CollisionShape2D = local_collider;
			var collision_points := local_mesh_collider.shape.collide_and_get_contacts(
				local_mesh_collider.global_transform,
				mesh_collider.shape,
				mesh_collider.global_transform
			);

			if (collision_points.size() > 0):
				var mesh_impact_point: Vector2 = collision_points.get(0);
				var local_impact_point: Vector2 = collision_points.get(1);
				var impact_angle := (local_impact_point - mesh_impact_point).normalized();
				deal_damage.damage(body, mesh_impact_point, impact_angle.angle());
