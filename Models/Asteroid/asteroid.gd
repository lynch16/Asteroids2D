class_name Asteroid extends RigidBody2D

# On ready, pick from 1 of 5 different asteroid options, apply a random rotation and velocity.
# Calculate mass/density based on asteroid option
# This class should instead be OrbitingBody?

@export var shatter_limit_force_total := 50.0; # Total force required to shatter asteroid into pieces
@export var destroy_limit_force_total := 1000.0; # Total force required to destroy asteroid without shatter
@export var invincibility_frames_limit := 5;
@export var max_velocity := 400; # m/s

@export var debug_logs := false;
@export var debug_collide := false;

var impact_speed := 100; # Duration of impact in seconds
var shatter_sum: float = 0;
var destroy_sum: float = 0;
var curr_invinc_frame := 0;
var damping_min := 2e-4;
var damping_max := 8e-5;
var child_angle_spread := PI/8;
var child_number := 1;
var min_shatter_times := 2


func _ready() -> void:
	# TODO: Make disable and invince unified
	# Set disabled after damage applied
	$AsteroidCollision.disabled = true;
	
	body_entered.connect(_on_body_entered);
	start_invincibility_frames();
	
	if (debug_collide):
		linear_velocity = Vector2.LEFT * 100000
		

func _physics_process(_delta: float) -> void:
	if (curr_invinc_frame >= invincibility_frames_limit):
		curr_invinc_frame = 0;
		$AsteroidCollision.disabled = false;
	elif (curr_invinc_frame > 0): 
		curr_invinc_frame += 1;
	
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);

func _on_body_entered(body: Node) -> void:
	# TODO: Players don't cause _on_body_entered
	
	var body_mass: float = 0.0;
	var velocity := Vector2.ZERO;
	if ("mass" in body):
		body_mass = body.mass;
	
	if ("velocity" in body):
		velocity = body.velocity;
	elif ("linear_velocity" in body):
		velocity = body.linear_velocity;
	
	# Determine total force of impact object with (m*v)/t with t = 1s. 
	var impact_force: Vector2 = (body_mass * linear_velocity - velocity)/impact_speed;
	
	if (body is Bullet):
		print("BULLET FORCE: ", impact_force.length());
		print("BULLET body_mass: ", body_mass);
		print("BULLET velocity: ", velocity);
		
	_take_damage(impact_force);

func _take_damage(impact_force: Vector2) -> void:
	var impact_mag := impact_force.length();
	
	# decrement force totals. If destroy is met at the same frame as shatter, destroy. 
	destroy_sum += impact_mag;
	shatter_sum += impact_mag;
	
	print("SHATTER SUM: ", shatter_sum, " ", shatter_limit_force_total, " ", impact_mag);
	
	if (
		(destroy_sum >= destroy_limit_force_total) ||
		child_number == min_shatter_times
	):
		_destroy();
	elif (shatter_sum >= shatter_limit_force_total):
		_shatter(impact_force);
#
func _apply_parent_force_to_child(parent_aster: Asteroid, child_aster: Asteroid, impact_force: Vector2) -> void:
	child_aster.position = parent_aster.position;
	child_aster.global_position = parent_aster.global_position;
	child_aster.linear_velocity = parent_aster.linear_velocity;
	child_aster.rotation = parent_aster.rotation;

	var dampening_ratio := randf_range(damping_min, damping_max);
	var rand_rotation := randf_range(-child_angle_spread, child_angle_spread);
	var rotated_force := impact_force.rotated((impact_force.angle() + rand_rotation)) ;
	child_aster.apply_central_impulse(rotated_force * dampening_ratio); 

# Break up asteroid based on sum of force applied - could come from weapons, ship or other bodies. At min size, dequeue
func _shatter(impact_force: Vector2) -> void:
	if (debug_logs):
		print("SHATTER")
		
	start_invincibility_frames();
	var child_aster1 := AsteroidManager.spawn_asteroid(self);
	var child_aster2 := AsteroidManager.spawn_asteroid(self);
	
	child_aster1.call_deferred("_apply_parent_force_to_child", self, child_aster1, impact_force);
	child_aster2.call_deferred("_apply_parent_force_to_child", self, child_aster2, impact_force);
	
	call_deferred("queue_free"); # Destroy parent
	
func _destroy() -> void:
	if (debug_logs):
		print("DESTROY");
	call_deferred("queue_free");
	# TODO: Destroy animation
	
func start_invincibility_frames() -> void:
	curr_invinc_frame = 1;
