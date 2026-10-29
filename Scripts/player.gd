extends Node2D

func _ready() -> void:
	if player.state["clothes"] == 1:
		$clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
