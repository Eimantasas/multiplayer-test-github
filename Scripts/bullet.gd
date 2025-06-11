extends RayCast3D

var speed : float = 90.0
var damage: int = 20

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.start()

func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	
	var collider = get_collider()
	if is_colliding():
		global_position = get_collision_point()
		
		if collider.has_method("was_shot"):
			collider.was_shot()


func _on_timer_timeout() -> void:
	queue_free()
