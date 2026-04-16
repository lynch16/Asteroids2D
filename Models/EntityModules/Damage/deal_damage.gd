class_name DealDamage
extends Node

@export var damage_dealt: float = 0.0;

func damage(node: Node) -> void:
	var damageable := Damageable.get_damageable_node(node);
	if (damageable):
		damageable.on_damage(damage_dealt, owner);
