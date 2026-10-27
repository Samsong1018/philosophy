extends Node2D

var phase = 0

func next():
	if phase != 1:
		phase += 1
		if phase == 1:
			$TextBox/Label.text = "The closest is already full. Someone stocked it before you had an opinion"
			$masculine.visible = true
			$feminine.visible = true
		if phase == 3:
			$masculine.visible = false
			$feminine.visible = false
			if player.state["reads"]["gender"] == 1:
				if player.state["reflex_state"] == 1:
					$TextBox/Label.text = "Your hand went there before you decided."
				elif player.state["reflex_state"] == 0:
					$TextBox/Label.text = "Your hand went to the other pile first. You moved it."
					player.state["friction"] += 1
			if player.state["reads"]["gender"] == -1:
				if player.state["reflex_state"] == 0:
					$TextBox/Label.text = "Your hand went there before you decided."
				elif player.state["reflex_state"] == 1:
					$TextBox/Label.text = "Your hand went to the other pile first. You moved it."
					player.state["friction"] += 1
		if phase == 4:
			$TextBox/Speaker.text = "Mother"
			$TextBox/Label.text = "You look nice. is that what you're wearing today?"
		if phase == 5:
			get_tree().change_scene_to_file("res://Scenes/scene_two.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next()

func _on_masculine_pressed() -> void:
	phase += 1
	player.state["reads"]["gender"] += 1
	player.state["clothes"] = 1
	$Player/Clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	next()

func _on_feminine_pressed() -> void:
	phase += 1
	player.state["reads"]["gender"] -= 1
	player.state["clothes"] = 0
	$Player/Clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
	next()
