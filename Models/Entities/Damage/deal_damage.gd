class_name DealDamage
extends Node

@export var damage_dealt: float = 0.0;

func damage(node: Variant) -> void:
	if (node.has_method("on_damage")):
		node.on_damage(damage_dealt);
