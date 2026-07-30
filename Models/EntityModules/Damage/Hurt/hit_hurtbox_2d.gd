class_name HitHurtbox2D
extends Hurtbox2D
## The generated collisions from MS_CollisionMeshGroup are used as both the hitbox and hurtbox.

@export var lifetime: float;
@export var combat_stats: CombatStats;

var deal_damage: DealDamage;
var hit_log: HitLog;

func _init(
	p_health_stats: HealthStats = HealthStats.new(),
	p_shape: Shape2D = null,
	p_owner_node: Node = null,
	p_combat_stats: CombatStats = CombatStats.new(),
	p_lifetime: float = 0.0,
	p_hitlog: HitLog = HitLog.new(),
) -> void:
	super(p_health_stats, p_shape, p_owner_node);
	combat_stats = p_combat_stats;
	lifetime = p_lifetime;
	hit_log = p_hitlog;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	monitoring = true;
	monitorable = true;
	area_shape_entered.connect(_on_area_shape_entered);

	deal_damage = DealDamage.new(
		combat_stats,
		owner_node,
		hit_log
	);
	add_child(deal_damage);

	if (lifetime > 0.0):
		var timer := Timer.new();
		timer.wait_time = lifetime;
		timer.one_shot = true;
		timer.timeout.connect(queue_free);
		add_child(timer);
		timer.start();

	match combat_stats.faction:
		FactionStats.Faction.PLAYER:
			set_collision_mask_value(2, true);
		FactionStats.Faction.ENEMY:
			set_collision_mask_value(1, true);
		FactionStats.Faction.ENVIRONMENT:
			set_collision_mask_value(1, true);
			set_collision_mask_value(2, true);

func _on_area_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is Area2D):
		var collision_body: Area2D = body;
		var body_shape_owner := collision_body.shape_find_owner(body_shape_index);
		var body_collider := collision_body.shape_owner_get_owner(body_shape_owner);
		var mesh_shape: Shape2D = collision_body.shape_owner_get_shape(body_shape_owner, body_shape_index);

		var local_shape_owner := shape_find_owner(local_shape_index);
		var local_collider := shape_owner_get_owner(local_shape_owner);
		var local_shape: Shape2D = shape_owner_get_shape(local_shape_owner, local_shape_index);

		if (body_collider is Node2D):
			var mesh_collider: Node2D = body_collider;
			var local_mesh_collider: Node2D = local_collider;
			var collision_points := local_shape.collide_and_get_contacts(
				local_mesh_collider.global_transform,
				mesh_shape,
				mesh_collider.global_transform
			);

			if (collision_points.size() > 0):
				var mesh_impact_point: Vector2 = collision_points.get(0);
				var local_impact_point: Vector2 = collision_points.get(1);
				var impact_angle := (local_impact_point - mesh_impact_point).normalized();
				deal_damage.damage(body, mesh_impact_point, impact_angle.angle());
