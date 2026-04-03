extends CharacterBody3D

@export var speed: float = 10.0
@export var run_speed: float = 18.0
@export var crouch_speed: float = 4.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var inventory: Control = $Inventory/CanvasLayer/InventoryUI

var camera_x_rotation: float = 0.0
var is_crouching: bool = false

var normal_head_y: float = 0.0
var crouch_head_y: float = -0.5  # sesuaikan seberapa rendah kameranya

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	normal_head_y = head.position.y

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_just_pressed("inventory"):
		inventory.visible = !inventory.visible
		if inventory.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			raycast.enabled = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			raycast.enabled = true

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

func _physics_process(delta):
	# Crouch
	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
	if Input.is_action_just_released("crouch"):
		is_crouching = false

	# Smooth camera crouch
	var target_head_y = crouch_head_y if is_crouching else normal_head_y
	head.position.y = lerp(head.position.y, target_head_y, 10.0 * delta)

	# Speed
	var current_speed: float
	if is_crouching:
		current_speed = crouch_speed
	elif Input.is_action_pressed("run"):
		current_speed = run_speed
	else:
		current_speed = speed

	var movement_vector = Vector3.ZERO
	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x
	movement_vector = movement_vector.normalized()

	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power

	move_and_slide()
