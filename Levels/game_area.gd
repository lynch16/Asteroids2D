class_name  GameArea
extends NavigationRegion2D

var timer := 0.0;
var bake_timeout := 1.0;

var viewport_buffer := 400.0;

@onready var enemy_pool: Node2D = $EnemyPool;
@onready var asteroid_pool: Node2D = $AsteroidPool;

func _ready() -> void:
	if navigation_polygon == null:
		var screen_size := get_viewport_rect().size;
		navigation_polygon = NavigationPolygon.new()
		var vertices := PackedVector2Array([
			Vector2(screen_size.x + viewport_buffer, screen_size.y + viewport_buffer), 
			Vector2(-viewport_buffer, screen_size.y + viewport_buffer), 
			Vector2(-viewport_buffer, -viewport_buffer),
			Vector2(screen_size.x + viewport_buffer, -viewport_buffer)
		])
		navigation_polygon.add_outline(vertices);

	AsteroidManager.set_spawn_parent_node(asteroid_pool);
	EnemyManager.set_spawn_parent_node(enemy_pool);

func _physics_process(delta: float) -> void:
	timer += delta;
	if (timer >= bake_timeout && !is_baking()):
		timer = 0.0;
		bake_navigation_polygon(true);

# Set navigable area to screen size
func _on_screen_resized() -> void:
	var screen_size := get_viewport_rect().size;
	var _verticies := PackedVector2Array();
	_verticies.append(Vector2(0, 0));
	_verticies.append(Vector2(screen_size.x, 0));
	_verticies.append(Vector2(screen_size.x, screen_size.y));
	_verticies.append(Vector2(0, screen_size.y));
	navigation_polygon.vertices = _verticies;
