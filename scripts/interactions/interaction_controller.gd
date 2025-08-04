extends Node

@onready var interaction_controller: Node = $"Interaction controller"
@onready var interaction_raycast: RayCast3D = %interaction_raycast
@onready var camera_3d: Camera3D = %Camera3D
@onready var hand: Marker3D = %Hand


var current_object : Object
var last_potential_object : Object
var interaction_component : Node

func _process(delta: float) -> void:
	#if on previous frame we were interacting with an object , lets keep interacting  
	if current_object :
		if Input.is_action_just_pressed("secondary") :
			if interaction_component :
				interaction_component.auxInteract()
				current_object = null
		elif Input.is_action_pressed("primary") :
			if interaction_component :
				interaction_component.interact()
		else :
			if interaction_component :
				interaction_component.postInteract()
				current_object = null
	else :#we weren't interacting with something lets see if we can 
		var potential_object : Object = interaction_raycast.get_collider()
		
		if potential_object and potential_object is Node :
			interaction_component = potential_object.get_node_or_null("InteractionComponent")
			if interaction_component:
				if interaction_component.can_interact == false:
					return
				last_potential_object = current_object
				if Input.is_action_just_pressed("primary") :
					current_object = potential_object
					interaction_component.preInteract(hand)
					
					
					if interaction_component.interaction_type == interaction_component.Interaction_Type.DOOR :
						interaction_component.set_direction(current_object.to_local(interaction_raycast.get_collision_point()))
func isCameraLocked() -> bool :
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting :
			return true	
	return false
