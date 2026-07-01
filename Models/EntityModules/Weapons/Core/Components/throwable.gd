@tool
class_name ThrowableComponent
extends Node2D
## This is responsible for throwing an owner node. It needs to receive a velocity and move the thrown node by that amount.

## This is the node that is actually being thrown, ie the projectile node
@export var owner_throwable: Projectile;

var velocity: Vector2;
var throw_angle: float;

func _process(delta: float) -> void:
	if (velocity != null):
		owner_throwable.global_rotation = throw_angle;
		owner_throwable.position += velocity * delta;

## Projectile triggers _use to instantiate
func throw(p_velocity: Vector2, p_throw_angle: float) -> void:
	owner_throwable._use();
	velocity = p_velocity;
	throw_angle = p_throw_angle;