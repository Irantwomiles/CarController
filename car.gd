extends VehicleBody3D

const MAX_STEER = 0.85
const ENGINE_POWER = 50
const MAX_TORQUE = 100
const MAX_RPM = 750

const MAX_FRICTION_SLIP = 1.0
const MIN_FRICTION_SLIP = 0.55

var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	
	$DebugLabel.visible = false
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var camera = Camera3D.new()
		# Setting cull_mask layer 2 to false will stop rendering it for the car.
		# We're doing this to hide the SpawnPoint materials in the scene
		camera.set_cull_mask_value(2, false)
		camera.set_position($CameraPosition.get_position())
		camera.set_rotation($CameraPosition.get_rotation())
		$CameraPosition/CameraPivot.add_child(camera)
		$BreakLights.visible = false
		$DebugLabel.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
	
		var steering_input = Input.get_axis("ui_right", "ui_left")
		var acceleration_input = Input.get_axis("ui_down", "ui_up")
		
		var break_input = Input.get_action_strength("break")
		
		print(break_input)
		
		$BackLeft.set_brake(break_input * 0.0)
		$BackRight.set_brake(break_input * 0.0)
		
		if break_input > 0:
			$BreakLights.visible = true
			$BackLeft.set_friction_slip(move_toward($BackLeft.get_friction_slip(), MIN_FRICTION_SLIP, delta * 8.0))
			$BackRight.set_friction_slip(move_toward($BackRight.get_friction_slip(), MIN_FRICTION_SLIP, delta * 8.0))
		else:
			$BreakLights.visible = false
			$BackLeft.set_friction_slip(move_toward($BackLeft.get_friction_slip(), MAX_FRICTION_SLIP, delta * 8.0))
			$BackRight.set_friction_slip(move_toward($BackRight.get_friction_slip(), MAX_FRICTION_SLIP, delta * 8.0))
		
		steering = move_toward(steering, steering_input * MAX_STEER, delta * 5.0)
		
		var acceleration = acceleration_input * ENGINE_POWER
		var rpm = $BackLeft.get_rpm()
		
		$BackLeft.engine_force = acceleration * MAX_TORQUE * (1 - abs(rpm) / MAX_RPM)
		
		rpm = $BackRight.get_rpm()
		$BackRight.engine_force = acceleration * MAX_TORQUE * (1 - abs(rpm) / MAX_RPM)
		
		$CameraPosition/CameraPivot.global_position = $CameraPosition/CameraPivot.global_position.lerp(global_position, delta * 20.0)
		$CameraPosition/CameraPivot.transform = $CameraPosition/CameraPivot.transform.interpolate_with(transform, delta * 5.0)
		
		
		$DebugLabel.text = "E-Force:" + str(ceil($BackLeft.engine_force)) + "\nL_RPM:" + str(ceil($BackLeft.get_rpm())) + " R_RPM:" + str(ceil($BackRight.get_rpm())) + "\n Friction Right:" + str($BackRight.get_friction_slip()) + " Friction Left" + str($BackLeft.get_friction_slip())
