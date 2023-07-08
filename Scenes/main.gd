extends Node2D

const EVENT = preload("res://Scenes/event.tscn")
const LANE = preload("res://lane.tscn")
const LINE = preload("res://line.tscn")

const line_height = 20
const track_height = (720 - line_height*(TRACKS-1)) / TRACKS
var multiplier = 2
var count = 0
var double_lane = 0
var double_life = 0

# Adjust for difficulty
const TRACKS = 4
const INTERVAL = 200
var EVENT_SPEED = 500
 
@onready var stats = {
	'family': 800,
	'friends': 800,
	'work': 800,
	'rest': 800
}

func _process(delta):
	if Input.is_action_just_pressed("Exit"):
		$PauseMenu.show()
		get_tree().paused = true
	if Input.is_action_just_pressed("Spawn"):
		spawn_double()
	
	for type in global.TYPES:
		get_node("Stats/"+type+"/Bar").value = stats[type]
	$Stats/rest/Bar.value = stats['rest']
	
	count += 1
	# Prevents multiple being spawned in the same interval
	var spawn_occured = 0
	if count >= INTERVAL:
		spawn_event()
		spawn_occured = 1
		count = 0
	if !spawn_occured && count % 40 == 0:
		randomize()
		if randi_range(0, 4) == 4:
			spawn_event()
			spawn_occured = 1
			
	# Run the double lane timer
	if double_life:
		double_life += 1
		if double_life >= 1000:
			$Calendar/double.hide()
			double_life = 0
			double_lane = 0

func _ready():
	$PauseMenu.hide()
	for i in TRACKS:
		var new_line = LINE.instantiate()
		$Calendar.add_child(new_line)
		new_line.set_position(Vector2(0, 360 + (track_height * (i+1)) + line_height * i))
		
		var new_lane = LANE.instantiate()
		new_lane.name = 'Lane' + str(i+1)
		$Calendar.add_child(new_lane)
		new_lane.set_position(Vector2(1920, 360 - (track_height/2) + (track_height * (i+1)) + line_height * i))
	
func spawn_event():
	var available = []
	for i in TRACKS:
		if !get_node('Calendar/Lane'+str(i+1)+'/Area2D').has_overlapping_areas():
			available.append(i+1)
	if available.size() > 0:
		var event_instance = EVENT.instantiate()
		randomize()
		var selected_lane = available[randi() % available.size()]
		event_instance.type = global.TYPES[randi() % global.TYPES.size()]
		event_instance.height = track_height + 1
		event_instance.position = get_node('Calendar/Lane' + str(selected_lane)).position
		event_instance.TRACKS = TRACKS
		event_instance.LANE = selected_lane
		event_instance.speed = EVENT_SPEED
		$Events.add_child(event_instance)

func spawn_double():
	var lane = randi_range(1, TRACKS)
	$Calendar/double.position = get_node('Calendar/Lane' + str(lane)).position
	$Calendar/double.show()
	double_lane = lane
	double_life = 1

func _on_timer_timeout():
	var areas = $Calendar/Point_check.get_overlapping_areas()
	for type in global.TYPES:
		stats[type] -= 0.5 * multiplier
		stats[type] = max(0, min(stats[type], 1000))
		stats['rest'] = min(stats['rest'], 1000)
		stats['rest'] = max(stats['rest'], 0)
	if areas.size() == 0:
		stats['rest'] += multiplier
	elif areas.size() == 1:
		var area = areas[0].get_parent()
		var amount = 3
		if area.LANE == double_lane:
			amount = amount * 2
		stats[area.type] += amount * multiplier
		stats['rest'] -= multiplier
	else:
		for area in areas:
			stats[area.get_parent().type] -= 4 * multiplier
			stats['rest'] -= multiplier


func _on_exit_pressed():
	get_tree().quit()


func _on_resume_pressed():
	global.volume = $PauseMenu/HSlider.value
	$Sounds/BackgroundMusic.volume_db = global.volume*0.5 - 50
	$PauseMenu.hide()
	get_tree().paused = false
