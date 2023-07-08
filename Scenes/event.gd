extends CharacterBody2D

const POOF = preload("res://Scenes/poof.tscn")

var type : String = ''
var speed : int = 500
var length : int = 500
var height : int
var colour
var TRACKS
var LANE # Which lane this event is in

func _ready():
	randomize()
	length = randi_range(500, 1000)
	$ColorRect.set_size(Vector2(length, height))
	$Button.set_size(Vector2(length, height))   
	$Area2D/CollisionShape2D.scale.x = length
	$Area2D.position.x = length/2
	$ColorRect.position.y = -height/2
	$Button.position.y = -height/2
	if type == 'family':
		colour = Color(0.91, 0.8, 0.2, 1.0) 
	elif type == 'friends': 
		colour = Color(0.21, 0.51, 0.11, 1.0)
	elif type == 'work':
		colour = Color(0.26, 0.26, 0.26, 1.0)
	$ColorRect.color = colour
	randomize()     
	$Label.text = global.LABELS[type][randi() % global.LABELS[type].size()]#
	$Label.label_settings.set_font_size(min(44, 240/TRACKS))

func _physics_process(delta):
	velocity.x = -speed
	move_and_slide()

func _on_button_pressed():
	var poof_instance = POOF.instantiate()
	poof_instance.position = position + Vector2(length/2, 0)
	poof_instance.modulate = colour
	poof_instance.process_material.emission_box_extents = Vector3(length/2, height/2, 1)
	poof_instance.emitting = true
	get_parent().add_child(poof_instance)
	$Area2D.monitorable = false
	visible = false
	$AudioStreamPlayer.volume_db = global.volume*0.5 - 40
	$AudioStreamPlayer.play()
	

func _on_area_2d_area_exited(area):
	if area.name == 'Calendar':
		queue_free()


func _on_audio_stream_player_finished():
	queue_free()
