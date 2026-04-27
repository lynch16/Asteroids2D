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
	area_entered.connect(_on_body_entered);

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

func _on_body_entered(node: Node) -> void:
	deal_damage.damage(node);
