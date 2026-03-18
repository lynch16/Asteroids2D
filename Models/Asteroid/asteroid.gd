class_name Asteroid extends RigidBody2D

# Change impact spead to use DealDamage

@export var max_velocity := 400; # m/s

@export var debug_collide := false;
@export var debug_random_movement := false;
@export var asteroid_mesh: AsteroidMesh;

var child_number := 0;
var collision_damage := 50.0;

@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");
@onready var shatter_dr: DamageResult = get_node("Damageable/AsteroidShatterDamageResult");
@onready var collision: CollisionPolygon2D = get_node("AsteroidCollision");
@onready var mesh_instance: MeshInstance2D = get_node("MeshInstance2D");
#@onready var nav_obstacle: NavigationObstacle2D = get_node("NavigationObstacle2D");

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
		linear_velocity = Vector2.LEFT * 100;
		
	if (debug_random_movement):
		var direction := rotation;
		direction += randf_range(0, PI/2);
		rotation = direction + PI/2;
		
		# Fly in the direction we're facing
		var velocity := Vector2(
			10.0, 
			0.0
		);
		linear_velocity =  velocity.rotated(rotation - PI/2);
		
	_populate_mesh();


func _load_collision_polygon() -> void:
	var edge_verts := PackedVector2Array(asteroid_mesh.edge_verticies.keys().map(
		func(key: Vector2) -> Vector2:
			return _calculate_weighted_vertex(key, asteroid_mesh.edge_verticies[key])
	))
	collision.polygon = edge_verts;
	
func _populate_mesh() -> void:
	var mesh := ArrayMesh.new();
	mesh_instance.mesh = mesh;
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, asteroid_mesh.mesh_surface_array);
		
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
	scale = Vector2(new_scale, new_scale);
	
	#if (child_number == 1):
		#sprite.modulate = Color(200, 0, 150, 1);
	#elif (child_number == 2):
		#sprite.modulate = Color(0, 200, 150, 1);

func _physics_process(_delta: float) -> void:
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);
	
func _on_body_entered(body: Node) -> void:
	# TODO: Players don't cause _on_body_entered
	deal_damage.damage(body);

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
