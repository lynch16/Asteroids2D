class_name Hurtbox2D
extends Area2D

@export var combat_stats: CombatStats;
@export var shape: Shape2D;
@export var owner_node: Node;

var damageable: Damageable;

func _init(
	p_combat_stats: CombatStats = CombatStats.new(),
	p_shape: Shape2D = null,
	p_owner_node: Node = null,
) -> void:
	combat_stats = p_combat_stats;
	shape = p_shape;
	owner_node = p_owner_node;

func _ready() -> void:
	monitoring = false;

	var damage_results: Array[DamageResult] = [];
	for child in get_children():
		if (child is DamageResult):
			damage_results.append(child);

	damageable = Damageable.new(   
		combat_stats,
		damage_results,
		owner_node,
	);
	add_child(damageable);

	if (shape != null):
		var collision_shape := CollisionShape2D.new();
		collision_shape.shape = shape;
		add_child(collision_shape);