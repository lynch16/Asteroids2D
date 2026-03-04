class_name Asteroid extends RigidBody2D

# Move shatter and destroy functionality into DamageResults
# Change impact spead to use DealDamage

@export var invincibility_frames_limit := 5;
@export var max_velocity := 400; # m/s

@export var debug_logs := false;
@export var debug_collide := false;

var child_number := 0;
var min_shatter_times := 2

var collision_damage := 50.0;

func _ready() -> void:
	add_to_group("enemy");
	_scale_to_child();
	
	body_entered.connect(_on_body_entered);
	
	$Damageable.on_init(self);
	$Damageable/InvincibleFramesDamageResult.init.connect(_disable_colliders)
	$Damageable/InvincibleFramesDamageResult.end.connect(_enable_colliders)
	
	if (debug_collide):
		linear_velocity = Vector2.LEFT * 100000
		
func _disable_colliders() -> void:
	$AsteroidCollision.disabled = true;
	
func _enable_colliders() -> void:
	$AsteroidCollision.set_deferred("disabled", false);
	
func _scale_to_child() -> void:
	
	# TEMP: Should be included in the scene details
	var new_scale := 1.0/(pow(2, child_number));
	
	## Smaller asteroid will shatter and destroy with half the force
	$Damageable.init_health = $Damageable.init_health * new_scale;
	
	# TODO: Change sprites;
	var collision_shape: CircleShape2D = $AsteroidCollision.shape;
	collision_shape.radius = collision_shape.radius * new_scale;
	
	var sprite: AnimatedSprite2D = $Sprite2D;
	sprite.scale = sprite.scale * new_scale;
	
	if (child_number == 1):
		sprite.modulate = Color(200, 0, 150, 1);;
	elif (child_number == 2):
		sprite.modulate = Color(0, 200, 150, 1);;

func _physics_process(_delta: float) -> void:
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);
	
func _on_body_entered(body: Node) -> void:
	# TODO: Players don't cause _on_body_entered
	if body is Asteroid:
		# Handle Asteroid Collision
		body.on_damage(collision_damage);

func on_damage(damage: float) -> void:
	$Damageable.on_damage(damage);
	
func _destroy() -> void:
	if (debug_logs):
		print("DESTROY");
	call_deferred("queue_free");
	# TODO: Destroy animation
