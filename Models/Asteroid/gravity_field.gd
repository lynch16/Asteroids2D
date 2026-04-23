extends Area2D

@export var grav_const := 6.67E-11 # 6.67 x 10^-11 N.m2/kg2
@export var enable_player_gravity := false;
@export var debug_grav_force := false;

@onready var parent_node: PhysicsBody2D = get_parent();

var gravity_objects: Array[Node2D] = [];

func _ready() -> void:
	body_entered.connect(_on_body_entered);
	
func _physics_process(delta: float) -> void:
	_apply_gravity(delta);
	
func _apply_gravity(delta: float) -> void:
	for i in range(gravity_objects.size()):
		
		var node := gravity_objects[i];
		if (!is_instance_valid(node)):
			gravity_objects.remove_at(i);
			return;
		
		var node_mass := 0.0;
		
		if node is Player:
			var player_node := node as Player;
			node_mass = player_node.movement_stats.mass;
		elif node is Asteroid:
			var aster_node := node as Asteroid;
			node_mass = aster_node.mass;

		var parent_node_mass := 0.0;
		if parent_node is Player:
			var player_node := parent_node as Player;
			node_mass = player_node.movement_stats.mass;
		elif parent_node is Asteroid:
			var aster_node := parent_node as Asteroid;
			node_mass = aster_node.mass;
		
		var radius := node.global_position.distance_to(parent_node.global_position);
		var grav_force: float = grav_const * ((node_mass * parent_node_mass)/(radius ** 2)) # G(m1m2/r^2) = F
		var node_vect: Vector2 = parent_node.global_position - node.global_position;
		if (grav_force > 0 && grav_force < INF):
			var grav_force_vector_delta := grav_force * node_vect * delta;
			
			if (debug_grav_force):
				print("grav_force_vector_delta", grav_force_vector_delta);
			
			if (node is RigidBody2D):
				var rigid_node := node as RigidBody2D;
				rigid_node.apply_central_force(grav_force_vector_delta);
				
			elif (enable_player_gravity && node is Player):
				var player_accel := Vector2(grav_force, 0).rotated(node_vect.angle());
				var player_node := node as Player;
				player_node.velocity += player_accel * delta; 

		
func _on_body_entered(node: Node2D) -> void:
	gravity_objects.append(node);
	
