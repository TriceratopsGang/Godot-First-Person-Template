class_name PlayerCharacter
extends CharacterBody3D


@export_group("References")
@export var fps_camera: Camera3D = null

@export_group("Speed")
@export var walk_speed: float = 5.0
@export var acceleration: float = 0.2
@export var deceleration: float = 0.4

@export_group("Gravity")
@export var jump_velocity: float = 5.0
@export var gravity_scalar: float = 1.0

@export_group("Camera")
@export var sensitivity_scalar: float = 0.01
@export var yaw_sensitivity: float = 0.25
@export var pitch_sensitivity: float = 0.25
const PITCH_CLAMP: float = deg_to_rad(89.0)
@export var base_fov: float = 60.0
@export var zoom_scalar: float = 2.0
@export var zoom_duration: float = 0.3

var input_dir: Vector2 = Vector2.ZERO
var move_dir: Vector3 = Vector3.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_handle_jump()
	if event.is_action_pressed("zoom"):
		_handle_zoom(true)
	elif event.is_action_released("zoom"):
		_handle_zoom(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y((-event.relative.x * yaw_sensitivity) * sensitivity_scalar)
		fps_camera.rotate_x((-event.relative.y * pitch_sensitivity) * sensitivity_scalar)
		fps_camera.rotation.x = clampf(fps_camera.rotation.x, -PITCH_CLAMP, PITCH_CLAMP)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	_apply_velocity()

func _apply_velocity() -> void:
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += (get_gravity() * gravity_scalar) * delta

func _handle_movement() -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if move_dir:
			velocity.x = lerpf(velocity.x, move_dir.x * _get_speed(), acceleration)
			velocity.z = lerpf(velocity.z, move_dir.z * _get_speed(), acceleration)
		else:
			velocity.x = lerpf(velocity.x, 0.0, deceleration)
			velocity.z = lerpf(velocity.z, 0.0, deceleration)

func _get_speed() -> float:
	return walk_speed

func _handle_jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity

func _handle_zoom(is_enter: bool) -> void:
	var tween: Tween = create_tween()
	var target_fov: float = base_fov / zoom_scalar if is_enter else base_fov
	tween.tween_property(fps_camera, "fov", target_fov, zoom_duration)
