extends Node2D

@export var node: Node2D

func _physics_process(delta: float) -> void:
	_keep_in_viewport();

func _keep_in_viewport():
	var viewport_size = get_viewport_rect().size;
	
	if (node.position.x < 0):
		node.position.x = viewport_size.x + node.position.x # adding position.x to calcuate an appropriate offset from boundary
	
	if (node.position.x > viewport_size.x):
		node.position.x = viewport_size.x - node.position.x;
		
	if (node.position.y > viewport_size.y):
		node.position.y = node.position.y - viewport_size.y;
	
	if (node.position.y < 0):
		node.position.y = viewport_size.y + node.position.y # adding position.y to calcuate an appropriate offset from boundary
	
