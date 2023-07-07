extends Node2D

const EVENT = preload("res://Scenes/event.tscn")
const LANE = preload("res://lane.tscn")
const LINE = preload("res://line.tscn")
const TRACKS = 6
const line_height = 20
const track_height = (720 - line_height*(TRACKS-1)) / TRACKS  
var multiplier = 2  
 
@onready var stats = {
	'family': 800,   
	'friends': 800,
	'work': 800,      
	'energy': 800
}


func _process(delta):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Spawn"):
		spawn_event()
	
	for type in global.TYPES:
		get_node("Stats/"+type+"/Bar").value = stats[type]
	$Stats/energy/Bar.value = stats['energy']

func _ready():
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
		event_instance.height = track_height + 1
		event_instance.position = get_node('Calendar/Lane' + str(available[randi() % available.size()])).position
		event_instance.tracks = TRACKS
		$Events.add_child(event_instance)


func _on_timer_timeout():
	var areas = $Calendar/Point_check.get_overlapping_areas()
	for type in global.TYPES:
		stats[type] -= 0.5 * multiplier
		stats[type] = min(stats[type], 1000)
		stats[type] = max(stats[type], 0)
		stats['energy'] = min(stats['energy'], 1000)
		stats['energy'] = max(stats['energy'], 0)
	if areas.size() == 0:
		stats['energy'] += multiplier
	elif areas.size() == 1:
		stats[areas[0].get_parent().type] += 3 * multiplier
		stats['energy'] -= multiplier
	else:
		for area in areas:
			stats[area.get_parent().type] -= 4 * multiplier
			stats['energy'] -= multiplier
