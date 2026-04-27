class_name MeshDeformHitHurtbox2D
extends MeshDeformHurtbox2D

var lifetime: float;
var hit_log: HitLog;
var deal_damage: DealDamage;

func _init(
	p_combat_stats: CombatStats = CombatStats.new(),
	p_damage_results: Array[DamageResult] = [],
	p_collision_mesh_group: MS_CollisionMeshGroup = null,
	p_mesh_deformation_shapes: Array[MeshDeformationShape] = [],
	p_lifetime: float = 0.0,
	p_hitlog: HitLog = null,
) -> void:
	super(p_combat_stats, p_damage_results, p_collision_mesh_group);
	collision_mesh_group = p_collision_mesh_group;
	mesh_deformation_shapes = p_mesh_deformation_shapes;
	lifetime = p_lifetime;
	hit_log = p_hitlog;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	monitoring = true;
	monitorable = true;
	area_shape_entered.connect(_on_body_shape_entered);

	deal_damage = DealDamage.new(
		combat_stats,
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

func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
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
				var impact_point: Vector2 = collision_points.get(0);
				deal_damage.damage(body, impact_point);
