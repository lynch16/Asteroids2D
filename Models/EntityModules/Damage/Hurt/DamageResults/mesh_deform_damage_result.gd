class_name MeshDeformDamageResult
extends DamageResult

func on_damage(
	_damage_dealt: float, 
	damager_node: Node, 
	hit_position: Vector2,
	hit_angle: float
) -> bool: 
	if (damageable.owner_node is Asteroid):
		var asteroid: Asteroid = damageable.owner_node;
		var deformation_shapes: Array[MeshDeformationShape] = [];
		if (damager_node.get("mesh_deformation_shapes") == null):
			printerr("Damager node " + damager_node.name + " does not have a 'mesh_deformation_shapes' property, defaulting to empty array for mesh deformation shapes");
		else:
			deformation_shapes = damager_node.get("mesh_deformation_shapes");
		asteroid.deform_mesh(hit_position, hit_angle, deformation_shapes);

	return true;
