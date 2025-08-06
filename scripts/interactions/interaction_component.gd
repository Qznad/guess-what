extends Node
#this is defined on individual objects in the game 

enum Interaction_Type {
	DEFAULT,
	DOOR,
	SWITCH,
	WHEEL,
	ITEM,
	PLAYER
}

@export var object_ref : Node3D
@export var interaction_type : Interaction_Type = Interaction_Type.DEFAULT
@export var pivot_point : Node3D
@export var maximum_rotation : float = 90.0
@export var nodes_to_affect : Array[Node]

var can_interact :bool = true
var is_interacting :bool = false
var player_hand : Marker3D
var lock_camera : bool = false
var starting_rotation :float 
var is_front : bool
var camera : Camera3D
var previous_mouse_pos : Vector2
var wheel_rotation : float = 0.0

# Signals
signal item_collected(item:Node)

func _ready() -> void:
	match interaction_type :
		Interaction_Type.DOOR :
			starting_rotation = pivot_point.rotation.x
			maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)
		Interaction_Type.SWITCH :
			starting_rotation = object_ref.rotation.z
			maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation) 
		Interaction_Type.WHEEL :
			starting_rotation = object_ref.rotation.x
			maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)
			camera = get_tree().get_current_scene().find_child("Camera3D",true,false)
#Run once , when the player FIRST clicks on an object
func preInteract(hand : Marker3D) ->void:
	is_interacting = true
	match interaction_type:
		Interaction_Type.DEFAULT:
			player_hand = hand
		Interaction_Type.DOOR :
			lock_camera = true
		Interaction_Type.SWITCH :
			lock_camera = true
		Interaction_Type.WHEEL :
			lock_camera = true
			previous_mouse_pos = get_viewport().get_mouse_position()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
#Run every frame perform some logic on this object
func interact()->void:
	if not can_interact:
		return
	match interaction_type:
		Interaction_Type.DEFAULT:
			_default_interact()
		Interaction_Type.ITEM :
			_collect_item()
 
func auxInteract() -> void :
	if not can_interact:
		return
	match interaction_type:
		Interaction_Type.DEFAULT:
			_default_throw()
#Runs once , when the player LAST interacts with an object
func postInteract()->void:
	is_interacting = false
	lock_camera = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if is_interacting:
		match interaction_type :
			Interaction_Type.DOOR :
				if event is InputEventMouseMotion :
					if is_front :
						pivot_point.rotate_y(-event.relative.y * .001)
					else :
						pivot_point.rotate_y(event.relative.y * .001)
					pivot_point.rotation.y = clamp(pivot_point.rotation.y , starting_rotation - maximum_rotation , maximum_rotation)
			Interaction_Type.SWITCH :
				if event is InputEventMouseMotion :
					var percentage : float
					object_ref.rotate_z(event.relative.y * .001)
					object_ref.rotation.z = clamp(object_ref.rotation.z , starting_rotation , maximum_rotation)
					percentage = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
					
					notify_nodes(percentage)
			Interaction_Type.WHEEL:
				if event is InputEventMouseMotion:
					var mouse_position : Vector2 = event.position
					var cross = calculate_cross_product(mouse_position)

					if cross < 0:
						wheel_rotation += 0.2
					else:
						wheel_rotation -= 0.2

					object_ref.rotation.x = clamp(wheel_rotation * 0.1, starting_rotation, maximum_rotation)

					var percentage = (object_ref.rotation.x - starting_rotation) / (maximum_rotation - starting_rotation)
					notify_nodes(percentage)

					#  Update the previous mouse position
					previous_mouse_pos = mouse_position
					
					var min_wheel_rotation: float = starting_rotation / 0.1
					var max_wheel_rotation: float = maximum_rotation / 0.1
					
					wheel_rotation = clamp(wheel_rotation, min_wheel_rotation, max_wheel_rotation)
func _default_interact() -> void :
	var object_current_position : Vector3 = object_ref.global_transform.origin
	var player_hand_position : Vector3 = player_hand.global_transform.origin
	var object_distance : Vector3 = player_hand_position - object_current_position
	
	
	var rigid_body3d : RigidBody3D = object_ref as RigidBody3D
	if rigid_body3d :
		rigid_body3d.set_linear_velocity((object_distance)*(5/rigid_body3d.mass))

func _default_throw() ->void :
	var object_current_position : Vector3 = object_ref.global_transform.origin
	var player_hand_position : Vector3 = player_hand.global_transform.origin
	var object_distance : Vector3 = player_hand_position - object_current_position
	
	
	var rigid_body3d : RigidBody3D = object_ref as RigidBody3D
	if rigid_body3d :
		var throw_direction :Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_force :float = 20.0/rigid_body3d.mass
		rigid_body3d.set_linear_velocity(throw_direction*throw_force)

func set_direction(_normal : Vector3) -> void :
	if _normal.z > 0 :
		is_front = true
	else :
		is_front = false


func notify_nodes(percentage : float ) -> void :
	for node in nodes_to_affect :
		if node and node.has_method("execute") :
			node.call("execute" , percentage)


func calculate_cross_product(_mouse_position: Vector2) -> float:
	var center_position = camera.unproject_position(object_ref.global_transform.origin)
	var vector_to_previous = previous_mouse_pos - center_position
	var vector_to_current = _mouse_position - center_position
	var cross_product = vector_to_previous.x * vector_to_current.y - vector_to_previous.y * vector_to_current.x
	
	return cross_product
	


func _collect_item()-> void:
	emit_signal("item_collected" , get_parent() )
	get_parent().queue_free()
