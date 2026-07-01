class_name ThrustAnimations
extends Node2D

var left_thrust: AnimatedSprite2D;
var right_thrust: AnimatedSprite2D;
var center_thrust: AnimatedSprite2D;

func _ready() -> void:
	left_thrust = get_node_or_null("AnimatedThrustSpriteL");
	right_thrust = get_node_or_null("AnimatedThrustSpriteR");
	center_thrust = get_node_or_null("AnimatedThrustSpriteC");

	# Add some randomness to the thrusters so they dont animate in sync
	if (is_instance_valid(left_thrust)):
		left_thrust.frame = 0;
	if (is_instance_valid(right_thrust)):
		right_thrust.frame = 1;
	if (is_instance_valid(center_thrust)):
		center_thrust.frame = 2;

func start_animation() -> void:
	show();
	if (is_instance_valid(left_thrust) && !left_thrust.is_playing()):
		left_thrust.play("default");
	if (is_instance_valid(right_thrust) && !right_thrust.is_playing()):
		right_thrust.play("default");
	if (is_instance_valid(center_thrust) && !center_thrust.is_playing()):
		center_thrust.play("default");

func stop_animation() -> void:
	hide();
	if (is_instance_valid(left_thrust)): left_thrust.pause();
	if (is_instance_valid(right_thrust)): right_thrust.pause();
	if (is_instance_valid(center_thrust)): center_thrust.pause();