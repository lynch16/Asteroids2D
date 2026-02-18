extends RigidBody2D

# On ready, pick from 1 of 5 different asteroid options, apply a random rotation and velocity.
# Calculate mass/density based on asteroid option
# This class should instead be OrbitingBody?

@export var shatter_limit_force_total = 50.0; # Total force required to shatter asteroid into pieces
@export var destroy_limit_force_total = 1000.0; # Total force required to destroy asteroid without shatter
@export var invincibility_frames_limit = 5;
@export var min_shatter_radius = 5
@export var max_velocity = 400; # m/s

@export var debug_logs = false;

var impact_speed = 1; # Duration of impact in seconds
var shatter_sum: float = 0;
var destroy_sum: float = 0;
var curr_invinc_frame = 0;

func _ready() -> void:
	body_entered.connect(_on_body_entered);
	start_invincibility_frames();

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
	var velocity = Vector2.ZERO;
	if ("mass" in body):
		body_mass = body.mass;
	
	if ("velocity" in body):
		velocity = body.velocity;
	elif ("linear_velocity" in body):
		velocity = body.linear_velocity;
	
	# Determine total force of impact object with (m*v)/t with t = 1s. 
	var impact_force: Vector2 = (body_mass * velocity)/impact_speed;
	_take_damage(impact_force);

func _take_damage(impact_force: Vector2) -> void:
	var impact_mag = impact_force.length();
	
	# decrement force totals. If destroy is met at the same frame as shatter, destroy. 
	destroy_sum += impact_mag;
	shatter_sum += impact_mag;
	if (debug_logs):
		print("impact_mag: ", impact_mag);
		print("destroy_sum: ", destroy_sum);
		print("shatter_sum: ", shatter_sum);
	
	var curr_radius = ($AsteroidCollision.shape as CircleShape2D).radius;
	
	if (debug_logs):
		print("curr_radius", curr_radius, min_shatter_radius)
	
	if (
		(destroy_sum >= destroy_limit_force_total) ||
		curr_radius <= min_shatter_radius
	):
		_destroy();
	
	if (shatter_sum >= shatter_limit_force_total):
		_shatter.call_deferred(impact_force);

# Break up asteroid based on sum of force applied - could come from weapons, ship or other bodies. At min size, dequeue
func _shatter(impact_force: Vector2) -> void:
	if (debug_logs):
		print("SHATTER");
	
	start_invincibility_frames();
	var child_asteroid1: RigidBody2D = duplicate();
	var child_asteroid2: RigidBody2D = duplicate();
	
	call_deferred("queue_free");
	# TODO: Change sprites;
	var parent = get_parent();
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
	var child1_rad = ((child_asteroid1.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius 
	((child_asteroid1.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius = child1_rad/2;
	(child_asteroid1.get_node("Sprite2D") as AnimatedSprite2D).scale = (child_asteroid1.get_node("Sprite2D") as AnimatedSprite2D).scale * Vector2(0.5, 0.5);
	var child2_rad = ((child_asteroid2.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius 
	((child_asteroid2.get_node("AsteroidCollision") as CollisionShape2D).shape as CircleShape2D).radius = child2_rad/2;
	(child_asteroid2.get_node("Sprite2D") as AnimatedSprite2D).scale = (child_asteroid2.get_node("Sprite2D") as AnimatedSprite2D).scale * Vector2(0.5, 0.5);
	
	if (debug_logs):
		print("IMPULSE :: ", "curr_sum: ", destroy_sum, " total limit: ", destroy_limit_force_total);
		
	# TODO: Adjust impact of object based on vector towards center of gravity
	var impulse_imparted_force = destroy_sum/destroy_limit_force_total * shatter_limit_force_total * impact_force;
	
	child_asteroid1.apply_central_impulse(impulse_imparted_force);
	child_asteroid2.apply_central_impulse(-impulse_imparted_force);
	
func _destroy() -> void:
	if (debug_logs):
		print("DESTROY");
	call_deferred("queue_free");
	# TODO: Destroy animation
	
func start_invincibility_frames() -> void:
	curr_invinc_frame = 1;
