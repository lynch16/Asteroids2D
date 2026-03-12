@tool
class_name Projectile
extends Node2D

@export var speed := 1000.0;

@onready var collision_area_2d: Area2D = get_node("Area2D");
@onready var deal_damage: DealDamage = get_node("DealDamage");

var velocity: Vector2 = Vector2.RIGHT;
var aim_point: Vector2 = Vector2.RIGHT;
var target: Node2D;

func _ready() -> void:
	collision_area_2d.body_entered.connect(_on_body_entered);
	
func on_create(
	weapon: Weapon,
	weapon_aim_point: Vector2,
) -> void:
	global_position = weapon.global_position;
	global_rotation = weapon.global_rotation;
	aim_point = weapon_aim_point;
		
func on_start(
	base_velocity: Vector2,
	launch_target: Node2D = null
) -> void:
	target = launch_target;
	
	var new_velocity := base_velocity + Vector2(speed, 0).rotated(global_rotation + get_angle_to(aim_point));
	velocity = new_velocity;
	
func update(delta: float) -> void:
	global_rotation = velocity.angle();
	position += velocity * delta;
	
func on_hit(hit_node: Node) -> void:
	deal_damage.damage(hit_node);
		
func _process(_delta: float) -> void:
	if !Engine.is_editor_hint() || self != get_tree().edited_scene_root:
		_cull_offscreen();
		
func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint() || self != get_tree().edited_scene_root:
		update(delta);
	
func _cull_offscreen() -> void:
	var viewport := get_viewport_rect().size;
	if (
		global_position.x >= viewport.x || global_position.x <= 0.0 || \
		global_position.y >= viewport.y || global_position.y <= 0.0
	):
		queue_free();

func _on_body_entered(node: Node) -> void:
	on_hit(node);
	queue_free(); 
