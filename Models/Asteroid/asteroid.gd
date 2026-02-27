extends RigidBody2D
class_name Asteroid

# On ready, pick from 1 of 5 different asteroid options, apply a random rotation and velocity.
# Calculate mass/density based on asteroid option
# This class should instead be OrbitingBody?

@export var limit_force_scaler: float = 10e10
@export var invincibility_frames_limit: int = 5;
@export var max_velocity: int = 400; # m/s
@export var min_destroy_radius: int = 50;

@export var debug_logs: bool = false;

var shatter_limit_force_total: float = 10.0 * limit_force_scaler; # Total force required to shatter asteroid into pieces
var destroy_limit_force_total: float = 100.0 * limit_force_scaler; # Total force required to destroy asteroid without shatter
var impact_speed: float = 1.0; # Duration of impact in seconds
var shatter_sum: float = 0;
var destroy_sum: float = 0;
var curr_invinc_frame: int = 0;

func _ready() -> void:
	body_entered.connect(_on_body_entered);
	start_invincibility_frames();
	#if (debug_logs):
		#print("shatter_limit_force_total ", shatter_limit_force_total);
		#print("destroy_limit_force_total ", destroy_limit_force_total);

func _physics_process(_delta: float) -> void:
	if (curr_invinc_frame >= invincibility_frames_limit):
		curr_invinc_frame = 0;
	elif (curr_invinc_frame > 0): 
		curr_invinc_frame += 1;
	
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);

func _on_body_entered(body: Node) -> void:
	if (curr_invinc_frame > 0): 
		return;
	
	var body_mass: float = 0.0;
	var velocity: Vector2 = Vector2.ZERO;
	
	# bodies can be Players or Rigidbody 2d;
	
	if (body is Player):
		body_mass = body.mass;
		velocity = body.velocity;
	elif (body is RigidBody2D):
		body_mass = body.mass;
		velocity = body.linear_velocity;
	
	# Determine total force of impact object with (m*v)/t with t = 1s. 
	var impact_force: Vector2 = (body_mass * velocity)/impact_speed;
	_take_damage(impact_force);

func _take_damage(impact_force: Vector2) -> void:
	var impact_mag: float = impact_force.length();
	
	# decrement force totals. If destroy is met at the same frame as shatter, destroy. 
	destroy_sum += impact_mag;
	shatter_sum += impact_mag;

	var curr_radius: float = (($AsteroidCollision as CollisionShape2D).shape as CircleShape2D).radius;
	
	if (debug_logs):
		print("impact_mag: ", impact_mag);
		print("curr_radius", curr_radius, min_destroy_radius)
	
	if (
		(destroy_sum >= destroy_limit_force_total) ||
		curr_radius <= min_destroy_radius
	):
		if (debug_logs):
			print("destroy_sum: ", destroy_sum);
			GameManager.pause();
		_destroy();
	
	if (shatter_sum >= shatter_limit_force_total):
		_shatter.call_deferred(impact_force);
		if (debug_logs):
			print("shatter_sum: ", shatter_sum);

# Break up asteroid based on sum of force applied - could come from weapons, ship or other bodies. At min size, dequeue
func _shatter(impact_force: Vector2) -> void:
	start_invincibility_frames();
	var child_asteroid1: Asteroid = duplicate();
	var child_asteroid2: Asteroid = duplicate();
	
	call_deferred("queue_free");
	# TODO: Change sprites;
	var parent: Node = get_parent();
	parent.add_child(child_asteroid1);
	child_asteroid1.start_invincibility_frames();
	parent.add_child(child_asteroid2);
	child_asteroid2.start_invincibility_frames();
	
	# Divide size of object and toughness as part of shatter;
	child_asteroid1.shatter_limit_force_total = shatter_limit_force_total/2;
	child_asteroid2.shatter_limit_force_total = shatter_limit_force_total/2;
	child_asteroid1.destroy_limit_force_total = destroy_limit_force_total/2;
	child_asteroid2.destroy_limit_force_total = destroy_limit_force_total/2;
	
	# TODO: Temp while I create propper sprite scaling
	var child1_rad: float = ((child_asteroid1.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius 
	((child_asteroid1.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius = child1_rad/2;
	(child_asteroid1.get_node("Sprite2D") as AnimatedSprite2D).scale = (child_asteroid1.get_node("Sprite2D") as AnimatedSprite2D).scale * Vector2(0.5, 0.5);
	var child2_rad: float = ((child_asteroid2.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius 
	((child_asteroid2.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius = child2_rad/2;
	(child_asteroid2.get_node("Sprite2D") as AnimatedSprite2D).scale = (child_asteroid2.get_node("Sprite2D") as AnimatedSprite2D).scale * Vector2(0.5, 0.5);
	
	# TODO: Adjust impact of object based on vector towards center of gravity
	var impulse_imparted_force: Vector2 = destroy_sum/destroy_limit_force_total * shatter_limit_force_total * impact_force;
	
	child_asteroid1.apply_central_impulse(impulse_imparted_force);
	child_asteroid2.apply_central_impulse(-impulse_imparted_force);
	
func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
	
func start_invincibility_frames() -> void:
	curr_invinc_frame = 1;
