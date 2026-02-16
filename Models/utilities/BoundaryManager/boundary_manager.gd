extends Node2D

@export var node: Node2D

func _physics_process(_delta: float) -> void:
	_keep_in_viewport();

func _keep_in_viewport():
	var viewport_size = get_viewport_rect().size;
	var new_position = node.position;
	var requires_clone = false;
	
	if (node.position.x < 0):
		new_position.x = viewport_size.x + node.position.x # adding position.x to calcuate an appropriate offset from boundary
		requires_clone = true;
		
	if (node.position.x > viewport_size.x):
		new_position.x = viewport_size.x - node.position.x;
		requires_clone = true;
		
	if (node.position.y > viewport_size.y):
		new_position.y = node.position.y - viewport_size.y;
		requires_clone = true;
	
	if (node.position.y < 0):
		new_position.y = viewport_size.y + node.position.y # adding position.y to calcuate an appropriate offset from boundary
		requires_clone = true;
	
	# Use more complex cloning process instead of repositioning in order to support both static and physics based bodies
	if (requires_clone):
		var clone = node.duplicate();
		node.get_parent().add_child(clone);
		clone.transform = node.transform;
		clone.rotation = node.rotation;
		if ("velocity" in clone):
			clone.velocity = node.velocity;
		elif (clone.has_method("add_force")):
			clone.add_force(node.velocity);
		clone.position = new_position;
		node.queue_free();
