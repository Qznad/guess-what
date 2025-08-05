extends Node

@onready var interaction_controller: Node = $"Interaction controller"
@onready var interaction_raycast: RayCast3D = %interaction_raycast
@onready var camera_3d: Camera3D = %Camera3D
@onready var hand: Marker3D = %Hand
@onready var default_reticle: TextureRect = %DefaultReticle
@onready var highlight_reticle: TextureRect = %HighlightReticle
@onready var interacting_reticle: TextureRect = %InteractingReticle
@onready var interactable_check: Area3D = $"../InteractableCheck"

@onready var outline_material : Material = preload("res://materials/outline.tres")




var current_object : Object
var last_potential_object : Object
var interaction_component : Node

func _ready() -> void:
	interactable_check.body_entered.connect(_on_body_entered)
	interactable_check.body_exited.connect(_on_body_exited)
	#MAKE SURE CROSSHAIR IS ALWAYS CENTERED 
	#default_reticle.position.x = get_viewport().size.x / 2
	#default_reticle.position.x = get_viewport().size.y / 2

func _process(delta: float) -> void:
	if interaction_component and interaction_component.is_interacting :
		default_reticle.visible = false
		highlight_reticle.visible = false
		interacting_reticle.visible = true
	#if on previous frame we were interacting with an object , lets keep interacting  
	if current_object :
		if Input.is_action_just_pressed("secondary") :
			if interaction_component :
				interaction_component.auxInteract()
				current_object = null
				_unfocus()
		elif Input.is_action_pressed("primary") :
			if interaction_component :
				interaction_component.interact()
		else :
			if interaction_component :
				interaction_component.postInteract()
				current_object = null
				_unfocus()
	else :#we weren't interacting with something lets see if we can 
		var potential_object : Object = interaction_raycast.get_collider()
		
		if potential_object and potential_object is Node :
			interaction_component = potential_object.get_node_or_null("InteractionComponent")
			if interaction_component:
				if interaction_component.can_interact == false:
					return
				last_potential_object = current_object
				_focus()
				if Input.is_action_just_pressed("primary") :
					current_object = potential_object
					if interaction_component.interaction_type == interaction_component.Interaction_Type.ITEM:
						if not interaction_component.is_connected("item_collected", Callable(self, "_on_item_collected")):
							interaction_component.connect("item_collected", Callable(self, "_on_item_collected"))
					interaction_component.preInteract(hand)

						
						
					if interaction_component.interaction_type == interaction_component.Interaction_Type.DOOR :
						interaction_component.set_direction(current_object.to_local(interaction_raycast.get_collision_point()))
		else :
			_unfocus()
func isCameraLocked() -> bool :
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting :
			return true	
	return false

func _focus()->void :
	default_reticle.visible = false
	highlight_reticle.visible = true
	interacting_reticle.visible = false


func _unfocus()->void :
	default_reticle.visible = true
	highlight_reticle.visible = false
	interacting_reticle.visible = false


func _on_item_collected(item: Node) :
	#INVETORY SYSTEME ?
	print("added to inventory (not really)  :  ", item)

func _on_body_entered(body : Node3D) -> void : 
	if body.name != "Player" :
		var name = body.name
		var ic = body.get_node_or_null("InteractionComponent")
		if ic and ic.interaction_type == ic.Interaction_Type.ITEM : 
			var mesh : MeshInstance3D = body.find_child("MeshInstance3D" , true , false)
			mesh.material_overlay = outline_material


func _on_body_exited(body : Node3D) -> void :
	if body.name != "Player" :
		var mesh : MeshInstance3D = body.find_child("MeshInstance3D" , true , false)
		if mesh :
			mesh.material_overlay = null
