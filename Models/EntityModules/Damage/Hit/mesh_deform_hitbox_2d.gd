class_name MeshDeformHitbox2D
extends Hitbox2D

var last_position: Vector2;
var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

func _init(
	p_attacker_combat_stats: CombatStats,
	p_lifetime: float,
	p_shape: Shape2D = null,
    p_mesh_deformation_shapes: Array[MeshDeformationShape] = [],
) -> void:
    super(p_attacker_combat_stats, p_lifetime, p_shape);
    mesh_deformation_shapes = p_mesh_deformation_shapes;

func _ready() -> void:
    super();
    area_shape_entered.connect(_on_body_shape_entered);

func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
    print("HITBOX SHAPE ENTERED");
    if (body is Area2D):
        var collision_body: Area2D = body;
        var body_shape_owner := collision_body.shape_find_owner(body_shape_index);
        var body_collider := collision_body.shape_owner_get_owner(body_shape_owner);

        var local_shape_owner := shape_find_owner(local_shape_index);
        var local_collider := shape_owner_get_owner(local_shape_owner);

        if (body_collider is DeformableMeshCollider2D):
            var mesh_collider: DeformableMeshCollider2D = body_collider;
            var local_mesh_collider: CollisionShape2D = local_collider;
            var collision_points := local_mesh_collider.shape.collide_and_get_contacts(
                local_mesh_collider.global_transform,
                mesh_collider.shape,
                mesh_collider.global_transform
            );

            if (collision_points.size() > 0):
                var impact_point: Vector2 = collision_points.get(0);
                var impact_angle := last_position.angle_to(impact_point);

                mesh_collider.apply_group_deformation(
                    mesh_collider.to_local(impact_point),
                    impact_angle,
                    mesh_deformation_shapes,
                );
