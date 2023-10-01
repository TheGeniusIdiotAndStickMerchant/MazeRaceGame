extends CharacterBody3D

enum State {
	Grounded,
	Arial
}

var state = State.Grounded 
#	set(value):
#		print("setting state from %s to %s" % [State.find_key(state), State.find_key(value)])
#		state = value

@export var mouse_sensitivity: float = 0.002

@export var max_vel: float = 2

@export_category("grounded")
@export var grounded_acceleration: float = 1
@export var grounded_decelleration: float = 2

@export_category("jump")
@export var jump_vel: float = 5
@export var jump_boost: float = 2

@export_category("arial")
@export var arial_acceleration: float = 0.1
@export var arial_grav: float = 4
@export var term_vel: float = 5

@export_category("wall jump")
@export var wall_jump_vel: float = 5
@export var wall_jump_boost: float = 0.3
@export var wall_jump_boost_norm: float = 4

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var accel: Vector3 = Vector3.ZERO
	match state:
		State.Grounded:
			accel = grounded()
		State.Arial:
			accel = arial()
	
	accel.y -= arial_grav
	accel.y = max(-term_vel, accel.y)
	
	velocity += accel*.5*delta
	move_and_slide()
	velocity += accel*.5*delta
	
 
func grounded() -> Vector3:
	if Input.is_action_pressed("Jump"):
		jump()
		return arial()
	
	if !is_on_floor():
		state = State.Arial
		return arial()
	
	var acceleration: Vector3 = Vector3.ZERO
	
	if velocity.length() < max_vel:
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
			acceleration = -grounded_decelleration * velocity.normalized()
	acceleration.y -= arial_grav
	return acceleration

func arial() -> Vector3:
	var acceleration: Vector3 = Vector3.ZERO
	
	
	if !Input.is_action_pressed("Jump"):
		if is_on_floor():
			state = State.Grounded
			return grounded()
	elif is_on_wall():
		wall_jump()
	
	if abs(Vector2(velocity.x, velocity.y).length()) < max_vel:
		acceleration = Vector3(
			Input.get_action_strength("Right") - Input.get_action_strength("Left"),
			0,
			-Input.get_action_strength("Forwards") + Input.get_action_strength("Backwards")
		).rotated(Vector3.UP, rotation.y) * arial_acceleration
	else:
		var def_acc =Vector3(
			Input.get_action_strength("Right") - Input.get_action_strength("Left"),
			0,
			-Input.get_action_strength("Forwards") + Input.get_action_strength("Backwards"),
		).rotated(Vector3.UP, rotation.y) * arial_acceleration
		if abs(def_acc.length()) < abs(velocity.length()):
			acceleration = def_acc
	
	return acceleration


func wall_jump():
	var normal = get_last_slide_collision().get_normal()
	var acc_without_norm = Vector3(0, wall_jump_vel, wall_jump_boost).rotated(Vector3.UP, rotation.y)
	
	if normal.dot(acc_without_norm) > 0:
		acc_without_norm = acc_without_norm.reflect(normal)
		acc_without_norm.y *= -1
	
	var acc = acc_without_norm + normal*wall_jump_boost_norm
	velocity +=  acc

func jump():
	state = State.Arial
	velocity.y = jump_vel
	if Vector2(velocity.x, velocity.z).length() < max_vel:
		velocity += Vector3(
			Input.get_action_strength("Right") - Input.get_action_strength("Left"),
			0,
			-Input.get_action_strength("Forwards") + Input.get_action_strength("Backwards"),
		).rotated(Vector3.UP, rotation.y) * jump_boost

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
