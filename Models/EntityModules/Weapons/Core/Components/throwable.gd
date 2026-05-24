class_name Throwable
extends Node2D
## This is responsible for throwing an owner node. It needs to receive a velocity and move the thrown node by that amount.

## This is the node that is actually being thrown, ie the projectile node
@export var owner_throwable: EquipItem;

var velocity: Vector2;
var throw_angle: float;

func _process(delta: float) -> void:
	if (velocity != null):
		owner_throwable.global_rotation = throw_angle;
		owner_throwable.position += velocity * delta;

func throw(p_velocity: Vector2, p_throw_angle: float) -> void:
	velocity = p_velocity;
	throw_angle = p_throw_angle;