extends Node2D

@export var node: Node2D

func _physics_process(_delta: float) -> void:
	_keep_in_viewport();

func _keep_in_viewport() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size;
	var new_position: Vector2 = node.position;
	var requires_clone: bool = false;
	
	if (node.position.x < 0):
		new_position.x = clamp(viewport_size.x + node.position.x, 0, viewport_size.x) # adding position.x to calcuate an appropriate offset from boundary
		requires_clone = true;
		
	if (node.position.x > viewport_size.x):
		new_position.x = clamp(viewport_size.x - node.position.x, 0, viewport_size.x);
		requires_clone = true;
		
	if (node.position.y > viewport_size.y):
		new_position.y = clamp(node.position.y - viewport_size.y, 0, viewport_size.y);
		requires_clone = true;
	
	if (node.position.y < 0):
		new_position.y = clamp(viewport_size.y + node.position.y, 0, viewport_size.y) # adding position.y to calcuate an appropriate offset from boundary
		requires_clone = true;
	
	# Use more complex cloning process instead of repositioning in order to support both static and physics based bodies
	if (requires_clone):
		var clone: Node2D = node.duplicate();
		node.get_parent().add_child(clone);
		clone.transform = node.transform;
		clone.rotation = node.rotation;
		clone.position = new_position;
		if ("velocity" in clone):
			(clone as CharacterBody2D).velocity = (node as CharacterBody2D).velocity;
		elif ("linear_velocity" in clone):
			(clone as RigidBody2D).linear_velocity = (node as RigidBody2D).linear_velocity;
			if (is_zero_approx((clone as RigidBody2D).linear_velocity.length())):
				# Kill clones that have stalled out 
				clone.queue_free();
		node.queue_free();
