extends CharacterBody3D

enum State {
	Grounded
}

var state = State.Grounded

@export var mouse_sensitivity: float = 0.002

@export_category("grounded")
@export var max_horz_vel: float = 2
@export var grounded_acceleration: float = 1
@export var grounded_decelleration: float = 2

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var accel: Vector3 = Vector3.ZERO
	match state:
		State.Grounded:
			accel = grounded()
	
	velocity += accel*.5*delta
	move_and_slide()
	velocity += accel*.5*delta

func grounded() -> Vector3:
	var acceleration: Vector3 = Vector3.ZERO
	if velocity.length() < max_horz_vel:
		acceleration = Vector3(
			Input.get_action_strength("Right") - Input.get_action_strength("Left"),
			0,
			-Input.get_action_strength("Forwards") + Input.get_action_strength("Backwards"),
		).rotated(Vector3.UP, rotation.y) * grounded_acceleration
		
		if acceleration.x == 0:
			var decell = grounded_decelleration * velocity.normalized().x
			if abs(velocity.x) > abs(decell):
				acceleration.x = -velocity.x
			else:
				acceleration.x = -decell
		if acceleration.z == 0:
			var decell = grounded_decelleration * velocity.normalized().z
			if abs(velocity.z) > abs(decell):
				acceleration.z = -velocity.z
			else:
				acceleration.z = -decell
	else:
		if velocity.length() <= grounded_decelleration:
			acceleration = -1* velocity #framerate dependant. Might fix later.
		else:
			acceleration = grounded_decelleration * velocity.normalized()
	return acceleration

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
