class_name AttackPatrolTransition
extends FSMTransition

var has_target: bool = false;
var target_lost_timer: Timer;
var target_lost_timeout: float = 5.0;

func _enter_tree() -> void:
	super();
	target_lost_timer = Timer.new();
	target_lost_timer.wait_time = target_lost_timeout;
	add_child(target_lost_timer);
	target_lost_timer.timeout.connect(_on_target_lost_timeout);

func _on_target_lost_timeout() -> void:
	print("FINISH TIMER LOST");
	has_target = false;

func is_valid() -> bool:
	if (vision_area.has_visible_objects()):
		has_target = true;
		if (!target_lost_timer.is_stopped()):
			target_lost_timer.stop();
	elif (has_target && target_lost_timer.is_stopped()):
		target_lost_timer.start();

	return !has_target;


func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	print("Target Lost!");
	pass;
