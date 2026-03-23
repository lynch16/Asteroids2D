class_name AsteroidMesh
extends Resource

@export var texture: Texture2D;
@export var corner_sampling: Dictionary[Vector2, float];
@export var collider_shapes: Array[Shape2D];
@export var mesh: ArrayMesh;

var mesh_instance: MeshInstance2D;
var collider: CollisionShape2D;

func _init(
	p_mesh: ArrayMesh = ArrayMesh.new(), 
	p_texture: Texture2D = Texture2D.new(), 
	p_corner_sampling: Dictionary[Vector2, float] = {},
	p_collider_shapes: Array[Shape2D] = []
) -> void:
	mesh = p_mesh;
	texture = p_texture;
	corner_sampling = p_corner_sampling;
	collider_shapes = p_collider_shapes;

func apply(asteroid: Asteroid, to_global: Callable) -> void:
	mesh_instance = asteroid.get_mesh_instance()
	mesh_instance.mesh = mesh;
	mesh_instance.texture = texture;
	mesh_instance.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;
	
	asteroid.init_colliders(collider_shapes);
	
	#collider = asteroid.get_collider();
	#collider.shape = collider_shape;
	#
	#var mesh_offset: Vector2 = asteroid.global_position - to_global.call(collider_shape.get_rect().get_center());
	#mesh_instance.position = mesh_offset;
	#collider.position = mesh_offset;

func update(asteroid: Asteroid, new_corner_samples: Dictionary[Vector2, float], viewport_rect: Rect2) -> void:
	corner_sampling = new_corner_samples
	TileMapProcGen._upsert_new_mesh_instance(viewport_rect, corner_sampling, texture, asteroid.get_mesh_instance())
	
	collider_shapes = TileMapProcGen._generate_collision_shapes(
		viewport_rect,
		corner_sampling
	)
	asteroid.init_colliders(collider_shapes);
	mesh = asteroid.get_mesh_instance().mesh;
	
