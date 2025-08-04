extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera_3d: Camera3D = $Head/Eyes/Camera3D
@onready var interaction_controller: Node = $"Interaction controller"


#FLASH LIGHT VARS
@onready var flashlight: SpotLight3D = $Head/Eyes/Camera3D/FlashLight
var flashlight_on: bool = false

@onready var standing: CollisionShape3D = $Standing
@onready var crouching: CollisionShape3D = $Crouching

@onready var stand_up_check: RayCast3D = $StandUpCheck

var lerp_speed = 10.0
#MovementVars

const walking_speed : float = 3.0
const sprinting_speed : float = 5.0
const crouching_speed : float = 1.0
var current_speed : float = 3.0

var moving : bool = false
var input_dir : Vector2 = Vector2.ZERO
var direction : Vector3 = Vector3.ZERO

#Camera position when crouching
const crouching_depth : float = -0.9 

#Player_Settings
var base_fov : float = 75.0
var mouse_sense :float = 0.2

const jump_velocity : = 4.0

#State Machine
enum PlayerState {
	IDLE_STAND,
	IDLE_CROUCH,
	CROUCHING,
	WALKING,
	SPRINTING,
	AIR
}

var player_state :PlayerState = PlayerState.IDLE_STAND


#Bobbing viewmodel Vars
const head_bobbing_sprint_speed : float = 22.0
const head_bobbing_walking_speed : float = 14.0
const head_bobbing_crouching_speed : float = 10.0
const head_bobbing_sprint_intense : float = 0.2
const head_bobbing_walking_intense : float = 0.1
const head_bobbing_crouching_intense : float = 0.05
var head_bobing_current_intense : float = 0.0
var head_bobbing_vector:Vector2 = Vector2.ZERO
var head_bobbing_index: float = 0.0

func _ready() :
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight.visible = flashlight_on
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit") :
		get_tree().quit()
		
	if event is InputEventMouseMotion :
		if not interaction_controller.isCameraLocked() :
			rotate_y(deg_to_rad(-event.relative.x) * mouse_sense )
			head.rotate_x(deg_to_rad(-event.relative.y) * mouse_sense)
			head.rotation.x = clamp(head.rotation.x , deg_to_rad(-85) , deg_to_rad(85))
	# Toggle flashlight on/off
	if event.is_action_pressed("flashlight"):
		flashlight_on = !flashlight_on
		flashlight.visible = flashlight_on
func _physics_process(delta: float) -> void:

	update_player_stat()
	update_camera(delta)
	
	#Falling State
	if not is_on_floor() :
		if velocity.y >= 0: #Jumping upwards
			velocity += get_gravity() * delta
		else : #Falling Down
			velocity += get_gravity() * delta * 2.0
	#Jumping State
	else:
		if Input.is_action_just_pressed("jump") and not stand_up_check.is_colliding():
			velocity.y = jump_velocity
	
	#Movement Logic
	input_dir = Input.get_vector("left","right","forward","backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x , 0 ,input_dir.y)).normalized() , delta * lerp_speed )
	
	if direction :
		velocity.x  = direction.x * current_speed
		velocity.z  = direction.z * current_speed
	else : 
		velocity.x = move_toward(velocity.x , 0 , current_speed )
		velocity.z = move_toward(velocity.z , 0 , current_speed )
	move_and_slide()
func update_player_stat() -> void:
	moving = input_dir != Vector2.ZERO

	var wants_to_crouch = Input.is_action_pressed("crouch")
	var can_stand_up = not stand_up_check.is_colliding()
	# --- Handle crouching logic (works in air and ground) ---
	if wants_to_crouch:
		if moving:
			player_state = PlayerState.CROUCHING
		else:
			player_state = PlayerState.IDLE_CROUCH
	elif can_stand_up:
		if is_on_floor():
			if not moving:
				player_state = PlayerState.IDLE_STAND
			elif Input.is_action_pressed("sprint"):
				player_state = PlayerState.SPRINTING
			else:
				player_state = PlayerState.WALKING
		else:
			player_state = PlayerState.AIR
	else:
		if moving:
			player_state = PlayerState.CROUCHING
		else:
			player_state = PlayerState.IDLE_CROUCH

	# --- Override with AIR if not grounded ---
	if not is_on_floor() and player_state != PlayerState.AIR:
		if wants_to_crouch or not can_stand_up:
			player_state = PlayerState.IDLE_CROUCH
		else:
			player_state = PlayerState.AIR

	updatePlayerColShape(player_state)
	updatePlayerSpeed(player_state)



func updatePlayerColShape(_player_state : PlayerState )-> void :
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH :
		standing.disabled = true
		crouching.disabled = false
	else :
		standing.disabled = false
		crouching.disabled = true
func updatePlayerSpeed(_player_state : PlayerState )-> void :
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH :
		current_speed = crouching_speed
	elif _player_state == PlayerState.WALKING :
		current_speed = walking_speed
	elif _player_state == PlayerState.SPRINTING :
		current_speed = sprinting_speed

func update_camera(delta : float) -> void :
	if player_state == PlayerState.AIR :
		pass
	else :
		if player_state == PlayerState.CROUCHING or player_state == PlayerState.IDLE_CROUCH :
			#DECREASING THE FOV BY 5%
			head.position.y = lerp(head.position.y , 1.8 + crouching_depth , delta * lerp_speed)
			camera_3d.fov = lerp(camera_3d.fov , base_fov * 0.95 , delta * lerp_speed)
			head_bobing_current_intense = head_bobbing_crouching_intense
			head_bobbing_index += head_bobbing_crouching_speed * delta
		elif player_state == PlayerState.IDLE_STAND :
			head.position.y = lerp(head.position.y , 1.8 , delta * lerp_speed)
			camera_3d.fov = lerp(camera_3d.fov , base_fov, delta * lerp_speed)
			head_bobing_current_intense = head_bobbing_walking_intense
			head_bobbing_index += head_bobbing_walking_speed * delta
		elif player_state == PlayerState.WALKING :
			head.position.y = lerp(head.position.y , 1.8, delta * lerp_speed)
			camera_3d.fov = lerp(camera_3d.fov , base_fov, delta * lerp_speed)
			head_bobing_current_intense = head_bobbing_walking_intense
			head_bobbing_index += head_bobbing_walking_speed * delta
		elif player_state == PlayerState.SPRINTING :
			#INCREASING THE FOV BY 5%
			head.position.y = lerp(head.position.y , 1.8, delta * lerp_speed)
			camera_3d.fov = lerp(camera_3d.fov , base_fov * 1.05 , delta * lerp_speed)
			head_bobing_current_intense = head_bobbing_sprint_intense
			head_bobbing_index += head_bobbing_sprint_speed * delta
			
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2.0) + 0.5
		if moving :
			eyes.position.y = lerp(eyes.position.y , head_bobbing_vector.y*(head_bobing_current_intense/2.0),delta * lerp_speed)
			eyes.position.x = lerp(eyes.position.x , head_bobbing_vector.x*(head_bobing_current_intense),delta * lerp_speed)
		else :
			eyes.position.y = lerp(eyes.position.y , 0.0,delta * lerp_speed)
			eyes.position.x = lerp(eyes.position.x , 0.0,delta * lerp_speed)
