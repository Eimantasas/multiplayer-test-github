extends RayCast3D

var speed : float = 90.0
var damage: int = 20

func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	
	var collider = get_collider()
	if is_colliding():
		global_position = get_collision_point()
		
		if collider.has_method("take_damage"):
			collider.take_damage(damage)
