extends Node
#this is defined on individual objects in the game 

enum Interaction_Type {
	DEFAULT,
	DOOR
}

@export var object_ref : Node3D
@export var interaction_type : Interaction_Type = Interaction_Type.DEFAULT
@export var pivot_point : Node3D
@export var maximum_rotation : float = 90.0

var can_interact :bool = true
var is_interacting :bool = false

var player_hand : Marker3D

var lock_camera : bool = false
var starting_rotation :float 
var is_front : bool


func _ready() -> void:
	match interaction_type :
		Interaction_Type.DOOR :
			starting_rotation = pivot_point.rotation.x
			maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)


#Run once , when the player FIRST clicks on an object
func preInteract(hand : Marker3D) ->void:
	is_interacting = true
	match interaction_type:
		Interaction_Type.DEFAULT:
			player_hand = hand
		Interaction_Type.DOOR :
			lock_camera = true
#Run every frame perform some logic on this object
func interact()->void:
	if not can_interact:
		return
	match interaction_type:
		Interaction_Type.DEFAULT:
			_default_interact()
 
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
