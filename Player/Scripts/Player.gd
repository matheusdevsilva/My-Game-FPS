extends CharacterBody3D
class_name Player

@export var speed:float= 6.0
@export var run_speed:float = 8.5
@export var accel:float = 12.0

@export var mouse_sens:float = 0.002
@export var jump_force:float = 4.5
@export var jump_hold_time:float = 0.2
@export var jump_cut_multiplier:float = 0.5
@export var jump_sprint_multiplier:float = 1.1
@export var air_control := 0.

@export var stand_height:float = 1.8
@export var crouch_height:float = 0.9
@export var stand_camera_y:float = 0.0
@export var crouch_camera_y:float = -0.6

@export var jump_kick_strength:float = 0.15
@export var land_kick_strength:float = 0.25
@export var cam_return_speed := 8.

@export var stamina_max:float = 100.0
@export var stamina_recovery:float = 10.0
@export var stamina_drain:float = 10.0
@export var stamina_recover_limit:float = 50.0

@export var base_fov:float = 75.0
@export var run_fov:float = 95.0
@export var fov_speed:float = 8.0

@export var tilt_amount:float = 0.08
@export var tilt_speed:int= 6
@export var steam_id:int
@export var username_steam:String = ""
@export var avatar_steam:Texture2D


var jump_time:float= 0.0
var stamina:float = 100.0
var current_speed:float = 0.0

var exhausted:bool = false
var is_running:bool = false
var is_crouching:bool = false
var is_jumping: = false
var can_move:bool = true
var can_open_menu:bool = true
var look_back:bool = false

var cam_impact :float= 0.0
var was_on_floor :bool = true
var bob_time :float= 0.0
var gravity:Variant = ProjectSettings.get_setting("physics/3d/default_gravity")

var player_inventory:PlayerInventory
var player_hud:PlayerHUD
var current_menu: Control = null

@onready var pivot:Node3D = $CameraPivot
@onready var collision:CollisionShape3D = $CollisionShape3D
@onready var camera:Camera3D = $CameraPivot/Camera3D
@onready var ray:RayCast3D = $CameraPivot/Camera3D/RayCast3D
@onready var flashlight:SpotLight3D = $CameraPivot/SpotLight3D
@onready var label_username:Label3D  = $Username
@onready var hand:Node3D = $CameraPivot/Hand
@onready var audio_listener:AudioListener3D = $CameraPivot/Camera3D/AudioListener3D
@onready var audio_stream_player:AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
	stamina = stamina_max
	label_username.text = username_steam
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens)
		pivot.rotation.x -= event.relative.y * mouse_sens
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if  Input.is_action_just_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
	
func update_stamina(delta: float, direction: Vector3) -> void:
	if stamina <= 0:
		exhausted = true
	if exhausted and stamina >= stamina_recover_limit:
		exhausted = false
	
	is_running = Input.is_action_pressed("run") and direction != Vector3.ZERO and !exhausted and !is_crouching
	if is_running:
		stamina -= stamina_drain * delta
	else:
		if direction == Vector3.ZERO:
			stamina += stamina_recovery * 1.5 * delta
		else:
			stamina += stamina_recovery * delta
	stamina = clamp(stamina, 0.0, stamina_max)
	
func handle_movement(delta: float, direction: Vector3) -> void:
	
	var target_speed = run_speed if is_running else speed
	if is_crouching:
		target_speed = speed * 0.4
	else:
		target_speed = run_speed if is_running else speed
	current_speed = lerp(current_speed, target_speed, 5.0 * delta)
	
	var target_velocity = direction * current_speed
	if is_on_floor():
		velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)
	else:
		air_control = 0.6
		velocity.x = lerp(velocity.x, target_velocity.x, accel * air_control * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, accel * air_control * delta)

	move_and_slide()

func handle_jump(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("jump") and !is_crouching:
		var final_jump_force = jump_force
		if is_running:
			final_jump_force *= jump_sprint_multiplier
		velocity.y = final_jump_force

		is_jumping = true
		jump_time = jump_hold_time


	if is_jumping and Input.is_action_pressed("jump") and jump_time > 0:
		velocity.y += jump_force * 1.5 * delta
		jump_time -= delta
	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y *= 0.5
		is_jumping = false
	if is_on_floor():
		is_jumping = false
	
func handle_camera(delta: float, direction: Vector3) -> void:
	if direction != Vector3.ZERO and is_on_floor():
		var bob_speed = 10.0 if is_running else 6.0
		var bob_amount = 0.1 if is_running else 0.05
		bob_time += delta * bob_speed
		camera.position.x = cos(bob_time) * bob_amount * 0.5
		camera.position.y = sin(bob_time * 2.0) * bob_amount
	else:
		camera.position.x = lerp(camera.position.x, 0.0, 8.0 * delta)
		camera.position.y = lerp(camera.position.y, 0.0, 8.0 * delta)
		
	var target_fov = run_fov if is_running else base_fov
	camera.fov = lerp(camera.fov, target_fov, fov_speed * delta)

	var input_dir := Input.get_vector("walk_left","walk_right","walk_up","walk_down")
	var tilt_target = -input_dir.x * tilt_amount
	pivot.rotation.z = lerp(
		pivot.rotation.z,
		tilt_target,
		tilt_speed * delta
	)
	if Input.is_action_pressed("look_to_back"):
		pivot.rotation.y = PI
		look_back = true
	else:
		pivot.rotation.y = 0.0
		look_back = false
	
func _physics_process(delta):
	if !can_move:
		velocity = Vector3.ZERO
		return
	var input_dir := Input.get_vector(
		"walk_left",
		"walk_right",
		"walk_up",
		"walk_down"
	)
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	update_stamina(delta, direction)
	handle_jump(delta)
	handle_ground(delta)
	handle_movement(delta, direction)
	handle_camera(delta, direction)
	handle_raycast()
	

func handle_raycast():
	if !ray.is_colliding():
		return
	var node = ray.get_collider()
	while node:
		if node.has_method("interact"):
			if Input.is_action_just_pressed("interact"):
				node.interact()
			return
		node = node.get_parent()
				
func handle_ground(delta):
	is_crouching = Input.is_action_pressed("crouch")
	var shape = collision.shape as CapsuleShape3D
	if is_crouching:
		camera.position.y = lerp(
			camera.position.y,
			crouch_camera_y,
			10.0 * delta
		)
		shape.height = lerp(
			shape.height,
			crouch_height,
			10.0 * delta
		)
	else:
		camera.position.y = lerp(
			camera.position.y,
			stand_camera_y,
			10.0 * delta
		)
		shape.height = lerp(
			shape.height,
			stand_height,
			10.0 * delta
		)

	
	
