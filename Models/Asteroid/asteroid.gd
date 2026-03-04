class_name Asteroid extends RigidBody2D

# Change impact spead to use DealDamage

@export var max_velocity := 400; # m/s

@export var debug_collide := false;

var child_number := 0;
var collision_damage := 50.0;

@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");
@onready var shatter_dr: DamageResult = get_node("Damageable/AsteroidShatterDamageResult");
@onready var collision: CollisionShape2D = get_node("AsteroidCollision");

func _ready() -> void:
	add_to_group("enemy");
	_scale_to_child();
	
	body_entered.connect(_on_body_entered);
	
	damageable.on_init(self);
	damageable.on_destroy.connect(_destroy);
	invince_frames_dr.init.connect(_disable_colliders);
	invince_frames_dr.end.connect(_enable_colliders);
	
	shatter_dr.end.connect(_on_max_shatter);
	
	if (debug_collide):
		linear_velocity = Vector2.LEFT * 100000
		
func _disable_colliders() -> void:
	collision.disabled = true;
	
func _enable_colliders() -> void:
	collision.set_deferred("disabled", false);
	
func _on_max_shatter() -> void:
	damageable.die();
	
func _scale_to_child() -> void:
	
	# TEMP: Should be included in the scene details
	var new_scale := 1.0/(pow(2, child_number));
	
	## Smaller asteroid will shatter and destroy with half the force
	damageable.init_health = damageable.init_health * new_scale;
	deal_damage.damage_dealt = deal_damage.damage_dealt * new_scale;
	
	# TODO: Change sprites;
	var collision_shape: CircleShape2D = collision.shape;
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
	deal_damage.damage(body);

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
