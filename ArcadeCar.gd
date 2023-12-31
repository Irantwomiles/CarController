extends Node3D

@onready var ball = $Ball
@onready var car_mesh = $suv
@onready var ground_ray = $suv/GroundRay
@onready var break_lights = $suv/BreakLights
@onready var right_wheel = $suv/body/wheel_frontRight
@onready var left_wheel = $suv/body/wheel_frontLeft
@onready var body_mesh = $suv/body/body
@onready var camera = $camera
@onready var multiplayer_synchronizer = $Ball/MultiplayerSynchronizer
@onready var audio_stream = $suv/AudioStreamPlayer3D

var sphere_offset = Vector3(0, 0, 0)
var acceleration = 100
var steering = 15.0
var turn_speed = 4
var turn_stop_limit = 0.65

var MAX_LINEAR_VELOCITY = 35.0
var speed_input = 0
var rotate_input = 0

var body_tilt = 35

func _ready():
	ground_ray.add_exception(ball)
	
	multiplayer_synchronizer.set_multiplayer_authority(str(name).to_int())
	ball.name = str(name)
	
	$DebugLabel.visible = false
	
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		# Setting cull_mask layer 2 to false will stop rendering it for the car.
		# We're doing this to hide the SpawnPoint materials in the scene
		camera.set_cull_mask_value(2, false)
		camera.set_current(true)
		break_lights.visible = false
		$DebugLabel.visible = true
	

func _physics_process(delta):
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		car_mesh.transform.origin = ball.transform.origin + sphere_offset
		
		if ball.get_linear_velocity().length() > MAX_LINEAR_VELOCITY:
			ball.apply_central_force(-car_mesh.global_transform.basis.z * 1)
		else:
			ball.apply_central_force(-car_mesh.global_transform.basis.z * speed_input)

func _process(delta):
	# Can't steer/accelerate when in the air
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
	
		if not ground_ray.is_colliding():
			return
		# Get accelerate/brake input
		
		var updated_speed = 0
		
		updated_speed += Input.get_action_strength("accelerate")
		updated_speed -= Input.get_action_strength("brake")
		updated_speed *= acceleration
		
		speed_input = lerpf(speed_input, updated_speed, delta * 1.5)
		
#		speed_input += Input.get_action_strength("accelerate")
#		speed_input -= Input.get_action_strength("brake")
#		speed_input *= acceleration
		# Get steering input
		rotate_input = 0
		
		break_lights.visible = false
		
		if speed_input >= 0:
			rotate_input += Input.get_action_strength("steer_left")
			rotate_input -= Input.get_action_strength("steer_right")
		else:
			rotate_input -= Input.get_action_strength("steer_left")
			rotate_input += Input.get_action_strength("steer_right")
			break_lights.visible = true
		
	
		rotate_input *= deg_to_rad(steering)
		

		# rotate wheels for effect
		right_wheel.rotation.y = rotate_input
		left_wheel.rotation.y = rotate_input
		
		# rotate car mesh
		if ball.linear_velocity.length() > turn_stop_limit:
			var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y,
					rotate_input)
			car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis,
					turn_speed * delta)
			car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
			
			# tilt body for effect
			var t = -rotate_input * ball.linear_velocity.length() / body_tilt
			body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 10 * delta)
		
		# align with ground
		var n = ground_ray.get_collision_normal()
		var xform = align_with_y(car_mesh.global_transform, n.normalized())
		car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)
		


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


