class_name InputController
extends Node

signal input_up(delta: float);
signal input_back(delta: float);
signal input_left(delta: float);
signal input_right(delta: float);
signal input_boost_start();
signal input_boost_end();

func _physics_process(delta: float) -> void:
	if (Input.is_action_pressed("yaw_left")):
		input_left.emit(delta);
	
	if (Input.is_action_pressed("yaw_right")):
		input_right.emit(delta);
	
	if (Input.is_action_pressed("thrust")):
		input_up.emit(delta);
	
	if (Input.is_action_pressed("brake")):
		input_back.emit(delta);

	if (Input.is_action_just_pressed("boost")):
		input_boost_start.emit();

	if (Input.is_action_just_released("boost")):
		input_boost_end.emit();