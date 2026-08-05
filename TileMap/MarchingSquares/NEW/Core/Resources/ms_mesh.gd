@tool 
class_name MS_Mesh extends Resource 

@export var texture: Texture2D;

var mesh: ArrayMesh;
var ms_bitmap: MS_Bitmap;
var ms_canvas: MS_Canvas;

var surface_array: Array = [];

func _init(
	p_ms_bitmap: MS_Bitmap = MS_Bitmap.new(),
	p_ms_canvas: MS_Canvas = MS_Canvas.new(),
	p_texture: Texture2D = GradientTexture1D.new()
) -> void:
	ms_bitmap = p_ms_bitmap;
	ms_canvas = p_ms_canvas;
	texture = p_texture;

	resource_local_to_scene = true;

func create_mesh() -> ArrayMesh:
	_calculate_surface_array();
	mesh = ArrayMesh.new();
	if (surface_array[Mesh.ARRAY_VERTEX] is PackedVector2Array):
		var array_vertex: PackedVector2Array = surface_array[Mesh.ARRAY_VERTEX];
		if (array_vertex.size() == 0):
			return mesh;

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array);

	return mesh;

func create_mesh_instance() -> MeshInstance2D:
	create_mesh();
	var mesh_instance := MeshInstance2D.new();
	mesh_instance.mesh = mesh;
	mesh_instance.texture = texture;
	mesh_instance.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;

	return mesh_instance;
	

func _calculate_surface_array() -> void:
	surface_array = [];
	surface_array.resize(Mesh.ARRAY_MAX);
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector2Array();
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array();
	surface_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array();
	surface_array[Mesh.ARRAY_NORMAL] = PackedVector3Array();

	ms_canvas.for_each_tile(_generate_tile_from_corners);

func _generate_tile_from_corners(
	center: Vector2, 
) -> void:
	_add_tile(
		center, 
		_get_tile_index_from_corners(center), 
	);

func _add_tile(
	center: Vector2, 
	tile_index: int,
) -> void:
	var verticies := MSMeshes.VERTEX_ARRAYS[tile_index].duplicate();
	var indicies := MSMeshes.INDEX_ARRAYS[tile_index].duplicate();
	var total_verticies: int = 0;
	if (surface_array[Mesh.ARRAY_VERTEX] is PackedVector2Array):
		var array_vertex: PackedVector2Array = surface_array[Mesh.ARRAY_VERTEX];
		total_verticies = array_vertex.size();
	
		for i: int in verticies.size():
			var vertex := verticies[i];
			verticies[i] = _calculate_weighted_vertex(center, vertex);
	
		array_vertex.append_array(verticies);
	
	if (surface_array[Mesh.ARRAY_TEX_UV] is PackedVector2Array):
		var texSize := texture.get_size();
		var uv_array: PackedVector2Array = surface_array[Mesh.ARRAY_TEX_UV];
		for i: int in verticies.size():
			uv_array.append(Vector2.ONE / (texSize/verticies[i]));

	if (surface_array[Mesh.ARRAY_NORMAL] is PackedVector3Array):
		var tile_normal_array := PackedVector3Array();
		
		var normal_array: PackedVector3Array = surface_array[Mesh.ARRAY_NORMAL];
		tile_normal_array.resize(verticies.size());
		tile_normal_array.fill(Vector3.FORWARD);
		normal_array.append_array(tile_normal_array)
	
	if (surface_array[Mesh.ARRAY_INDEX] is PackedInt32Array):
		var array_index: PackedInt32Array = surface_array[Mesh.ARRAY_INDEX];
	
		for i: int in indicies.size():
			indicies[i] += total_verticies;
		
		array_index.append_array(indicies);

func _get_tile_index_from_corners(
	center: Vector2, 
) -> int:
	var tile_index := 0;
	for i: int in MS_Canvas.CORNERS.size():
		var corner := center + MS_Canvas.CORNERS[i] * ms_canvas.tile_size/2;

		if (!ms_canvas.canvas_rect.has_point(corner)):
			continue;

		var tile_position := ms_canvas.get_tile_position(corner);

		if (
			tile_position.x < 0 || 
			tile_position.y < 0
		):
			continue;

		tile_index += int(ms_bitmap.get_bitmap_cellv(tile_position)) << i;
		
	return tile_index;

func _calculate_weighted_vertex(center: Vector2, normalized_vertex: Vector2) -> Vector2:
	var is_edge := absf(normalized_vertex.x) + absf(normalized_vertex.y) == 1.0;
	var direction := Vector2.UP if normalized_vertex.x != 0.0 else Vector2.RIGHT;
			
	var vertex := normalized_vertex * ms_canvas.tile_size/2.0 + center;
	if (is_edge):
		var corner_1 := vertex + direction * ms_canvas.tile_size/2.0;
		var corner_2 := vertex - direction * ms_canvas.tile_size/2.0;

		if (!ms_canvas.canvas_rect.has_point(corner_1) || !ms_canvas.canvas_rect.has_point(corner_2)):
			return vertex;

		var value_1: float = ms_bitmap.get_cellv(ms_canvas.get_tile_position(corner_1));
		var value_2: float = ms_bitmap.get_cellv(ms_canvas.get_tile_position(corner_2));
		var weight := (value_1 + value_2)/(value_1 - value_2) / 2.0 + 0.5;
		vertex = corner_1.lerp(corner_2, weight);
	
	return vertex;
