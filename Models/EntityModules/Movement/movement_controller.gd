class_name MovementController
extends Node2D
## Moves entities as if they are in space: Based on thrust in direction of travel

@export var movement_stats: MovementStats;
@export var moveable_character: CharacterBody2D;

## TODO: Why is this negative?
@export var flip_speed: float = -TAU * 40.0;

# Track state of inputs given
var ship_direction: float;
var acceleration := Vector2.ZERO;
var current_velocity := Vector2.ZERO;

## Vars to track flip of ship to complete turn and burn
var turn_around_active: float;
var end_flip_rotation: float;
var flip_complete_delta_rotation: float = PI/32;
var on_flip_complete: Callable;

# When boosting, not recharging but will need recharge
# When not boosting, if need recharge && no timer running, create and start timer;
var is_boosting := false;
var is_boost_recharging := false;
var boost_needs_recharge := false;

var is_rubber_banding := false;

var tween: Tween;

@onready var recharge_timer: Timer = $RechargeTimer;

signal movement_updated(velocity: Vector2, rotation: float);
signal energy_updated(remaining_energy: float);

func _ready() -> void:
	ship_direction = moveable_character.rotation;
	current_velocity = moveable_character.velocity;
	recharge_timer.timeout.connect(_start_recharge_boost_energy);

func _physics_process(delta: float) -> void:
	if (turn_around_active):
		_flip_rotation(delta);

	if (is_rubber_banding || acceleration != Vector2.ZERO || !is_equal_approx(ship_direction, moveable_character.rotation)):
		current_velocity = current_velocity + acceleration;
		movement_updated.emit(current_velocity, ship_direction);

		# Reset vars after emitting update to listeners
		acceleration = Vector2.ZERO;

	if (!is_boosting):
		# Create recharge timer if needs to recharge and not already created
		if (boost_needs_recharge && !is_boost_recharging && recharge_timer.is_stopped()):
			recharge_timer.start();

	elif (!recharge_timer.is_stopped()):
		recharge_timer.stop();

	if (is_boost_recharging):
		_recharge_boost_energy(delta);
		
	is_boosting = false;

func move_forward(delta: float) -> void:
	# Apply acceleration to max speed in direction facing
	acceleration = Vector2(movement_stats.acceleration, 0).rotated(ship_direction) * delta;
	
func _recharge_boost_energy(delta: float) -> void:
	_update_ship_energy(movement_stats.current_energy + movement_stats.boost_recharge_speed * delta);
	if (is_equal_approx(movement_stats.current_energy, movement_stats.max_energy)):
		_recharge_complete();

func _start_recharge_boost_energy() -> void:
	if (current_velocity.length() > movement_stats.max_speed):
		is_rubber_banding = true;

		if (tween && tween.is_running()):
			tween.kill();

		tween = create_tween();
		tween.tween_property(self, "current_velocity", current_velocity.limit_length(movement_stats.max_speed), recharge_timer.wait_time);
	
	is_boost_recharging = true;
	boost_needs_recharge = true;

func _recharge_complete() -> void:
	is_boost_recharging = false;
	boost_needs_recharge = false;
	is_rubber_banding = false;

func _update_ship_energy(new_energy: float) -> void:
	movement_stats.current_energy = new_energy;
	energy_updated.emit(movement_stats.current_energy);

func boost_forward(delta: float) -> void:
	if (movement_stats.current_energy <= movement_stats.min_energy):
		return;

	is_boosting = true;
	is_boost_recharging = false;
	boost_needs_recharge = true;

	_update_ship_energy(movement_stats.current_energy - movement_stats.boost_cost_s * delta)
	acceleration = Vector2(movement_stats.acceleration, 0).rotated(ship_direction) * movement_stats.boost_ratio *  delta;

func brake(delta: float) -> void:
	# Apply acceleration to max speed in reverse direction facing
	acceleration = Vector2(-movement_stats.acceleration, 0).rotated(ship_direction) * delta;
	
## Rotate direction of travel to the left
## turn_ratio is used to speed up for hard turns
func yaw_left(delta: float, turn_ratio: float = 1.0) -> void:
	if turn_around_active: 
		print("Can't turn left during turn-and-burn");
		return;

	ship_direction -= movement_stats.rotation_speed * turn_ratio * delta;
	
## Rotate direction of travel to the right
## turn_ratio is used to speed up for hard turns
func yaw_right(delta: float, turn_ratio: float = 1.0) -> void:
	if turn_around_active: 
		print("Can't turn right during turn-and-burn");
		return;
	ship_direction += movement_stats.rotation_speed * turn_ratio * delta;

# TODO: Should not be able to shoot during a turn and burn
func turn_around(_on_flip_complete: Callable) -> void:
	turn_around_active = true;
	# End point is current direction rotated 180*
	end_flip_rotation = fposmod(ship_direction + PI, TAU);
	# Callback after _this_ flip is completed. Calling turn_around multiple times will overwrite this to whatever the end Callable is
	on_flip_complete = _on_flip_complete;

func _flip_rotation(delta: float) -> void:
	var flip_accuracy := fposmod(end_flip_rotation - ship_direction, TAU);
	if (
		flip_accuracy <= flip_complete_delta_rotation || # Clockwise approach
		flip_accuracy >= TAU - flip_complete_delta_rotation # CCW approach
	):
		if (flip_accuracy > PI): # Clockwise
			print("Turn clockwise");
			yaw_right(delta, movement_stats.hard_turn_ratio);
		elif (flip_accuracy <= PI):
			print("Turn CCW");
			yaw_left(delta, movement_stats.hard_turn_ratio);
	else:
		turn_around_active = false;
		on_flip_complete.call();
