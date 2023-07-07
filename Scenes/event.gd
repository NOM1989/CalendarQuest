extends CharacterBody2D

var type : String = ''
var speed : int = 500
var length : int = 700
var height : int = 115
var colour

func _ready():
	$ColorRect.set_size(Vector2(length, height))
	$Button.set_size(Vector2(length, height))
	$Area2D/CollisionShape2D.scale.x = length
	$Area2D.position.x = length/2
	if type == 'family':
		colour = Color(0.91, 0.8, 0.2, 1.0)
	elif type == 'friends':
		colour = Color(0.21, 0.51, 0.11, 1.0)
	elif type == 'work':
		colour = Color(0.26, 0.26, 0.26, 1.0)
	$ColorRect.color = colour
	randomize()
	$Label.text = global.LABELS[type][randi() % global.LABELS[type].size()]

func _physics_process(delta):
	velocity.x = -speed
	move_and_slide()

func _on_button_pressed():
	queue_free()

func _on_area_2d_area_exited(area):
	if area.name == 'Calendar':
		queue_free()
