extends Node2D

const EVENT = preload("res://Scenes/event.tscn")

var stats = {
	'family': 0,
	'friends': 0,
	'work': 0
	
	
}

func _process(delta):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Spawn"):
		spawn_event()
	
	
	
func spawn_event():
	var event_instance = EVENT.instantiate()
	randomize()
	event_instance.type = global.TYPES[randi() % global.TYPES.size()]
	var available = []
	for i in 4:
		if !get_node('Calendar/Lane'+str(i+1)+'/Area2D').has_overlapping_areas():
			available.append(i+1)
	if available.size() > 0:
		event_instance.position = get_node('Calendar/Lane' + str(available[randi() % available.size()])).position + Vector2(0,50)
		$Events.add_child(event_instance)
