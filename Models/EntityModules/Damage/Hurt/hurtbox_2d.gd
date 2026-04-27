class_name Hurtbox2D
extends Area2D

@export var combat_stats: CombatStats;
@export var damage_results: Array[DamageResult];
@export var shape: Shape2D;

var damageable: Damageable;

func _init(
	p_combat_stats: CombatStats = CombatStats.new(),
	p_damage_results: Array[DamageResult] = [],
	p_shape: Shape2D = null
) -> void:
	combat_stats = p_combat_stats;
	damage_results = p_damage_results;
	shape = p_shape;

func _ready() -> void:
	monitoring = false;

	damageable = Damageable.new(   
		combat_stats,
		damage_results
	);
	add_child(damageable);
	damageable.owner = owner;

	if (shape != null):
		var collision_shape := CollisionShape2D.new();
		collision_shape.shape = shape;
		add_child(collision_shape);