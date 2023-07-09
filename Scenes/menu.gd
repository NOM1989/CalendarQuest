extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global.tracks = $HSlider.value


func _on_exit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_how_to_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/instructions.tscn")
