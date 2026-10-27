extends Node2D

var phase = 1

func next():
	print(phase)
	if phase != 2 and phase != 5 and phase != 7:
		phase += 1
		if phase == 2:
			$dev.visible = true
			$TextBox/Speaker.text = "Dev"
			$TextBox/responses/confirm.visible = true
			$TextBox/responses/deny.visible = true
			$TextBox/responses/deflect.visible = true
			
			if player.state["reads"]["gender"] >= 1:
				$TextBox/Text.text = "You're on the guys' side, yeah?"
			elif player.state["reads"]["gender"] <= -1:
				$TextBox/Text.text = "Oh, you're sitting with girls at lunch, right?"
			else:
				$TextBox/Text.text = "Oh, I can't tell. weird."
		if phase == 4:
			phase += 1
			$dev.visible = false
			$TextBox/responses/confirm.visible = false
			$TextBox/responses/deny.visible = false
			$TextBox/responses/deflect.visible = false
			$TextBox/responses/Yes.visible = true
			$TextBox/responses/No.visible = true
			$TextBox/Speaker.text = "You"
			$TextBox/Text.text = "You notice a phone laying on the ground. Do you pick it up?"
		if phase == 7:
			if abs(player.state["reads"]["gender"]) >= 2:
				$TextBox/responses/No.visible = false
				$TextBox/responses/Yes.visible = false
				$TextBox/responses/Accept.visible = true
				$TextBox/responses/Rework.visible = true
				$TextBox/responses/Refuse.visible = true
				$dev.visible = false
				$TextBox/Speaker.text = "???"
				var tag = ""
				if player.state["reads"]["gender"] >= 2:
					tag = "boy"
				if player.state["reads"]["gender"] <= -2:
					tag = "girl"
				$TextBox/Text.text = "You just recieved a new tag: " + tag + ". Do you choose to accept?"
			else:
				get_tree().change_scene_to_file("res://Scenes/scene_three.tscn")

func _ready() -> void:
	if player.state["clothes"] == 1:
		$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next()

func _on_confirm_pressed() -> void:
	if player.state["reads"]["gender"] == 1:
		player.state["reads"]["gender"] += 1
	elif player.state["reads"]["gender"] == -1:
		player.state["reads"]["gender"] -= 1
	phase +=1
	$TextBox/responses/confirm.visible = false
	$TextBox/responses/deny.visible = false
	$TextBox/responses/deflect.visible = false
	$TextBox/Text.text = "Cool."

func _on_deny_pressed() -> void:
	player.state["reads"]["belong"] -= 1
	player.state["reads"]["conduct"] -= 1
	player.state["friction"] += 1
	phase += 1
	$TextBox/responses/confirm.visible = false
	$TextBox/responses/deny.visible = false
	$TextBox/responses/deflect.visible = false
	$TextBox/Text.text = "*Shrugs* It doesn't. I was just asking"

func _on_deflect_pressed() -> void:
	$TextBox/Text.text = "Okay"
	$TextBox/responses/confirm.visible = false
	$TextBox/responses/deny.visible = false
	$TextBox/responses/deflect.visible = false
	phase += 1

func _on_yes_pressed() -> void:
	player.state.phone = true
	$Phone.visible = false
	phase += 1
	next()

func _on_no_pressed() -> void:
	player.state.phone = false
	phase += 1
	next()

func _on_accept_pressed() -> void:
	if player.state["reads"]["gender"] >= 2:
		player.state["tags"].append("boy")
	if player.state["reads"]["gender"] <= -2:
		player.state["tags"].append("girl")
	
	get_tree().change_scene_to_file("res://Scenes/scene_three.tscn")

func _on_rework_pressed() -> void:
	player.state["reads"]["gender"] /= 2
	get_tree().change_scene_to_file("res://Scenes/scene_three.tscn")

func _on_refuse_pressed() -> void:
	player.state["reads"]["gender"] /= 2
	get_tree().change_scene_to_file("res://Scenes/scene_three.tscn")
