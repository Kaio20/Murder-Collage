extends KinematicBody

###################-VARIABLES-####################

# Camera
export(float) var mouse_sensitivity = 12.0
export(NodePath) var head_path
export(NodePath) var cam_path

export(float) var FOV = 80.0
var mouse_axis := Vector2()
onready var head: Spatial = get_node(head_path)
onready var cam: Camera = get_node(cam_path)
#onready var ray = get_node("Head/Camera/RayCast")

# Move
var velocity := Vector3()
var direction := Vector3()
var move_axis := Vector2()
var sprint_enabled := true
var sprinting := false

# Walk
const FLOOR_MAX_ANGLE: float = deg2rad(46.0)
export(float) var gravity = 30.0
export(int) var walk_speed = 10
export(int) var sprint_speed = 16
export(int) var acceleration = 8
export(int) var deacceleration = 10
export(float, 0.0, 1.0, 0.05) var air_control = 0.3
export(int) var jump_height = 10

# Fly
export(int) var fly_speed = 10
export(int) var fly_accel = 4
var flying := false

#ray
export var raylength = 8000.0

##################################################

# Called when the node enters the scene tree
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.fov = FOV



# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	move_axis.x = 1 
	move_axis.y = 1 
	
	var mouse_position = get_viewport().get_mouse_position()
	var space_state = get_world().direct_space_state
	
	if (Input.is_action_pressed("leftclick")):
		var from = cam.project_ray_origin(mouse_position)
		var to = from + cam.project_ray_normal(mouse_position) * raylength
		print ("hello")
		var ray = space_state.intersect_ray(from,to)
		
		if not ray.empty():
			print(ray.get_collider())
		pass


# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
		walk(delta)


# Called when there is an input event
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_axis = event.relative
		camera_rotation()

# if event is InputEventMouseButton and event.pressed and event.button_index == 1:
#		var from = cam.project_ray_origin(event.position)
#		var to = from + cam.project_ray_normal(event.position) * raylength
#		print ("hello")
		
#		ray(to,true,true,1,true)
		
func walk(delta: float) -> void:
	# Input
	direction = Vector3()
	direction = get_global_transform().basis.z *-1
	direction.y = 0 
	direction = direction.normalized()
	
	var _snap: Vector3
	_snap = Vector3.DOWN

	
	# Apply Gravity
	velocity.y -= gravity * delta
	
	# Move Forward
	var _speed: int
	if (Input.is_action_pressed("move_rightclick")):
		_speed = walk_speed
		cam.set_fov(lerp(cam.fov, FOV * 1.03, delta * 8))
		sprinting = true
	else:
		_speed = 0
		cam.set_fov(lerp(cam.fov, FOV, delta * 8))
		sprinting = false
	
	# Acceleration and Deacceleration
	# where would the player go
	var _temp_vel: Vector3 = velocity
	_temp_vel.y = 0
	var _target: Vector3 = direction * _speed
	var _temp_accel: float
	if direction.dot(_temp_vel) > 0:
		_temp_accel = acceleration
	else:
		_temp_accel = deacceleration
	if not is_on_floor():
		_temp_accel *= air_control
	# interpolation
	_temp_vel = _temp_vel.linear_interpolate(_target, _temp_accel * delta)
	velocity.x = _temp_vel.x
	velocity.z = _temp_vel.z
	# clamping (to stop on slopes)
	if direction.dot(velocity) == 0:
		var _vel_clamp := 0.25
		if abs(velocity.x) < _vel_clamp:
			velocity.x = 0
		if abs(velocity.z) < _vel_clamp:
			velocity.z = 0
	
	# Move
	var moving = move_and_slide_with_snap(velocity, _snap, Vector3.UP, true, 4, FLOOR_MAX_ANGLE)
	if is_on_wall():
		velocity = moving
	else:
		velocity.y = moving.y


func fly(delta: float) -> void:
	# Input
	direction = Vector3()
	var aim = head.get_global_transform().basis
	direction = direction.normalized()
	
	# Acceleration and Deacceleration
	var target: Vector3 = direction * fly_speed
	velocity = velocity.linear_interpolate(target, fly_accel * delta)
	
	# Move
	velocity = move_and_slide(velocity)


func camera_rotation() -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if mouse_axis.length() > 0:
		var horizontal: float = -mouse_axis.x * (mouse_sensitivity / 100)
		var vertical: float = -mouse_axis.y * (mouse_sensitivity / 100)
		
		mouse_axis = Vector2()
		
		rotate_y(deg2rad(horizontal))
		head.rotate_x(deg2rad(vertical))
		
		# Clamp mouse rotation
		var temp_rot: Vector3 = head.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, -50, 40)
		head.rotation_degrees = temp_rot

func can_sprint() -> bool:
	return (sprint_enabled and is_on_floor())

#func raycast() -> void:
#	# Input
#	direction = Vector3()
#
#	# Move Forward
#	var _speed: int
#	if (Input.is_action_pressed("leftclick")):
#
#		print("Hi")
		
