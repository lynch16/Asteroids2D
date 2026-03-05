class_name FSMState
extends Node

var transitions: Array[FSMTransition] = [];

func _ready() -> void:
	var children := get_children();
	for child in children:
		if (child is not FSMTransition):
			printerr(child.name + " is not a valid FSM Transition");
		else:
			transitions.push_back(child);

func on_enter() -> void:
	pass;

func on_update(_delta: float) -> void:
	pass;
	
func on_exit() -> void:
	pass;
