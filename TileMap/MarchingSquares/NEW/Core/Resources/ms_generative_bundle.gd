@tool 
class_name MS_GenerativeBundle extends Resource

@export var ms_canvas: MS_Canvas;
@export var ms_bitmap: MS_Bitmap;
@export var texture: Texture2D;

func _init(
	p_canvas: MS_Canvas = MS_Canvas.new(),
	p_ms_bitmap: MS_Bitmap = MS_Bitmap.new(),
	p_texture: Texture2D = GradientTexture1D.new()
) -> void:
	ms_canvas = p_canvas;
	ms_bitmap = p_ms_bitmap;
	texture = p_texture;

	resource_local_to_scene = true;

func save(save_path: String) -> void:
	ResourceSaver.save(self, save_path);