class_name Projectile
extends Weapon
## Projectile is a Weapon that is Throwable

@export var throwable: Throwable;
## Used to instantiate the hitbox shape for this projectile
@export var projectile_shape: Shape2D;
## Direction and speed to send this projectile. Determined by thrower
@export var launch_velocity: Vector2;
## Whether to remove projectile from scene on collision
@export var destroy_on_hit: bool = true;

var velocity := Vector2.ZERO;

func _use() -> void:
	assert(projectile_shape != null, "Projectile " + str(get_instance_id()) + " missing collision shape");
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

	## Send that thang
	velocity = launch_velocity;

func _release_on_hit(_node: Area2D) -> void:
	queue_free();
	
func update(delta: float) -> void:
	if (velocity != Vector2.ZERO):
		global_rotation = velocity.angle();
		position += velocity * delta;
	
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