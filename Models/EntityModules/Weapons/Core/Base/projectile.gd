@tool
class_name Projectile
extends Weapon
## Projectile is a Weapon that is ThrowableComponent

@export var throwable: ThrowableComponent:
	set(value):
		throwable = value;
		update_configuration_warnings();
## Used to instantiate the hitbox shape for this projectile
@export var projectile_shape: Shape2D:
	set(value):
		projectile_shape = value;
		update_configuration_warnings();
## Direction and speed to send this projectile. Determined by thrower
@export var launch_velocity: Vector2;
## Whether to remove projectile from scene on collision
@export var destroy_on_hit: bool = true;
## Shapes used to deform mesh
@export var mesh_deformation_shapes: Array[MeshDeformationShape];

var velocity := Vector2.ZERO;

func _ready() -> void:
	super();
	if (throwable == null):
		throwable = get_node("%ThrowableComponent");

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray();
	if (throwable == null && get_node_or_null("%ThrowableComponent") == null):
		warnings.append("Projectile is missing ThrowableComponent");
	if (projectile_shape == null):
		warnings.append("Projectile is missing Hitbox shape");
	return warnings;

func _use() -> void:
	## Instantiate hitbox on use
	var hitbox := Hitbox2D.new(
		combat_stats,
		0.0, 
		projectile_shape,
		null,
		self,
	);
	add_child(hitbox);
	if (destroy_on_hit):
		hitbox.area_entered.connect(_release_on_hit);

func _release_on_hit(_node: Area2D) -> void:
	queue_free();

func _process(_delta: float) -> void:
	_cull_offscreen();

func _cull_offscreen() -> void:
	var viewport := get_viewport_rect().size;
	if (
		global_position.x >= viewport.x || global_position.x <= 0.0 || \
		global_position.y >= viewport.y || global_position.y <= 0.0
	):
		queue_free();