class_name  GameArea
extends NavigationRegion2D

var timer := 0.0;
var bake_timeout := 1.0;

func _enter_tree() -> void:
	navigation_polygon = NavigationPolygon.new();
	navigation_polygon.agent_radius = MarchingSquaresUtility.TILE_SIZE * 2.0;

func _ready() -> void:
	_on_screen_resized();
	AsteroidManager.set_spawn_parent_node(self);

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

