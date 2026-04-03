extends RayCast3D

var current_collider
var counter: int = 0

func _ready():
	pass

func _process(delta):
	var collider = get_collider()

	if is_colliding() and collider is Interactable:
		counter += 1
		if Input.is_action_just_pressed("interact"):
			collider.interact()
