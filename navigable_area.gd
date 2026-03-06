extends NavigationRegion2D

var timer := 0.0;
var bake_timeout := 1.0;

func _ready() -> void:
	AsteroidManager.set_spawn_parent_node(self);

func _physics_process(delta: float) -> void:
	timer += delta;
	if (timer >= bake_timeout && !is_baking()):
		timer = 0.0;
		bake_navigation_polygon(true);
