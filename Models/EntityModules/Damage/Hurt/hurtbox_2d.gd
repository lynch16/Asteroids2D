class_name Hurtbox2D
extends Area2D

@export var combat_stats: CombatStats;
@export var damage_results: Array[DamageResult];

var damageable: Damageable;

func _ready() -> void:
	monitoring = false;

	damageable = Damageable.new(   
		combat_stats,
		damage_results
	);

func receive_hit(damage: float, attacker: Node) -> void:
	damageable.on_damage(damage, attacker);
