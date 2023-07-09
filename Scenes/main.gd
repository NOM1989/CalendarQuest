extends Node2D

const EVENT = preload("res://Scenes/event.tscn")
const LANE = preload("res://lane.tscn")
const LINE = preload("res://line.tscn")

const line_height = 20

var multiplier = 2
var count = 0
var double_lane = 0
var double_life = 0
var on_a_roll = false
var score

# Adjust for difficulty     
var TRACKS = 6
var track_height = (720 - line_height*(global.tracks-1)) / global.tracks
var INTERVAL = 90
var extras_interval = int(80 - global.tracks * 10)
var EVENT_SPEED = 500
 
@onready var stats = {
	'family': 800,
	'friends': 800,
	'work': 800,
	'rest': 200
}

func _process(delta):
	var too_low = 0
	for stat in stats:
		if stats[stat] < 50:
			too_low += 1
	if too_low > 1:
		finish()
	
	if Input.is_action_just_pressed("Exit"): 
		$PauseMenu.show()
		get_tree().paused = true
	#if Input.is_action_just_pressed("Spawn"):
		#spawn_double()
	
	for type in global.TYPES:
		get_node("Stats/"+type+"/Bar").value = stats[type]
	$Stats/rest/Bar.value = stats['rest']
	
	$Score.text = "Score " + str(score/10)
	
	if on_a_roll:
		score += 1
	for stat in stats:
		if stats[stat] > 800:
			score += 2
		elif stats[stat] > 400:
			score += 1
		elif stats[stat] < 200:
			score -= 1
		if stats[stat] < 100:
			$AnimationPlayer.play("Warning")
			
	count += 1
	# Prevents multiple being spawned in the same interval
	var spawn_occured = 0
	if count >= INTERVAL:
		spawn_event()
		spawn_occured = 1
		count = 0
		INTERVAL = max(INTERVAL - 1, 20)
		EVENT_SPEED = min(EVENT_SPEED+5, 1500)
		$ChallengeBar.value = ((90 - INTERVAL) * EVENT_SPEED * 100) / (70*1500)
	if !spawn_occured && count % extras_interval == 0:
		randomize()
		if randi_range(0, 4) == 4:
			spawn_event()
			spawn_occured = 1
	if double_life == 0 && count % 20 == 0:
		randomize()
		if randi_range(0, 150) == 1:
			spawn_double()
		
	# Run the double lane timer
	if double_life:
		double_life += 1
		if double_life >= 1000:
			$Calendar/double.hide()
			double_life = 0
			double_lane = 0
	
	var total = 0
	for stat in stats:
		if stats[stat] < 200:
			total = -3000
		else:
			total += stats[stat]
	
	if !on_a_roll and total > 2800:
		intense_mode()
	elif on_a_roll and total < 2800:
		back_to_normal()

func _ready():
	TRACKS = global.tracks
	score = 0
	$Cool_light.hide()
	$Calendar/double.hide()
	$Sounds/BackgroundMusic.volume_db = -10
	$Sounds/Alarm.volume_db = 10
	$Sounds/Metal.volume_db = 0
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
		randomize()
		if randi_range(1,35) == 1:
			event_instance.special = true
		else:
			event_instance.special = false
		$Events.add_child(event_instance)

func spawn_double():
	var lane = randi_range(1, TRACKS)
	$Calendar/double.position = get_node('Calendar/Lane' + str(lane)).position
	$Calendar/double.show()
	$Calendar/double/AnimationPlayer.play("x2")
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
		stats['rest'] += 2*multiplier
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
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

			
func _on_resume_pressed():
	global.volume = $PauseMenu/HSlider.value
	$Sounds/BackgroundMusic.volume_db = global.volume*0.5 - 50
	$Sounds/Alarm.volume_db = global.volume*0.5 - 30
	$Sounds/Metal.volume_db = global.volume*0.5 - 40
	$PauseMenu.hide()
	get_tree().paused = false


func _on_animation_player_animation_finished(anim_name):
	$Calendar/double/AnimationPlayer.play("x2")

func intense_mode():
	$Cool_light.show()
	on_a_roll = true
	$Sounds/BackgroundMusic.playing = false
	$Sounds/Metal.playing = true

func back_to_normal():
	$Cool_light.hide()
	on_a_roll = false
	$Sounds/BackgroundMusic.playing = true
	$Sounds/Metal.playing = false

func screen_shake():
	$AnimationPlayer2.play("Shake")

func finish():
	global.score = score/10
	get_tree().change_scene_to_file("res://Scenes/finished.tscn")

# Added more granular changes to game loop instead
#func _on_timer_2_timeout():
#	INTERVAL -= 3
#	EVENT_SPEED += 50
