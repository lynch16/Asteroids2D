@tool
class_name RangeActor
extends CharacterBody2D

var enabled := false;
@export var orbit_speed := 2.0; #Radians per second
@export var linear_speed := 1000.0 # m/s
@export var movement_type: MovementType = MovementType.Line;
@export var vertical_offset := 0.0;

enum MovementType {
	Circle,
	Line
}

var angle := 0.0;
var radius := 100.0
var linear_dir := 1;

@onready var center := Vector2(620.0, 100.0 + vertical_offset);
@onready var start := Vector2(10.0, 100.0 + vertical_offset);
@onready var weapon_range: WeaponRange = get_parent();

func _ready() -> void:
	PhysicsServer2D.set_active(true);
	if (movement_type == MovementType.Line):
		global_position = start;
	elif (movement_type == MovementType.Circle):
		global_position = center;

func _physics_process(delta: float) -> void:
	if weapon_range.enabled:
		if (movement_type == MovementType.Line):
			_move_across_screen(delta);
		elif (movement_type == MovementType.Circle):
			_orbit_movement(delta);
	
	if (linear_dir == 1):
		rotation = 0;
	else:
		rotation = PI;

func _move_across_screen(delta: float) -> void:
	var new_position := global_position + ((Vector2(linear_speed * linear_dir, 0) ) * delta);
	if (new_position.x >= get_viewport_rect().size.x - 10.0 || new_position.x  <= 0.0):
		linear_dir = linear_dir * -1;
		new_position = global_position + ((Vector2(linear_speed * linear_dir, 0) ) * delta);
	velocity = (new_position - global_position) / delta;
	move_and_slide();

# Spin target in a circle to simulate target movement
func _orbit_movement(delta: float) -> void:
	angle += orbit_speed * delta;
	var new_position := center + Vector2(cos(angle), sin(angle)) * radius;
	velocity = (new_position - global_position) / delta;
	move_and_slide();
