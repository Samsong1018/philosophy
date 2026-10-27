extends Node2D

var phase = 1

func next():
	if phase != 1:
		phase += 1

func _ready() -> void:
	if player.state.gender >= 2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_boys.svg")
	elif player.state.gender <= -2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_girls.svg")

func _on_girls_pressed() -> void:
	phase += 1 
	next()

func _on_boys_pressed() -> void:
	phase += 1
	next()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next()
