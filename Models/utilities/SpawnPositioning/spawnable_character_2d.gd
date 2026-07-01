class_name SpawnableCharacter2D
extends CharacterBody2D

var shapecast: SpawnShapeCast2D;
var hurtbox: Hurtbox2D;

func _enter_tree() -> void:
	shapecast = SpawnShapeCast2D.new();
	var shape := CircleShape2D.new();
	shape.radius = 200.0;
	shapecast.shape = shape;
	shapecast.collide_with_areas = true;
	add_child(shapecast);

func is_position_overlapping(
	additional_ignored_nodes: Array[Hurtbox2D] = []
) -> bool:
	var all_ignored_nodes := Array(additional_ignored_nodes);
	if (hurtbox):
		all_ignored_nodes.append(hurtbox);
	return shapecast.will_position_collide(velocity, all_ignored_nodes, true);
