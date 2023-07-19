extends Node

const LABELS = {
	'family' : ['Have a picnic', 'Watch a movie', 'Go on a date', 'Take kids to school', 'Family game night'],
	'friends' : ['Play football', 'Go out for drinks', 'Hang out with friends', 'Play games online'],
	'work' : ['Make a presentation', 'Respond to emails', 'Talk with colleagues', 'Attend meeting']
} 

const SPECIAL_LABELS = {
	'family' : ["Child's birthday", 'School play', "Spouse's birthday", "Christmas", "Sports day"],
	'friends' : ["School reunion", "Friend's birthday", "Friend's wedding", "Friend's baby shower"],
	'work' : ["End of year review", "Ask for a raise", "Meet with boss"]
}

const TYPES = ['family', 'friends', 'work']

var volume = 80
var score
var tracks

func _ready():
	SilentWolf.configure({
		"api_key": "daguo0B6013jjhkrWjbsD7hk0lBNNG7Q1X5C4WXS",
		"game_id": "calendarquest",
		"log_level": 0
	})
	SilentWolf.scores_config = {
	"open_scene_on_close": "res://Scenes/menu.tscn"
}
