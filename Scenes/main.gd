extends Node2D

const EVENT = preload("res://Scenes/event.tscn")
const LANE = preload("res://lane.tscn")
const LINE = preload("res://line.tscn")
const TRACKS = 5
const line_height = 20
const track_height = (720 - line_height*(TRACKS-1)) / TRACKS  

var stats = {
	'family': 0,
	'friends': 0,
	'work': 0
}

var is_setup = false

func _process(delta):
	if not is_setup:
		setup()
		is_setup = true
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Spawn"):
		spawn_event()
	
func setup():
	# Spawn lanes based on number of tracks
	for i in TRACKS:
		var new_line = LINE.instantiate()
		$Calendar.add_child(new_line)
		new_line.set_position(Vector2(0, 360 + (track_height * (i+1)) + line_height * i))
		
		var new_lane = LANE.instantiate()
		new_lane.name = 'Lane' + str(i+1)
		$Calendar.add_child(new_lane)
		new_lane.set_position(Vector2(1920, 360 - (track_height/2) + (track_height * (i+1)) + line_height * i))
	
func spawn_event():
	var event_instance = EVENT.instantiate()
	randomize()
	event_instance.type = global.TYPES[randi() % global.TYPES.size()]
	var available = []
	for i in TRACKS:
		if !get_node('Calendar/Lane'+str(i+1)+'/Area2D').has_overlapping_areas():
			available.append(i+1)
	if available.size() > 0:
		# Eliot problem:
		# event_instance.get_node('ColorRect').set_size(Vector2(700, track_height))
		# event_instance.get_node('Button').set_size(Vector2(700, track_height))
		event_instance.position = get_node('Calendar/Lane' + str(available[randi() % available.size()])).position
		$Events.add_child(event_instance)
