extends Area2D

@export var grav_const: float = 6.67E-11 # 6.67 x 10^-11 N.m2/kg2
@export var enable_player_gravity: bool = false;
@export var debug_grav_force: bool = false;

var gravity_objects: Array[Variant] = [];

func _ready() -> void:
	body_entered.connect(_on_body_entered);
	
func _physics_process(delta: float) -> void:
	_apply_gravity(delta);
	
func _apply_gravity(delta: float) -> void:
	for node: Variant in gravity_objects:
		if (!is_instance_valid(node)):
			gravity_objects.erase(node);
			return;
		
		var node_mass: float;
		if node is RigidBody2D:
			node_mass = (node as RigidBody2D).mass;
		elif (node is Player):
			node_mass = (node as Player).mass;
			
		var parent: PhysicsBody2D = (get_parent() as PhysicsBody2D);
		var radius: float = node.global_position.distance_to(parent.global_position);
		var grav_force: float = grav_const * ((node_mass * (parent as RigidBody2D).mass)/(radius ** 2)) # G(m1m2/r^2) = F
		var node_vect: Vector2 = parent.global_position - node.global_position;
		if (grav_force > 0 && grav_force < INF):
			var grav_force_vector_delta: Vector2 = grav_force * node_vect * delta;
			
			if (debug_grav_force):
				print("grav_force_vector_delta", grav_force_vector_delta);
			
			if (node is RigidBody2D):
				(node as RigidBody2D).apply_central_force(grav_force_vector_delta);
				
			elif (enable_player_gravity && node is Player):
				var player_accel: Vector2 = Vector2(grav_force, 0).rotated(node_vect.angle());
				(node as Player).velocity += player_accel * delta; 

		
func _on_body_entered(node: Node2D) -> void:
	gravity_objects.append(node);
	
