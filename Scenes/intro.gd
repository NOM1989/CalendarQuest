extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("intro")


# Called every frame. 'delta' is the elapsed time since the previous frame


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
