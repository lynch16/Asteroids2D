@tool
class_name VisionArea
extends Area2D

@export var detection_group_name: String;
@export var field_of_view := PI/4;
@export var view_distance := 200;
@export var target_acquisition_interval := 0.5; # Seconds to run the target update functionality

var targets: Array[Node2D] = [];

signal on_targets_updated(targets: Array[Node2D]);

@onready var collision_polygon: CollisionPolygon2D = get_node("CollisionPolygon2D");

func _ready() -> void:
	if (!detection_group_name):
		printerr("VisionArea missing detection_group_name; will NOT detect");
		
	collision_polygon.polygon = _get_cone_polygon_points();
	body_entered.connect(_on_body_visible);
	body_exited.connect(_on_body_exited);
		
func _process(_delta: float) -> void:
	queue_redraw();
	
func _can_see_targets() -> bool:
	return targets.size() > 0;
	
func _on_body_visible(node_2d: Node2D) -> void:
	if (targets.has(node_2d)):
		return;
		
	if (node_2d.is_in_group(detection_group_name)):
		var node_angle := get_angle_to(node_2d.global_position);
		var normalized_node_angle := _normalize_rotation(node_angle);
				
		if abs(normalized_node_angle) <= field_of_view:
			var blocking_intersection_point := _get_blocking_intersection_point(node_angle);
			if (blocking_intersection_point == Vector2.INF):
				targets.append(node_2d);
				on_targets_updated.emit(targets);

func _on_body_exited(node_2d: Node2D) -> void:
	targets.erase(node_2d);
	on_targets_updated.emit(targets);

func _draw() -> void:
	_draw_vision_cone();
	
func _normalize_rotation(base_rotation: float) -> float:
	return base_rotation + PI/2;

func _calc_max_view_point_from_angle(view_angle: float) -> Vector2:
	return Vector2(cos(view_angle), sin(view_angle)) * view_distance;
	
func _get_blocking_intersection_point(view_angle: float) -> Vector2:
	var global_angle := global_rotation + view_angle;
	var space_state := get_world_2d().direct_space_state;
	var point := _calc_max_view_point_from_angle(global_angle);
	var ray_query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + point,
		collision_mask,
		[get_parent()]
	);
	var collider_ray := space_state.intersect_ray(ray_query)
	var collider: Variant = collider_ray.get("collider");
	if (collider is Node):
		var collider_node: Node = collider;
		 # If the colliding node is not our target, return the position of what is blocking
		if (!collider_node.is_in_group(detection_group_name)):
			return collider_ray.get("position");
		
	return Vector2.INF;

func _draw_vision_cone() -> void:
	var cone_color := Color(1, 0, 0, 0.1) if _can_see_targets() else Color(0, 1, 0, 0.1)
	draw_polygon(_get_cone_polygon_points(), [cone_color])

func _get_cone_polygon_points() -> PackedVector2Array:
	var cone_points := 32;
	var cone_points_arc := PackedVector2Array();
	cone_points_arc.append(Vector2());
	var near_angle := _normalize_rotation(rotation) + field_of_view;
	
	for i in range(cone_points + 1):
		var angle := -near_angle + (2 * field_of_view * i / cone_points);
		var blocking_intersection_point := _get_blocking_intersection_point(angle);
		if (blocking_intersection_point == Vector2.INF):
			var point := _calc_max_view_point_from_angle(angle);
			cone_points_arc.append(point);
		else:
			cone_points_arc.append(to_local(blocking_intersection_point));
	
	return cone_points_arc;

func get_random_global_point_at_edge_of_vision(cone_points: int = 32) -> Vector2:
	var near_angle := _normalize_rotation(rotation) + field_of_view;
	var cone_point := randi() % cone_points;
	var angle := -near_angle + (2 * field_of_view * cone_point / cone_points);
	var point := _calc_max_view_point_from_angle(angle);
	return to_global(point);
